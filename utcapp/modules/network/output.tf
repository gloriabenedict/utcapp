output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "App-tier subnet IDs, one per AZ"
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "Database subnet IDs, one per AZ"
  value       = aws_subnet.db[*].id
}

output "nat_gateway_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}