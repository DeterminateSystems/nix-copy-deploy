{
  description = "nix copy deployment example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
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

        packages.default = {
          inherit (pkgs) ponysay;
        };
      });
}
