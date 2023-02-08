# nix copy deploy

## Setup

```shell
# Load Nix stuff
direnv allow

# Generate SSH keys
ssh-keygen

# Select ./secrets
# Provide password

eval "$(ssh-agent -s)"

ssh-add ./secrets/id_rsa
# Enter previously provided password

# Create DigitalOcean droplets
terraform apply -auto-approve

# Run deploy script
./deploy.sh
```
