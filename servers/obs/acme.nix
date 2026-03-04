{ pkgs, config, ... }:
let
  grafanaName = "grafana.li.lab";
  otelName = "obs.li.lab";
in
{
  security.acme = {
    acceptTerms = true;
    server = "https://vault.li.lab:8200/v1/ecc/acme/directory";
    defaults = {
      email = "admin@${otelName}";
      keyType = "ec256";
    };
    certs."${otelName}" = {
      group = "nginx";
      reloadServices = [ "opentelemetry-collector.service" ];
      enableDebugLogs = true;
    };
    certs."${grafanaName}" = {
      group = "nginx";
      reloadServices = [ "grafana.service" ];
      enableDebugLogs = true;
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."${otelName}" = {
      enableACME = true;
    };
    
    virtualHosts."${grafanaName}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
