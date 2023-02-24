{
  description = "`nix copy` deployment example";

  inputs = {
    # We'll tie Nixpkgs to a stable release
    nixpkgs.url = "nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          jq
          openssh
          shellcheck
          terraform
        ];
      };

      # We'll keep it simple by using a package from Nixpkgs, but this could be any package
      # we want: a web server, a database server, a Bitcoin miner (ew), etc.
      packages.default = pkgs.ponysay;
    });
}
