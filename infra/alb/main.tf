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

variable "aws_instances" {
  description = "List of EC2 objects"
}

variable "vpc" {
  description = "VPC"
}

variable "aws_subnets" {
  description = "All subnets"
}

variable "security_group" {
  description = "Security group"
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES / RESOURCES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "load_balancer" {
  name               = "load-balancer-${var.stage}"
  load_balancer_type = "application"
  subnets            = [for v in var.aws_subnets : v.id]
  security_groups    = [var.security_group.id]
}

resource "aws_security_group_rule" "allow-http-inbound" {
  type              = "ingress"
  security_group_id = var.security_group.id


  # from_port   = 8080
  # to_port     = 8080
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-http-outbound" {
  type              = "egress"
  security_group_id = var.security_group.id

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

  tags = {
    Name = "lb-listener-${var.stage}"
  }
}

resource "aws_lb_target_group" "lb_targets" {
  name = "target-group"
  # port     = 8080
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lb-listener-${var.stage}"
  }
}

resource "aws_lb_target_group_attachment" "lb_instance1" {
  count            = length(var.aws_instances)
  target_group_arn = aws_lb_target_group.lb_targets.arn
  target_id        = var.aws_instances[count.index].id
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

  tags = {
    Name = "lb-listener-rule-${var.stage}"
  }
}