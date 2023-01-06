variable "pod_cidr" {
  description = "Default subnet CIDR don't overlay with SVC/NODE/JOIN CIDR."
  default = "10.16.0.0/16"
  type = string
}

variable "svc_cidr" {
  description = "Be consistent with apiserver's service-cluster-ip-range."
  default = "10.96.0.0/12"
  type = string
}

variable "join_cidr" {
  description = "Pod/Host communication Subnet CIDR, don't overlay with SVC/NODE/POD CIDR."
  default = "100.64.0.0/16"
  type = string
}

variable "tunnel_type" {
  description = "Tunnel protocol，available options: geneve, vxlan or stt. (stt requires compilation of ovs kernel module)"
  default = "geneve"
  type = string

  validation {
    condition = contains(["geneve", "vxlan", "stt"], var.tunnel_type)
    error_message = "tunnel type must be \"geneve\", \"vxlan\" or \"stt\""
  }
}

variable "node_label" {
  description = "The node label to deploy OVN DB."
  default = "node-role.kubernetes.io/master"
  type = string
}

variable "versioning" {
  description = ""
  default     = {}
  type = object({
    version = optional(string)
  })
}

variable "node" {
  description = "Server nodes to use to install the CNI."
  type = object({
    host    = string
    user    = string
    bastion = optional(string)
  })
}

variable "timeout" {
  description = "SSH Timeout"
  default     = "15m"
  type        = string
}
