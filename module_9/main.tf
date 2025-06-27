terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_m9" {
  cidr_block = "172.16.0.0/16"

}

resource "aws_subnet" "subnet_m9" {
  vpc_id     = aws_vpc.vpc_m9.id
  cidr_block = "172.16.1.0/24"
}

module "create_ec2" {
  source = "./modules/create_ec2"

  subnet_id  = aws_subnet.subnet_m9.id
  vpc_id     = aws_vpc.vpc_m9.id
  name       = var.name

}

