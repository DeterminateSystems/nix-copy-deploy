{
  description = "nix copy deployment example";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_20
            jq
            openssh
            shellcheck
            terraform
          ];
        };

        packages.default = pkgs.buildGoModule {
          name = "hello-nix-copy";
          src = ./.;
          subPackages = [ "cmd/hello-nix-copy" ];
          vendorSha256 = "sha256-wCFprlv7z53N/m0lUWEqKl5RDJBe0r8XjFJHQ2HygMc=";
        };
      });
}
