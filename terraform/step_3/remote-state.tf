data "terraform_remote_state" "step_1" {
  backend = "local"

  config = {
    path = "../step_1/terraform.tfstate"
  }
}

data "terraform_remote_state" "step_2" {
  backend = "local"

  config = {
    path = "../step_2/terraform.tfstate"
  }
}
