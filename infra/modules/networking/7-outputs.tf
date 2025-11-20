output "vpc-id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "private-subnet-ids" {
  description = "List of IDs of private subnets"
  # Iterate through the map and pull out the .id attribute
  value = [for s in aws_subnet.private : s.id]
}

output "public-subnet-ids" {
  description = "List of IDs of public subnets"
  # Iterate through the map and pull out the .id attribute
  value = [for s in aws_subnet.public : s.id]
}
