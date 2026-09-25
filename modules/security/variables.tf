variable "name_prefix" {
  description = "Prefix for Name tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the security groups."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR, used to restrict private-tier egress."
  type        = string
}

variable "admin_cidr" {
  description = "Administrator source CIDR allowed to SSH to the bastion."
  type        = string
}
