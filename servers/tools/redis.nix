{
  config,
  pkgs,
  ...
}:
let
  redisPassword = config.sops.secrets."redis-credential".path;
in
{
  services.redis = {
    package = pkgs.valkey;
    servers.default = {
      enable = true;
      port = 6379;
      bind = null;
      requirePassFile = "${redisPassword}";
    };
  };

  sops.secrets."redis-credential" = {
    sopsFile = ./secrets/secrets-enc.yaml;
    format = "yaml";
    mode = "0440";
    owner = config.users.users.redis.name;
    group = config.users.users.redis.group;
    restartUnits = [ "redis-default.service" ];
  };

  users.users.redis = {
    isSystemUser = true;
    group = "redis";
    description = "redis service user";
  };

  users.groups.redis = { };

  networking.firewall.allowedTCPPorts = [
    6379
  ];
}
