resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tf-example-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "igw"
  }
}

resource "aws_subnet" "subnet" {
  count             = var.instance_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.subnets}.${count.index}.0/24"
  availability_zone = "${var.subnet_availability_zone}${local.availability_zones[count.index]}"

  tags = {
    Name = "tf-example-subnet${count.index}"
  }
}

resource "aws_network_interface" "adapter" {
  count           = var.instance_count
  subnet_id       = aws_subnet.subnet[count.index].id
  private_ips     = ["{var.ips}.${count.index}.1"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "primary_network_interface${count.index}"
  }
}

resource "aws_instance" "this" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World ${count.index}" > index.html
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
    Name = "AWS-Instance-${count.index}"
  }
}

resource "aws_security_group" "security_group" {
  name   = "jamesa555-ec2-security-group"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}
