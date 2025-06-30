variable "ami" {
  type        = string
  description = "AMI id to use for the instance"
  default     = "ami-05fcfb9614772f051"

  validation {
    condition     = length(var.ami) > 4 && substr(var.ami, 0, 4) == "ami-"
    error_message = "The ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be one of: t2.micro, t3.micro, t3.small, t3.medium."
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet to run the instance in"
}

variable "root_volume_size" {
  type        = number
  default     = 8
  description = "Size of root volume in GB"

  validation {
    condition     = var.root_volume_size > 0
    error_message = "Volume size must be greater than 0."
  }
}

variable "root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume type"

}

variable "root_volume_encrypted" {
  type        = bool
  default     = true
  description = "Encryption of root volume"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the instance"
  default     = {}
}

variable "name" {
  type        = string
  description = "Default tag for related infrastructure"

  validation {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC to run the instance in"
}

variable "allowed_ssh_cidr" {
  type        = list(string)
  default     = ["203.0.113.17/32"]
  description = "CIDR blocks defining IP addresses that are allowed to SSH into the instance"

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "Public internet access (0.0.0.0/0) is not allowed for SSH. Use a restricted CIDR."
  }
}




