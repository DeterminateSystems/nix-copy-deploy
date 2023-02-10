#!/usr/bin/env bash
set -euo pipefail

# Get root project directory
ROOT=$(git rev-parse --show-toplevel)

NIX_INSTALLATION_SCRIPT="curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"

# Terraform state file
TF_STATE="${ROOT}/terraform.tfstate"

# Check for existence of a Terraform state file
if [ ! -f "$TF_STATE" ]; then
  echo "No Terraform state file at $TF_STATE. Have you run 'terraform apply'?"
  exit 1
fi

# The system of the target host (Ubuntu 22.04)
SYSTEM="x86_64-linux"

# The desired package
FLAKE_PATH=".#packages.${SYSTEM}.default"

# Get the Nix store path
NIX_STORE_PATH="$(nix path-info $FLAKE_PATH)"

# An array of droplet IPs drawn from the Terraform state file produced by `terraform apply`
DROPLET_IPS=$(jq -f "${ROOT}"/scripts/get-ip-addresses.jq < "${TF_STATE}" | tr -d '"')

echo "Starting deployment"

# Run the deployment script on each droplet
for ip in $DROPLET_IPS; do
  target="root@${ip}"
  run="ssh -o StrictHostKeyChecking=no ${target}"

  echo "Installing Nix on droplet at ${ip}"
  $run "${NIX_INSTALLATION_SCRIPT}"

  echo "Copying ${FLAKE_PATH} to ${target}"
  nix copy \
    --to ssh-ng://root@"${ip}" \
    $FLAKE_PATH

  echo "Installing ${FLAKE_PATH} to profile"
  $run nix profile install "${NIX_STORE_PATH}"

  echo "Running the copied program"
  $run "echo 'Hello from nix copy!' | ponysay"
done
