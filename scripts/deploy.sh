#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)

# Terraform state file
TF_STATE="${ROOT}/terraform.tfstate"

if [ ! -f "$TF_STATE" ]; then
  echo "No Terraform state file at $TF_STATE. Have you run 'terraform apply'?"
  exit 1
fi

# The system of the target host
SYSTEM="x86_64-linux"

# The desired package (TODO: make this a local package)
FLAKE_PATH=".#packages.${SYSTEM}.default"

# SSH command
SSH="ssh -o StrictHostKeyChecking=no"

# An array of droplet IPs drawn from the Terraform state file produced by `terraform apply`
IPS=$(jq -f "${ROOT}"/scripts/get-ip-addresses.jq < "${TF_STATE}" | tr -d '"')

for ip in $IPS; do
  target="root@${ip}"

  echo "Installing Nix on droplet at ${ip}"
  #$SSH "${target}" "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"

  echo "Copying ${FLAKE_PATH} to ${target}"
  nix copy \
  --to ssh-ng://root@"${ip}" \
  --substituters https://cache.nixos.org \
  $FLAKE_PATH

  echo "Installing ${FLAKE_PATH} to profile"
  $SSH "${target}" nix profile install "$(nix path-info $FLAKE_PATH)"

  $SSH "${target}" "echo 'Hello Nix' | ponysay"
done
