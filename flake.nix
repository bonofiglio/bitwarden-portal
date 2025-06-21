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
        bitwarden-portal = pkgs.stdenv.mkDerivation {
          pname = "bitwarden-portal";
          version = "1.0.0";

          src = ./.;

          runtimeInputs = with pkgs; [
            python314
            curlMinimal
            bash
            openssl
            ncurses
            coreutils
            gnumake
            libgcc
            gnugrep
            binutils
            findutils
            wget
            unzip
            gnutar
            jq
            bitwarden-cli
          ];

          installPhase = ''
            mkdir -p $out/bin
            cp bitwarden-portal.sh $out/bin/bitwarden-portal
            chmod +x $out/bin/bitwarden-portal
          '';
        };
      in {
        packages.default = bitwarden-portal;
        overlays.default = final: prev: {
            bitwarden-portal = bitwarden-portal;
        };
      });
}
