terraform {
  required_version = "1.3.7"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.26.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "nixos" {
  image = "ubuntu-18-04-x64"
  size  = "s-1vcpu-1gb"
  name  = "nixos"
  count = 3
}
