variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnets" {
  description = "Subnets"
  type        = list(string)
}

variable "ips" {
  description = "Adapter IP addresses"
  type        = list(string)
}

variable "ami" {
  description = "AMI"
  type        = string
  default     = "ami-0b6d6dacf350ebc82"
}
