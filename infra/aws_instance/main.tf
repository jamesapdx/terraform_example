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

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  load_balancer_type = "application"
  subnets         = [for v in aws_subnet.subnet : v.id]
  security_groups = [aws_security_group.security_group.id]
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
  name = "target-group"
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
  count = var.instance_count
  target_group_arn = aws_lb_target_group.lb_targets.arn
  target_id        = aws_instance.this[count.index].id
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
