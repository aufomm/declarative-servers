{ config, ... }:
{
  sops.secrets."vault_ssl_certificate" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.vault.name;
    group = config.users.users.vault.group;
  };

  sops.secrets."vault_ssl_certificate_key" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.vault.name;
    group = config.users.users.vault.group;
  };
}
