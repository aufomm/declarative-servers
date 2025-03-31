{ config, ... }:
{
  sops.secrets."minio-root-credential" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.minio.name;
    group = config.users.users.minio.group;
  };
}
