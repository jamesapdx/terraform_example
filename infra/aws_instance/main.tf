resource "aws_vpc" "vpc" {
  cidr_block = "${var.network}.0.0/16"

  tags = {
    Name = "vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "igw-${var.env}"
  }
}

resource "aws_subnet" "subnet" {
  count             = var.instance_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.network}.${count.index + 1}.0/24"
  availability_zone = "${var.subnet_availability_zone}${local.availability_zones[count.index]}"

  tags = {
    Name = "subnet${count.index}-${var.env}"
  }
}

resource "aws_network_interface" "adapter" {
  count           = var.instance_count
  subnet_id       = aws_subnet.subnet[count.index].id
  private_ips     = ["{var.network}.${count.index + 1}.100"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "primary_network_interface${count.index}-${var.env}"
  }
}

resource "aws_instance" "this" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World ${count.index} #{var.env}" > index.html
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
    Name = "EC2-instance-${count.index}-${var.env}"
  }
}

resource "aws_security_group" "security_group" {
  name   = "jamesa555-ec2-security-group-${var.env}"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}
