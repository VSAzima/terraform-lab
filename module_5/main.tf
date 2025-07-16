terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "bucket_m5" {
  bucket = "bucket-m5"

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_instance" "instance_m5" {
  ami                    = "ami-05fcfb9614772f051"
  instance_type          = "t3.micro"
  count                  = var.ec2_enabled ? 1 : 0
  subnet_id              = aws_subnet.subnet_m5.id
  vpc_security_group_ids = [aws_security_group.security_group_m5.id]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
  
  depends_on = [
    aws_subnet.subnet_m5 
  ]
}

resource "aws_vpc" "vpc_m5" {
  cidr_block = "172.16.0.0/16"

}

resource "aws_subnet" "subnet_m5" {
  vpc_id     = aws_vpc.vpc_m5.id
  cidr_block = "172.16.1.0/24"
}

resource "aws_security_group" "security_group_m5" {
  name        = "security_group_m5"
  vpc_id      = aws_vpc.vpc_m5.id
}

resource "aws_security_group_rule" "security_group_rule_m5" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_m5.id
}


