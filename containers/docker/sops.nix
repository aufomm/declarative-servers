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
}
