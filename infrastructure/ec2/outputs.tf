output "public_ip" {
  value       = var.associate_public_ip_address ? module.ec2.public_ip : ""
  description = "public ip address"
}

output "instance_id" {
  value = module.ec2.id
}

output "volume_ids" {
  value = [for volume in var.additional_ebs_volumes : aws_ebs_volume.data[volume.name].id]
  description = "List of EBS volume IDs attached to the instance"
}

output "private_ip" {
  value       = module.ec2.private_ip
  description = "Private IP address of the EC2 instance"
}