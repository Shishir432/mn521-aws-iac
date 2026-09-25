# ---------------------------------------------------------------------------
# Compute module: SSH key pair, bastion host (public subnet) and
# private Linux server (private subnet).
# ---------------------------------------------------------------------------

# Latest Amazon Linux 2023 AMI, resolved from AWS's public SSM parameter so
# the code never hard-codes a region-specific AMI ID.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ------------------------------ Key pair -----------------------------------

# Terraform generates an ED25519 key; the public half is uploaded to AWS and
# the private half is written locally with 0400 permissions (git-ignored).
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = { Name = "${var.name_prefix}-key" }
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${var.key_output_dir}/${var.name_prefix}-key.pem"
  file_permission = "0400"
}

# ----------------------------- Instances -----------------------------------

locals {
  common_instance_settings = {
    ami           = data.aws_ssm_parameter.al2023.insecure_value
    instance_type = var.instance_type
    key_name      = aws_key_pair.this.key_name
  }
}

resource "aws_instance" "bastion" {
  ami                    = local.common_instance_settings.ami
  instance_type          = local.common_instance_settings.instance_type
  key_name               = local.common_instance_settings.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    hostname = "${var.name_prefix}-bastion"
    role     = "Bastion host (jump box)"
  })

  # IMDSv2 only - blocks SSRF-style credential theft from instance metadata
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.name_prefix}-bastion"
    Role = "bastion"
  }
}

resource "aws_instance" "private" {
  ami                         = local.common_instance_settings.ami
  instance_type               = local.common_instance_settings.instance_type
  key_name                    = local.common_instance_settings.key_name
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.private_sg_id]
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    hostname = "${var.name_prefix}-app01"
    role     = "Private Linux application server"
  })

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.name_prefix}-app01"
    Role = "application"
  }
}
