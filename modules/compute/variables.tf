variable "name_prefix" {
  description = "Prefix for Name tags."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for the bastion host."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet for the Linux application server."
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group attached to the bastion."
  type        = string
}

variable "private_sg_id" {
  description = "Security group attached to the private server."
  type        = string
}

variable "key_output_dir" {
  description = "Local directory where the generated private key is saved."
  type        = string
}
