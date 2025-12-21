{ ... }:
{
  sops.secrets."garage/env" = {
    sopsFile = ../secrets/garage-enc.yaml;
    format = "yaml";
    mode = "0440";
  };
  
  sops.secrets."garage/webui-env" = {
    sopsFile = ../secrets/garage-enc.yaml;
    format = "yaml";
    mode = "0440";
  };
}
