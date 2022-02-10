variable "stage" {
  description = "The deployment stage"
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all applicable objects."
  default     = {}
}
