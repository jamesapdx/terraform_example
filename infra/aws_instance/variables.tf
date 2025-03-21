variable "env" {
  description = "Environment"
  type        = string
}

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
