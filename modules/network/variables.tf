variable "name_prefix" {
  description = "Prefix for Name tags (e.g. mn521-enterprise-dev)."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Two CIDR blocks for the private subnets."
  type        = list(string)
}
