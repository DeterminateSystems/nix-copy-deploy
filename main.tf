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

resource "digitalocean_ssh_key" "default" {
  name       = "nixos-ssh-key"
  public_key = file("./secrets/nix_copy_droplet.pub")
}

resource "digitalocean_droplet" "nixos" {
  image    = "ubuntu-18-04-x64"
  size     = "s-1vcpu-1gb"
  name     = "nixos"
  count    = var.do_num_droplets
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}
