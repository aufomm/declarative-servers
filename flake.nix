{
  description = "Manage NixOS server remotely";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      disko,
      sops-nix,
      home-manager,
      colmena,
      ...
    }@inputs:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f system nixpkgs.legacyPackages.${system});
      mkColmenaConfig =
        {
          user ? "fomm",
          host,
          buildOnTarget ? false,
          system ? "x86_64-linux",
          extraModules ? [ ],
          hostModule,
        }:
        {
          deployment = {
            targetHost = host;
            targetPort = 22;
            targetUser = user;
            buildOnTarget = buildOnTarget;
            tags = [ "homelab" ];
          };
          nixpkgs.system = system;
          imports = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./servers/configuration.nix
            hostModule
          ] ++ extraModules;
          time.timeZone = "Australia/Melbourne";
        };
    in
    {
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        defaults =
          { pkgs, ... }:
          {
            environment.systemPackages = [
              pkgs.curl
            ];
          };
        tools = mkColmenaConfig {
          host = "tools";
          buildOnTarget = true;
          hostModule = ./servers/tools;
          extraModules = [
            sops-nix.nixosModules.sops
          ];
        };
      };

      apps = forEachSystem (
        system: pkgs: {
          apply = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply" ''
                #!/usr/bin/env bash
                set -euo pipefail

                if [ $# -eq 0 ]; then
                  echo "Usage: apply <server-name>"
                  exit 1
                fi

                serverName="$1"
                echo "Applying to server: $serverName"
                exec ${
                  colmena.packages.${system}.colmena
                }/bin/colmena apply --experimental-flake-eval --on "$serverName"
              ''
            );
          };
        }
      );
    };
}
