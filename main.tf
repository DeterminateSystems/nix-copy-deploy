terraform {
  required_version = "1.3.9"
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
  name       = "nix-copy-ssh-key"
  public_key = file("./secrets/nix_copy_droplet.pub")
}

resource "digitalocean_droplet" "default" {
  image    = var.do_droplet_image
  size     = var.do_droplet_size
  name     = "nix-copy-${count.index}"
  count    = var.do_num_droplets
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}
