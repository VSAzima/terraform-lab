variable "project_id" {
  type        = string
  description = "The Google Cloud project ID"
}

variable "region" {
  description = "The region in which to provision resources"
  type        = string
  default     = ""
}

variable "zone" {
  description = "The zone in which to provision resources"
  type        = string
  default     = ""
}

variable "instance_count" {
  type        = number
  description = "Number of instances in a managed instance group"
}

variable "image_name" {
  description = "Image to use in VM provisioning"
  type        = string
}

variable "network_self_link" {
  type        = string
  description = "Self link of the VPC network"
}

variable "subnetwork_self_link" {
  type        = string
  description = "Self link of the subnet"
}

variable "health_check" {
  type        = string
  description = "Health check id"
}
