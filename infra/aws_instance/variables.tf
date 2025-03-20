variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type = number
  default = 2
}

variable "subnet_availability_zone" {
  description = "Subnet availability zone"
  type = string
  default = "us-west-2"
}

locals {
  availability_zones = ["a", "b", "c", "d"]
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnets" {
  description = "Subnets"
  type        = string
}

variable "ips" {
  description = "Adapter IP addresses"
  type        = string
}

variable "ami" {
  description = "AMI"
  type        = string
  default     = "ami-0b6d6dacf350ebc82"
}
