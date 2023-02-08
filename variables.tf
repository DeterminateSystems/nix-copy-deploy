variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "do_num_droplets" {
  type    = number
  default = 3
}

variable "do_droplet_ssh_key_name" {
  type    = string
  default = "nix_copy_droplet"
}
