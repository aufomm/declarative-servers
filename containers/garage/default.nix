{
  imports = [
    ./service.nix
    ./sops.nix
    ./traefik.nix
  ];

  networking.hostName = "garage";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };
}
