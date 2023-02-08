#!/bin/bash

DROPLETS=$(jq '.resources[] | select(.type == "digitalocean_droplet")' < terraform.tfstate)
IPS=$(echo "${DROPLETS}" | jq '.resources[] | select(.type == "digitalocean_droplet") | .instances[].attributes.ipv4_address' | tr -d '"')
NUM_DROPLETS="echo ${IPS} | jq '. | length'"
SYSTEM="x86_64-linux"
FLAKE_PATH="nixpkgs#legacyPackages.${SYSTEM}.hello"
SSH="ssh -o StrictHostKeyChecking=no"

echo "Deploying hello package to ${NUM_DROPLETS} DigitalOcean droplets"

for ip in $IPS; do
  echo "Installing Nix on ${ip}"
  $SSH root@"$ip" "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"

  echo "Copying ${FLAKE_PATH} to ${ip}"
  nix copy --to ssh-ng://root@"${ip}" $FLAKE_PATH

  echo "Installing ${FLAKE_PATH} to user profile"
  $SSH root@"${ip}" nix profile install "$(nix path-info $FLAKE_PATH)"

  $SSH root@"${ip}" hello
done
