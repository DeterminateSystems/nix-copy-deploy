{
  description = "`nix copy` deployment example";

  inputs = {
    # We'll tie Nixpkgs to a stable release
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2211.433406.tar.gz";
  };

  outputs =
    { self
    , nixpkgs
    }:

    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems
        ({ pkgs }: {
          default = pkgs.mkShell
            {
              packages = with pkgs; [
                jq
                openssh
                shellcheck
                terraform
              ];
            };
        });

      packages = forAllSystems ({ pkgs }: {
        # We'll keep it simple by using a package from Nixpkgs, but this could be any package
        # we want: a web server, a database server, a Bitcoin miner (ew), etc.
        default = pkgs.ponysay;
      });
    };
}
