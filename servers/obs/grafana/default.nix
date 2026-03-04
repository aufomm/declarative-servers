{
  imports = [
    ./service.nix
    ./sops.nix
    ./dashboards.nix
    ./datasources.nix
  ];

  environment.etc."grafana/dashboards".source = ./dashboards;
}
