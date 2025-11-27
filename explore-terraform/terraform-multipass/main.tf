terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.0"
    }
  }
}

provider "multipass" {}

resource "multipass_instance" "example" {
  name   = "tf-demo"
  image  = "jammy"  # Ubuntu 22.04
  cpus   = 2
  memory = "2G"
  disk   = "5G"
}

