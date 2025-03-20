terraform {
  cloud {
    organization = "Jamesa555Org"
    
    workspaces {
      name = "prod"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "infra_aws_instance" {
  source = "./infra/aws_instance"
  instance_type = var.instance_type
  instance_count = var.instance_count
  subnet_availability_zone = var.subnet_availability_zone
  vpc_cidr = var.vpc_cidr
  subnets = var.subnets
  ips = var.ips
  ami = var.ami
}

module "infra_s3_bucket" {
  source = "./infra/s3_bucket"
  
}