{ config, ... }:
{
  sops.secrets."keycloak/db-password" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.keycloak.name;
    group = config.users.users.keycloak.group;
    restartUnits = [ "keycloak.service" ];
  };
}
