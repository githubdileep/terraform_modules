# Output the ID of the VPC created
output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

# Output the IDs of the public subnets created
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = aws_subnet.public_subnet.*.id
}

# Output the IDs of the private subnets created
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value = aws_subnet.private_subnet.*.id
}

# Output the IDs of the database subnets created
output "database_subnet_ids" {
  description = "The IDs of the database subnets"
  value = aws_subnet.database_subnet.*.id
}
