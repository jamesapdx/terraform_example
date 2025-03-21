output "aws_instance_names" {
  description = "Instance names"
  value       = { for key, value in aws_instance.this : key => value.tags.Name }
}

output "aws_instance_ips" {
  description = "Instance ips"
  value       = { for key, value in aws_instance.this : key => value.private_ip }
}

output "aws_instances" {
  description = "EC2 objects"
  value       = aws_instance.this
}

output "vpc" {
  description = "VPC"
  value       = aws_vpc.vpc
}

output "aws_subnets" {
  description = "Subnets"
  value       = aws_subnet.subnet
}

output "security_group" {
  description = "Security group"
  value       = aws_security_group.security_group

}