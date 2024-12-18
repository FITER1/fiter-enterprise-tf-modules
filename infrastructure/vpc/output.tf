output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = module.vpc.azs
}

output "intra_subnets" {
  description = "Subnet ID for intra subnets"
  value       = module.vpc.intra_subnets
}

output "private_route_table_ids" {
  description = "Route Table ID's for the Private subnet"
  value       = module.vpc.private_route_table_ids
}
