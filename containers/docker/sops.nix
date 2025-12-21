{ config, ... }:
{
  sops.secrets."env" = {
    sopsFile = ../secrets/docker-enc.yaml;
    format = "yaml";
    mode = "0440";
  };

  sops.secrets."fomm_ca" = {
    sopsFile = ../secrets/docker-enc.yaml;
    format = "yaml";
    mode = "0444";
  };

  sops.secrets."vault-agent/approle_id" = {
    sopsFile = ../secrets/docker-enc.yaml;
    format = "yaml";
    mode = "0444";
  };
  
  sops.secrets."vault-agent/approle_secret" = {
    sopsFile = ../secrets/docker-enc.yaml;
    format = "yaml";
    mode = "0440";
  };
}
