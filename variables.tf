variable "aws_region" {
  description = "AWS region to deploy into (Sydney by default)."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Short name used as a prefix for every resource Name tag."
  type        = string
  default     = "mn521-enterprise"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.project_name))
    error_message = "project_name must be 3-24 characters of lowercase letters, digits or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment label (dev, test or prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC. Chosen so it does not overlap the on-premises GNS3 ranges."
  type        = string
  default     = "10.50.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets (one per Availability Zone)."
  type        = list(string)
  default     = ["10.50.1.0/24", "10.50.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnets are required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private subnets (one per Availability Zone)."
  type        = list(string)
  default     = ["10.50.11.0/24", "10.50.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnets are required."
  }
}

variable "admin_cidr" {
  description = "The only source network allowed to SSH to the bastion host - use your own public IP as a /32 (e.g. 203.0.113.10/32)."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid CIDR and must not be 0.0.0.0/0 (SSH must not be open to the internet)."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the bastion and the private Linux server (t3.micro is Free Tier eligible)."
  type        = string
  default     = "t3.micro"
}
