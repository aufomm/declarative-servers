{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../disk-config.nix
    ./traefik.nix
    ./postgres.nix
    ./redis.nix
    ./minio
    ./github-runner.nix
  ];

  networking = {
    hostName = "tools";
    useNetworkd = true;
  };

  nix.settings = {
    substituters = [ "https://nixpkgs-terraform.cachix.org" ];
    trusted-public-keys = [
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.yq
    pkgs.jq
    pkgs.deck
  ];
}
