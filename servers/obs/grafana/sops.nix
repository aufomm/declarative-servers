{ config, ... }:
{
  sops.secrets."grafana/client_secret" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };

  sops.secrets."grafana/secret_key" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };
}
