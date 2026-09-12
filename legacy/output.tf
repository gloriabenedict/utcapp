output "vpc_id" {
  value = aws_vpc.vpc1.id  
}

output "sub-public-id" {
    value = aws_subnet.sub1.id
  
}
output "Nat-id" {
  value = aws_nat_gateway.nat1.id
  
}
output "vpc_arn" {
  value = aws_vpc.vpc1.arn
}