{
  imports = [
    ./service.nix
    ./httpbin.nix
    ./sops.nix
    ./traefik.nix
  ];

  networking.hostName = "docker";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  users.users.fomm = {
    extraGroups = [
      "docker"
    ];
  };
}
