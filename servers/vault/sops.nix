{ config, ... }:
{
  sops.secrets."vault/ssl_certificate" = {
    sopsFile = ./secrets/vault-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.vault.name;
    group = config.users.users.vault.group;
  };

  sops.secrets."vault/ssl_certificate_key" = {
    sopsFile = ./secrets/vault-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.vault.name;
    group = config.users.users.vault.group;
  };
}
