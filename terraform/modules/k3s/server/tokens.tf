resource "random_password" "server_token" {
  length  = 64
  special = false
}

resource "random_password" "agent_token" {
  length  = 64
  special = false
}
