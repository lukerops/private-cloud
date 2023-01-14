variable "interface" {
  description = "Name of the interface on the control plane(s) which will announce the VIP."
  type        = string
}

variable "address" {
  description = "VIP address to be used for the control plane."
  type        = string
}

variable "versioning" {
  description = ""
  default     = {}
  type = object({
    version = optional(string)
  })
}
