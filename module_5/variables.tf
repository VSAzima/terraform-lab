variable "ec2_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    module  = "m5"
    project = "gridu"
  }
}
