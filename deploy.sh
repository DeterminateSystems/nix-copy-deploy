#!/bin/bash

IPS=$(cat terraform.tfstate | jq '.resources[].instances[].attributes.ipv4_address' | tr -d '"')

for ip in $IPS; do
  nix copy --to ssh-ng://${ip} .#packages.aarch64-darwin.default
done
