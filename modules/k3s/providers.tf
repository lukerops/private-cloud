terraform {
  required_version = ">= 1.3.0, < 1.4.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1, < 3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3, < 4.0.0"
    }

    ssh = {
      source  = "loafoe/ssh"
      version = ">= 2.2.1, < 3.0.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.1.0, < 4.0.0"
    }
  }
}

provider "kubernetes" {
  client_certificate     = local.kubeconf.client.certificate
  client_key             = local.kubeconf.client.key
  cluster_ca_certificate = local.kubeconf.cluster.ca_certificate
  host                   = local.kubeconf.cluster.host
}
