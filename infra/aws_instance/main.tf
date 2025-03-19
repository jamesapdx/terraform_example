resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

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

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "us-west-2b"


  tags = {
    Name = "tf-example-subnet2"
  }
}

resource "aws_network_interface" "adapter1" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["172.16.10.100"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "primary_network_interface1"
  }
}

resource "aws_network_interface" "adapter2" {
  subnet_id       = aws_subnet.subnet2.id
  private_ips     = ["172.16.11.100"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "primary_network_interface2"
  }
}

resource "aws_instance" "aws_instance1" {
  ami           = "ami-0b6d6dacf350ebc82"
  instance_type = "t2.micro"
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World 1" > index.html
    python3 -m http.server 80 &
    EOF
    # python3 -m http.server 8080 &

  network_interface {
    network_interface_id = aws_network_interface.adapter1.id
    device_index         = 0
  }
  lifecycle {
    # Reference the security group as a whole or individual attributes like `name`
    replace_triggered_by = [aws_security_group.security_group]
  }
  tags = {
    Name = "AWS_Instance1"
  }
}

resource "aws_instance" "aws_instance2" {
  ami           = "ami-0b6d6dacf350ebc82"
  instance_type = "t2.micro"
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World 2" > index.html
    python3 -m http.server 80 &
    EOF
    # python3 -m http.server 8080 &


  network_interface {
    network_interface_id = aws_network_interface.adapter2.id
    device_index         = 0
  }
  lifecycle {
    # Reference the security group as a whole or individual attributes like `name`
    replace_triggered_by = [aws_security_group.security_group]
  }
  tags = {
    Name = "AWS_Instance2"
  }
}

resource "aws_security_group" "security_group" {
  name   = "jamesa555-ec2-security-group"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups    = [aws_security_group.security_group.id]

}

resource "aws_security_group_rule" "allow-http-inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.security_group.id

  # from_port   = 8080
  # to_port     = 8080
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-http-outbound" {
  type              = "egress"
  security_group_id = aws_security_group.security_group.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "lb_targets" {
  name     = "target-group"
  # port     = 8080
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "lb_instance1" {
  target_group_arn = aws_lb_target_group.lb_targets.arn
  target_id        = aws_instance.aws_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "lb_instance2" {
  target_group_arn = aws_lb_target_group.lb_targets.arn
  target_id        = aws_instance.aws_instance2.id
  port             = 80
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_targets.arn
  }
}
