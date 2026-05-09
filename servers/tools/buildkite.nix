{
  config,
  pkgs,
  lib,
  nixpkgs-terraform,
  ...
}:
let
  bkToken = config.sops.secrets."bk-token".path;
in
{
  services = {
    buildkite-agents = {
      nixos = {
        enable = true;
        name = "nixos";
        tokenPath = "${bkToken}";
      };
    };
  };


  sops.secrets."bk-token" = {
    sopsFile = ./secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = "buildkite-agent-nixos";
    group = "buildkite-agent-nixos";
  };
}
