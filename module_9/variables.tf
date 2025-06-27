variable "region" {
  description = "The region to create the instance in."
  type        = string
  default     = "eu-north-1"
}

variable "name" {
  type        = string
  description = "Default tag for related infrastructure"
  default     = "module_9"
  validation {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty."
  }
}
