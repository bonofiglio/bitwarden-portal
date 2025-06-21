{
  description = "Keep two Bitwarden/Vaultwarden instances in sync";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        overlays.default = final: prev: {
            bitwarden-portal = pkgs.stdenv.mkDerivation {
              pname = "bitwarden-portal";
              version = "1.0.0";

              src = ./.;

              installPhase = ''
                mkdir -p $out/bin
                cp bitwarden-portal.sh $out/bin/bitwarden-portal
                chmod +x $out/bin/bitwarden-portal

                wrapProgram $out/bin/bitwarden-portal \
                  --prefix PATH : ${final.lib.makeBinPath [
                    pkgs.openssl
                    pkgs.coreutils
                    pkgs.findutils
                    pkgs.jq
                    pkgs.bitwarden-cli
                  ]}
              '';
            };
        };
      });
}
