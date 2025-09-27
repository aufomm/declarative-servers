{
  imports = [
    ./networking.nix
    ./traefik.nix
    ./postgres.nix
    ./redis.nix
    ./keycloak
    # ./minio
    ./vault
    ./github-runner.nix
  ];

  services.prometheus.exporters.node.enable = true;
  networking.firewall.allowedTCPPorts = [
    9100
  ];
}
