output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value = [
    aws_nat_gateway.nat_a.id,
    aws_nat_gateway.nat_b.id
  ]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]
}
