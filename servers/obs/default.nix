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
    ./acme.nix
    ./grafana
    ./logs
    ./traces
    ./metrics
    ./collector
  ];

  sops.secrets."fomm_ca" = {
    sopsFile = ./secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0444";
  };

  sops.secrets."auth_cert" = {
    sopsFile = ./secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0444";
  };

  networking = {
    hostName = "obs";
    useNetworkd = true;
  };
  
  environment.systemPackages = [
    pkgs.openssl
  ];
}
