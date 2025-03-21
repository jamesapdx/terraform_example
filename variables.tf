variable "env" {
  description = "Environment, one of staging, dev, prod"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of instances to create, 4 max"
  type        = number
  default     = 2
}

variable "subnet_availability_zone" {
  description = "Subnet availability zone"
  type        = string
  default     = "us-west-2"
}

variable "network" {
  description = "Network portion of the IPv4 address"
  type        = string
  default     = "172.16"
}

variable "ami" {
  description = "AMI, linux version"
  type        = string
  default     = "ami-0b6d6dacf350ebc82"  # amazon linux
}
