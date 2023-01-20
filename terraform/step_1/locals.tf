locals {
  pods_cidr = "10.42.0.0/16"
  svcs_cidr = "10.43.0.0/16"

  kubeapi_ip = "10.8.0.10"
  coredns_ip = "10.43.0.10"

  server_nodes = [
    {
      name = "k3s-arm64-1-1"
      host = "10.8.0.50"
      user = "k3s"
      taints = {
        "CriticalAddonsOnly"             = "true:NoExecute"
        "node-role.kubernetes.io/master" = "true:NoSchedule"
      }
    },
  ]

  agent_nodes = [
    {
      name = "k3s-amd64-2-1"
      host = "10.8.0.150"
      user = "k3s"
      labels = {
        "node-role.kubernetes.io/storage"      = "true"
        "node.longhorn.io/create-default-disk" = "config"
      }
      annotations = {
        "node.longhorn.io/default-disks-config" = jsonencode([
          {
            name            = "b55307db-449a-4119-acdd-dd8f9b89ba3c"
            path            = "/mnt/longhorn/b55307db-449a-4119-acdd-dd8f9b89ba3c"
            allowScheduling = true
            tags            = ["hdd"]
          },
          {
            name            = "b90d7e50-c73b-4da8-94ce-9c3c083bdf59"
            path            = "/mnt/longhorn/b90d7e50-c73b-4da8-94ce-9c3c083bdf59"
            allowScheduling = true
            tags            = ["hdd"]
          },
          {
            name            = "db6cf8a7-cc21-4bb2-92e2-13f4e8bd89f9"
            path            = "/mnt/longhorn/db6cf8a7-cc21-4bb2-92e2-13f4e8bd89f9"
            allowScheduling = true
            tags            = ["hdd"]
          },
        ])
      }
    },
    # {
    #   name = "k3s-1-3"
    #   host = "10.254.0.102"
    #   user = "k3s"
    # },
    # {
    #   name = "k3s-1-4"
    #   host = "10.254.0.103"
    #   user = "k3s"
    # },
  ]
}
