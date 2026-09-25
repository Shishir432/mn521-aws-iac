output "key_pair_name" {
  description = "Name of the AWS key pair."
  value       = aws_key_pair.this.key_name
}

output "private_key_path" {
  description = "Local path of the generated private key."
  value       = local_sensitive_file.private_key.filename
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI used for both instances."
  value       = data.aws_ami.al2023.id
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host."
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host."
  value       = aws_instance.bastion.private_ip
}

output "private_instance_id" {
  description = "Instance ID of the private Linux server."
  value       = aws_instance.private.id
}

output "private_instance_ip" {
  description = "Private IP of the private Linux server."
  value       = aws_instance.private.private_ip
}
