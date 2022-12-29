variable "versioning" {
  description = "Select the k3s version."
  default     = {}
  type = object({
    version = optional(string)
    channel = optional(string, "stable")
  })

  validation {
    condition     = contains(["stable", "latest", "testing"], var.versioning.channel)
    error_message = "The k3s channel must be \"stable\" or \"latest\"."
  }

  validation {
    condition     = var.versioning.version != null && startswith(var.versioning.version, "v")
    error_message = "The k3s version always starts with \"v\" (Ex: \"v1.24\")."
  }
}

variable "timeout" {
  description = "SSH Timeout"
  default     = "15m"
  type        = string
}

variable "server_nodes" {
  description = "List of all k3s server nodes."
  type = list(object({
    name          = string
    host          = string
    user          = string
    bastion       = optional(string)
    labels        = optional(map(string), {})
    taints        = optional(map(string), {})
  }))

  validation {
    condition     = length(var.server_nodes) > 0
    error_message = "Need at least 1 server node."
  }
}

variable "agent_nodes" {
  description = "List of all k3s agent nodes."
  default     = []
  type = list(object({
    name          = string
    host          = string
    user          = string
    bastion       = optional(string)
    labels        = optional(map(string), {})
    taints        = optional(map(string), {})
  }))
}

variable "extra_commands" {
  default = {}
  type = object({
    server = optional(list(string), [])
    agent  = optional(list(string), [])
  })
}

variable "kubeapi_ip" {
  description = "Kube API IP to connect nodes."
  default     = null
  type        = string
  nullable    = true
}
