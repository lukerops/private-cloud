locals {
  pods_cidr = "10.42.0.0/16"
  svcs_cidr = "10.43.0.0/16"

  kubeapi_ip = "10.254.0.10"
  coredns_ip = "10.43.0.10"

  server_nodes = [
    {
      name = "k3s-1-1"
      host = "10.254.0.100"
      user = "k3s"
      taints = {
        "CriticalAddonsOnly"             = "true:NoExecute"
        "node-role.kubernetes.io/master" = "true:NoSchedule"
      }
    },
  ]

  agent_nodes = [
    {
      name = "k3s-1-2"
      host = "10.254.0.101"
      user = "k3s"
      # taints = {
      #   "CriticalAddonsOnly"             = "true:NoExecute"
      #   "node-role.kubernetes.io/master" = "true:NoSchedule"
      # }
    },
    {
      name = "k3s-1-3"
      host = "10.254.0.102"
      user = "k3s"
    },
    {
      name = "k3s-1-4"
      host = "10.254.0.103"
      user = "k3s"
    },
  ]
}
