variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "do_num_droplets" {
  type        = number
  description = "The number of droplets to deploy"
}

variable "do_droplet_size" {
  type        = string
  description = "The machine size for the droplets"
}

variable "do_droplet_image" {
  type        = string
  description = "The DigitalOcean image for the deployed droplets"
}
