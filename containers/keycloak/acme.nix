{ pkgs, ... }:
let
  hostname = "auth.li.lab";
in
{
  environment.systemPackages = [
    pkgs.openssl
  ];

  security.acme = {
    acceptTerms = true;
    server = "https://vault.li.lab:8200/v1/ecc/acme/directory";
    defaults = {
      email = "admin@${hostname}";
      keyType = "ec256";
    };
    certs."${hostname}" = {
      group = "nginx";
      reloadServices = [ "keycloak.service" ];
      enableDebugLogs = true;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      enableACME = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
  ];
}
