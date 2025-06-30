#ts:skip=AC-AW-IS-IN-M-0144 Subnet id, as well as VPC are inherited from the root module
resource "aws_instance" "instance_m9" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
  }

  ebs_optimized = true
  monitoring    = true

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true
    precondition {
      condition     = var.vpc_id != data.aws_vpc.default.id
      error_message = "Deployment blocked: default VPC is not allowed. Use a custom VPC."
  }
  }

  tags = var.tags
}

#ts:skip=AC_AW_NS_LC_LC-L_0443 This rule is ensured by variable validation
resource "aws_security_group" "security_group_m9" {
  name        = "${var.name}-sg_m9"
  vpc_id      = var.vpc_id
  description = "allows ssh connection to an instance from an approved IP list"

  ingress {
    description = "allow ssh from an approved list"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    description = "allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_ssh_cidr
  }

  tags = var.tags
}  

data "aws_vpc" "default" {
  default = true
}

