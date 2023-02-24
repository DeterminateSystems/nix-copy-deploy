#!/usr/bin/env bash
set -euo pipefail

# Get root project directory
ROOT=$(git rev-parse --show-toplevel)

# Terraform state file
TF_STATE="${ROOT}/terraform.tfstate"

# Check for existence of a Terraform state file
if [ ! -f "$TF_STATE" ]; then
  echo "No Terraform state file at $TF_STATE. Have you run 'terraform apply'?"
  exit 1
fi

# An array of droplet IPs drawn from the Terraform state file produced by `terraform apply`
DROPLET_IPS=$(jq -f "${ROOT}"/scripts/get-ip-addresses.jq < "${TF_STATE}" | tr -d '"')

# Run the deployment script on each droplet
for ip in $DROPLET_IPS; do
  target="root@${ip}"
  run="ssh -o StrictHostKeyChecking=no ${target}"

  $run "echo 'Hello from nix copy!' | ponysay"
done
