{ config, ... }:
{
  sops.secrets."keycloak/db-password" = {
    sopsFile = ../secrets/keycloak-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };

  sops.secrets."keycloak/ssl_certificate" = {
    sopsFile = ../secrets/keycloak-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };

  sops.secrets."keycloak/ssl_certificate_key" = {
    sopsFile = ../secrets/keycloak-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };

  sops.secrets."fomm_ca" = {
    sopsFile = ../secrets/keycloak-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };
}
