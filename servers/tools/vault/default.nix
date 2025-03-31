{
  imports = [
    ./service.nix
    ./sops.nix
  ];

  networking.firewall.allowedTCPPorts = [
    8200
  ];
}
