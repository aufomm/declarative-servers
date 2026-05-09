{ config, ... }:
{
  sops.secrets."keycloak/db-password" = {
    sopsFile = ../secrets/pskc-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };

  sops.secrets."fomm_ca" = {
    sopsFile = ../secrets/pskc-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };

  sops.secrets."cf/cert" = {
    sopsFile = ../secrets/pskc-enc.yaml;
    format = "yaml";
    mode = "0440";
  };

  sops.secrets."cf/tunnel_creds" = {
    sopsFile = ../secrets/pskc-enc.yaml;
    format = "yaml";
    mode = "0440";
  };
}
