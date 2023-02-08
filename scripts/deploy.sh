#!/usr/bin/env bash
set -euo pipefail

# Terraform state file
TF_STATE="./terraform.tfstate"

if [ ! -f "$TF_STATE" ]; then
  echo "No Terraform state file at $TF_STATE. Have you run 'terraform apply'?"
  exit 1
fi

# The system of the target host
SYSTEM="x86_64-linux"

# The desired package (TODO: make this a local package)
FLAKE_PATH="nixpkgs#legacyPackages.${SYSTEM}.hello"

# SSH command
SSH="ssh -o StrictHostKeyChecking=no"

# An array of droplet IPs drawn from the Terraform state file produced by `terraform apply`
IPS=$(jq '.resources[] | select(.type == "digitalocean_droplet") | .instances[].attributes.ipv4_address' < "${TF_STATE}" | tr -d '"')

for ip in $IPS; do
  echo "Installing Nix on ${ip}"
  $SSH root@"$ip" "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"

  echo "Copying ${FLAKE_PATH} to ${ip}"
  nix copy --to ssh-ng://root@"${ip}" $FLAKE_PATH

  echo "Installing ${FLAKE_PATH} to user profile"
  $SSH root@"${ip}" nix profile install "$(nix path-info $FLAKE_PATH)"

  $SSH root@"${ip}" hello
done
