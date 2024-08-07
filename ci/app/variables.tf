variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource."
}