.resources[] | select(.type == "digitalocean_droplet") | .instances[].attributes.ipv4_address
