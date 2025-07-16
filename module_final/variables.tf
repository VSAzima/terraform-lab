variable "project_id" {
  description = "The project in which to provision resources"
  type        = string
  default     = "gd-gcp-gridu-cloud-cert"
}

variable "region" {
  description = "The region in which to provision resources"
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The zone in which to provision resources"
  type        = string
  default     = "europe-west4-c"
}

variable "allowed_ips" {
  description = "CIDR blocks defining IP addresses that are allowed to access the instance"
  type        = list(string)
  default     = ["172.18.184.0/23"] #GD-wifi limit

  validation {
    condition     = var.allowed_ips != "0.0.0.0/0"
    error_message = "Public internet access (0.0.0.0/0) is not allowed. Use a restricted CIDR."
  }
}

variable "golden_image_name" {
  description = "Image to use in VM provisioning"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "instance_count" {
  type        = number
  description = "Number of instances in a managed instance group"
  default     = 3
}