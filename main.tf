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
}