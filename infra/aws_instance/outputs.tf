output "aws_instance_names" {
  description = "Instance names"
  value = { for key, value in aws_instance.this : key => value.tags.Name}
}

output "aws_instance_ips" {
  description = "Instance names"
  value = { for key, value in aws_instance.this : key => value.private_ip}
}
