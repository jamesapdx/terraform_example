resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-sample"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-sample"
  }
}

resource "aws_network_interface" "adapter1" {
  subnet_id   = aws_subnet.subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface1"
  }
}

resource "aws_network_interface" "adapter2" {
  subnet_id   = aws_subnet.subnet.id
  private_ips = ["172.16.10.101"]

  tags = {
    Name = "primary_network_interface2"
  }
}

resource "aws_instance" "aws_instance1" {
  ami           = "ami-0b6d6dacf350ebc82"
  instance_type = "t2.micro"


  network_interface {
    network_interface_id = aws_network_interface.adapter1.id
    device_index         = 0
  }

  tags = {
    Name = "AWS_Instance1"
  }
}

resource "aws_instance" "aws_instance2" {
  ami           = "ami-0b6d6dacf350ebc82"
  instance_type = "t2.micro"


  network_interface {
    network_interface_id = aws_network_interface.adapter2.id
    device_index         = 0
  }

  tags = {
    Name = "AWS_Instance2"
  }
}

