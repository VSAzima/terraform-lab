resource "aws_instance" "instance_m9" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
  }

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group" "security_group_m9" {
  name        = "${var.name}-sg_m9"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}  
