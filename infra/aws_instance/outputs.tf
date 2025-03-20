output "aws_instance_ip1" {
    description = "IP of instance 1"
    value = aws_instance.aws_instance1.private_ip
}

output "aws_instance_ip2" {
    description = "IP of instance 2"
    value = aws_instance.aws_instance2.private_ip
}