# `nix copy` deployment example

> **Warning**: this example project only works on `x86_64-linux` machines.

This repo provides an example of using [`nix copy`][nix-copy] as a deployment tool. This Nix utility enables you to copy Nix [closures] from one machine to another, which provides a declarative alternative to tools like [rsync].

This example involves standing up some [DigitalOcean][do] droplets using [Terraform] and then `nix copy`ing a Nix closure to those machines and running the copied program (in this case [ponysay]). It isn't a particularly realistic example, of course, but it does suggest how you could use a setup like this to copy and start up long-running processes serving real traffic.

The Terraform logic is in [`main.tf`](./main.tf) while the deployment script is in [`scripts/deploy.sh`](./scripts/deploy.sh).

One of the core benefits of the approach you see here is that `nix copy` is [Nix store][store] aware. It copies only those dependencies that aren't yet present in the target machine's Nix store, while many tools need to install everything from scratch every time. In this example, each droplet has a "fresh" Nix store and the full ponysay closure needs to be copied over; but in a scenario where you were updating a target machine with some dependencies already present, the `nix copy` operation may be substantially more efficient than an equivalent non-Nix approach.

## Running this example

### Setup

First, [install] Nix using the [Determinate Nix Installer][nix-installer]:

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Then create a [DigitalOcean][do] account and get an API key.

Then:

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
```

### Deploy

With the droplets deployed, you can run the [deployment script](./scripts/deploy.sh):

```shell
./scripts/deploy.sh
```

This script does a few things:

- It gathers a list of droplet IPs from the [Terraform] state file
- It uses SSH to do a few things on each droplet:
  - It installs Nix using the [Determinate Nix Installer][nix-installer]
  - It copies the closure for [ponysay] to the target machine's [Nix store][store]
  - It adds the package to the target machine's user profile
  - It pipes the string `Hello from nix copy!` to [ponysay] on the target machine, which outputs a lovely equine greeting

### Run

Once you've deployed ponysay on each machine, you can run it on each of them:

```shell
./scripts/run.sh
```

This script uses SSH to pipe the string `Hello from nix copy!` to [ponysay] on the target machine, which outputs a lovely equine greeting. A different horse each time!


### Tear down

Once you've run the example, spin the droplets down:

```shell
terraform apply -destroy -auto-approve
```

[closures]: https://zero-to-nix.com/concepts/closures
[do]: https://digitalocean.com
[go]: https://go.dev
[install]: https://zero-to-nix.com/start/install
[nix-copy]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-copy
[nix-installer]: https://github.com/DeterminateSystems/nix-installer
[ponysay]: https://github.com/erkin/ponysay
[rsync]: https://linux.die.net/man/1/rsync
[store]: https://zero-to-nix.com/concepts/nix-store
[terraform]: https://terraform.io
