terraform {
  required_version = ">= 1.3.0, < 1.4.0"

  required_providers {
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
