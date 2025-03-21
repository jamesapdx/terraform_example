# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURATION / PROVIDERS
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  cloud {
    organization = "Jamesa555Org"
    
    workspaces {
      name = "prod"  #ignore for now, not using cloud workspaces
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

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

# ----------------------------------------------------------------------------------------------------------------------
# MODULES
# ----------------------------------------------------------------------------------------------------------------------

module "ec2" {
  source = "./infra/ec2"

  stage = var.stage
  instance_count = var.instance_count
  instance_type = var.instance_type
  subnet_availability_zone = var.subnet_availability_zone
  network = var.network
  ami = var.ami
}

module "alb" {
  source = "./infra/alb"

  stage = var.stage
  aws_instances = module.ec2.aws_instances
  vpc = module.ec2.vpc
  aws_subnets = module.ec2.aws_subnets
  security_group = module.ec2.security_group
}

module "s3_bucket" {
  source = "./infra/s3_bucket"

  stage = var.stage
}

# ----------------------------------------------------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------------------------------------------------

output "aws_instance_ips" {
    description = "IPs of instances"
    value = module.ec2.aws_instance_ips
}

output "s3_bucket_name" {
    description = "Name of s3 bucket"
    value = module.s3_bucket.s3_bucket_name
}

output "s3_bucket_arn" {
    description = "ARN of the S3 bucket"
    value = module.s3_bucket.s3_bucket_arn
}
