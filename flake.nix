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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
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
      nixpkgs-terraform,
      nixos-generators,
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
          tags ? [ ],
          extraModules ? [ ],
          hostModule,
        }:
        {
          deployment = {
            targetHost = host;
            targetPort = 22;
            targetUser = user;
            buildOnTarget = buildOnTarget;
            tags = [
              "homelab"
            ]
            ++ tags;
          };
          nixpkgs.system = system;
          imports = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            hostModule
            ./share
            ./share/runtime-config.nix
          ]
          ++ extraModules;
          time.timeZone = "Australia/Melbourne";
        };
    in
    {
      nixosConfigurations.vault = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./share
          ./share/runtime-config.nix
          ./servers
        ];
      };

      packages.x86_64-linux = {
        lxc = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./share
            home-manager.nixosModules.home-manager
            { networking.hostName = "nixos"; }
          ];
          format = "proxmox-lxc";
        };
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
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
          buildOnTarget = false;
          hostModule = ./servers/tools;
          tags = [ "vm" ];
          extraModules = [
            ./servers
            disko.nixosModules.disko
            { _module.args.nixpkgs-terraform = nixpkgs-terraform; }
          ];
        };
        vault = mkColmenaConfig {
          host = "lxc-vault";
          buildOnTarget = false;
          hostModule = ./servers/vault;
          tags = [ "vm" ];
          extraModules = [
            ./servers
            disko.nixosModules.disko
          ];
        };
        lxc-redis = mkColmenaConfig {
          host = "lxc-redis";
          hostModule = ./containers/redis;
          tags = [ "lxc" ];
          extraModules = [
            ./containers
          ];
        };
        lxc-vault = mkColmenaConfig {
          host = "lxc-vault";
          hostModule = ./containers/vault;
          tags = [ "lxc" ];
          extraModules = [
            ./containers
          ];
        };
        lxc-keycloak = mkColmenaConfig {
          host = "lxc-keycloak";
          hostModule = ./containers/keycloak;
          tags = [ "lxc" ];
          extraModules = [
            ./containers
          ];
        };
        lxc-docker = mkColmenaConfig {
          host = "lxc-docker";
          hostModule = ./containers/docker;
          tags = [ "lxc" ];
          extraModules = [
            ./containers
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
                exec ${colmena.packages.${system}.colmena}/bin/colmena apply --on "$serverName"
              ''
            );
          };
          build-lxc = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply" ''
                #!/usr/bin/env bash
                set -euo pipefail
                lxc_path="${self.packages.${system}.lxc}/tarball"
                cp -f "$lxc_path"/nixos-*.tar.xz terraform/proxmox/nixos.tar.xz
              ''
            );
          };
          bootstrap-nix = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply" ''
                #!/usr/bin/env bash
                set -euo pipefail

                if [ $# -eq 0 ]; then
                  echo "Usage: apply <host-ip-address>"
                  exit 1
                fi

                host_ip="$1"
                echo "Applying to server: $serverName"
                nix run github:nix-community/nixos-anywhere -- --flake .#vault --target-host fomm@"$host_ip"
              ''
            );
          };
        }
      );
    };
}
