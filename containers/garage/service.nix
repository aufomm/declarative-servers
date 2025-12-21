{ config, pkgs, ... }:

let
  region = "us-east-1";
  apiPort = 3900;
  rpcPort = 3901;
  adminPort = 3903;
  webuiPort = 3909;
  garageEnv = config.sops.secrets."garage/env".path;
  garageWebuiEnv = config.sops.secrets."garage/webui-env".path;
in
{
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    environmentFile = garageEnv;
    settings = {
      db_engine = "lmdb";
      replication_factor = 1;

      rpc_bind_addr = "127.0.0.1:${toString rpcPort}";
      rpc_public_addr = "127.0.0.1:${toString rpcPort}";

      s3_api = {
        s3_region = region;
        api_bind_addr = "127.0.0.1:${toString apiPort}";
      };

      admin = {
        api_bind_addr = "127.0.0.1:${toString adminPort}";
      };
      use_local_tz = true;
      compression_level = 1;
    };
  };

  services.garage-webui = {
    enable = true;
    port = webuiPort;
    environmentFile = garageWebuiEnv;
    waitForServices = [ "garage.service" ];

    # Module options (can be overridden by environmentFile)
    apiBaseUrl = "http://127.0.0.1:${toString adminPort}";
    s3Region = region;
    s3EndpointUrl = "http://127.0.0.1:${toString apiPort}";
  };
}
