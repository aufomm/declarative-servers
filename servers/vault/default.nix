{
  imports = [
    ./service.nix
    ./sops.nix
  ];

  networking = {
    hostName = "vault";
    useNetworkd = true;
  };
  networking.firewall.allowedTCPPorts = [
    8200
  ];
}
