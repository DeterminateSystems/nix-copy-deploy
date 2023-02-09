# nix copy deploy

## Setup

```shell
cp .env.example .env

# Set value for DIGITALOCEAN_TOKEN

# Load Nix stuff
direnv allow

# Generate SSH keys
ssh-keygen -f ./secrets/nix_copy_droplet -N ''

# Add private key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ./secrets/nix_copy_droplet

# Create DigitalOcean droplets
terraform apply -auto-approve

# Run deploy script
./scripts/deploy.sh
```

## Teardown

```shell
terraform apply -destroy -auto-approve
```
