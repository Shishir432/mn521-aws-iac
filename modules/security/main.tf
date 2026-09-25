# ---------------------------------------------------------------------------
# Security module: least-privilege security groups.
#   bastion-sg : SSH only from the administrator's IP
#   private-sg : SSH and ICMP only from the bastion security group
# Rules use the standalone aws_vpc_security_group_*_rule resources
# recommended for AWS provider v5, so each rule is tracked individually.
# ---------------------------------------------------------------------------

resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "Bastion host - SSH from administrator IP only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-bastion-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  description       = "SSH from administrator"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound (updates, SSH to private hosts)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "private" {
  name        = "${var.name_prefix}-private-sg"
  description = "Private Linux server - reachable only via the bastion"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-private-sg" }
}

# Referencing the bastion SG (not a CIDR) means only instances that carry
# bastion-sg can connect, even if IP addresses change.
resource "aws_vpc_security_group_ingress_rule" "private_ssh_from_bastion" {
  security_group_id            = aws_security_group.private.id
  description                  = "SSH from bastion only"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "private_icmp_from_bastion" {
  security_group_id            = aws_security_group.private.id
  description                  = "ICMP (ping) from bastion for connectivity testing"
  ip_protocol                  = "icmp"
  from_port                    = -1
  to_port                      = -1
  referenced_security_group_id = aws_security_group.bastion.id
}

# Egress is limited to the VPC unless a NAT Gateway exists, in which case
# outbound internet (for OS updates) is allowed.
resource "aws_vpc_security_group_egress_rule" "private_egress" {
  security_group_id = aws_security_group.private.id
  description       = var.allow_private_internet_egress ? "Outbound via NAT Gateway" : "Outbound restricted to the VPC"
  ip_protocol       = "-1"
  cidr_ipv4         = var.allow_private_internet_egress ? "0.0.0.0/0" : var.vpc_cidr
}
