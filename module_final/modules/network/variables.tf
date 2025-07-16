variable "project_id" {
  description = "The project in which to provision resources"
  type        = string
}

variable "region" {
  description = "The region in which to provision resources"
  type        = string
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR blocks defining IP addresses that are allowed to access the instance"
}

variable "instance_group_url" {
  type        = string
  description = "URL of the instance group"
}