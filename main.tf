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

module "infra_aws_instance" {
  source = "./infra/aws_instance"

  env = var.env
  instance_count = var.instance_count
  instance_type = var.instance_type
  subnet_availability_zone = var.subnet_availability_zone
  network = var.network
  ami = var.ami
}

module "alb" {
  source = "./infra/alb"

  env = var.env
  aws_instances = module.infra_aws_instance.aws_instances
  vpc = module.infra_aws_instance.vpc
  aws_subnets = module.infra_aws_instance.aws_subnets
  security_group = module.infra_aws_instance.security_group
}

module "infra_s3_bucket" {
  source = "./infra/s3_bucket"

  env = var.env
}
