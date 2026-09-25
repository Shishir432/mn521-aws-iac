output "vpc_id" {
  description = "ID of the enterprise VPC."
  value       = module.network.vpc_id
}

output "availability_zones" {
  description = "Availability Zones used."
  value       = module.network.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs (a/b)."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (a/b)."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (null when enable_nat_gateway = false)."
  value       = module.network.nat_gateway_id
}

output "security_group_ids" {
  description = "Security group IDs."
  value = {
    bastion = module.security.bastion_sg_id
    private = module.security.private_sg_id
  }
}

output "key_pair_name" {
  description = "AWS key pair name."
  value       = module.compute.key_pair_name
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  value       = module.compute.ami_id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = module.compute.bastion_public_ip
}

output "private_instance_ip" {
  description = "Private IP address of the Linux server."
  value       = module.compute.private_instance_ip
}

output "ssh_to_bastion" {
  description = "Command to SSH to the bastion."
  value       = "ssh -i ${module.compute.private_key_path} ec2-user@${module.compute.bastion_public_ip}"
}

output "ssh_to_private_via_bastion" {
  description = "Command to SSH to the private server through the bastion (ProxyJump)."
  value       = "ssh -i ${module.compute.private_key_path} -o ProxyCommand=\"ssh -i ${module.compute.private_key_path} -W %h:%p ec2-user@${module.compute.bastion_public_ip}\" ec2-user@${module.compute.private_instance_ip}"
}
