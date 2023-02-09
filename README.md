# `nix copy` deployment example

This repo provides an example of using [`nix copy`][nix-copy] as a deployment tool. This Nix utility enables you to copy Nix [closures] from one machine to another, which provides a declarative alternative to tools like [rsync].

This example involves standing up some [DigitalOcean] droplets using [Terraform] and then `nix copy`ing a Nix closure to those machines and running the copied program (in this case a simple [web server](./cmd/hello/main.go) written in [Go]). It isn't a particularly realistic example, of course, as the droplets aren't connected to the open Internet, but it does suggest how you could use a setup like this to copy and start up long-running processes serving real traffic.

The Terraform logic is in [`main.tf`](./main.tf) while the deployment script is in [`scripts/deploy.sh`](./scripts/deploy.sh).

## Setup

Create a [DigitalOcean][do] account and get an API key. Make sure you have [Nix installed][install]. Then:

```shell
# Provide environment variables
cp .env.example .env

# Set a value for DIGITALOCEAN_TOKEN

# Load Nix development environment
direnv allow # or `nix develop` if you don't have direnv installed

# Generate SSH keys
ssh-keygen -f ./secrets/nix_copy_droplet -N ''

# Add private key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ./secrets/nix_copy_droplet

# Create DigitalOcean droplets
terraform apply -auto-approve

# Run the deployment script
./scripts/deploy.sh
```

## Teardown

Once you've run the example, spin the droplets down:

```shell
terraform apply -destroy -auto-approve
```

[closures]: https://zero-to-nix.com/concepts/closures
[do]: https://digitalocean.com
[go]: https://go.dev
[install]: https://zero-to-nix.com/start/install
[nix-copy]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-copy
[ponysay]: https://github.com/erkin/ponysay
[rsync]: https://linux.die.net/man/1/rsync
[terraform]: https://terraform.io
