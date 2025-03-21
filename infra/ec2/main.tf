# ----------------------------------------------------------------------------------------------------------------------
# Platform Standard Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "stage" {
  description = "The development stage (i.e. `dev`, `stg`, `prd`)"
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES / LOCALS / REMOTE STATE
# ----------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

variable "subnet_availability_zone" {
  description = "Subnet availability zone"
  type        = string
  default     = "us-west-2"
}

locals {
  # will append to subnet_availability_zone
  availability_zones = ["a", "b", "c", "d"]
}

variable "network" {
  description = "Network portion of the IPv4 address"
  type        = string
}

variable "ami" {
  description = "AMI, linux version"
  type        = string
  default     = "ami-0b6d6dacf350ebc82"
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES / RESOURCES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "vpc" {
  cidr_block = "${var.network}.0.0/16"

  tags = {
    Name = "vpc-${var.stage}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "igw-${var.stage}"
  }
}

resource "aws_subnet" "subnet" {
  count             = var.instance_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.network}.${count.index + 1}.0/24"
  availability_zone = "${var.subnet_availability_zone}${local.availability_zones[count.index]}"

  tags = {
    Name = "subnet${count.index}-${var.stage}"
  }
}

resource "aws_network_interface" "adapter" {
  count           = var.instance_count
  subnet_id       = aws_subnet.subnet[count.index].id
  private_ips     = ["{var.network}.${count.index + 1}.100"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "primary_network_interface${count.index}-${var.stage}"
  }
}

resource "aws_instance" "this" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World ${count.index} #{var.stage}" > index.html
    python3 -m http.server 80 &
    EOF
  # python3 -m http.server 8080 &

  network_interface {
    network_interface_id = aws_network_interface.adapter[count.index].id
    device_index         = 0
  }
  lifecycle {
    replace_triggered_by = [aws_security_group.security_group]
  }
  tags = {
    Name = "EC2-instance-${count.index}-${var.stage}"
  }
}

resource "aws_security_group" "security_group" {
  name   = "jamesa555-ec2-security-group-${var.stage}"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------------------------------------------------

output "aws_instance_names" {
  description = "Instance names"
  value       = { for key, value in aws_instance.this : key => value.tags.Name }
}

output "aws_instance_ips" {
  description = "Instance IPs"
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