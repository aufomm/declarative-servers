{ config, ... }:
let
  app-version = "0.5.0";
  app = "token-inspector";
  hostname = "jwt.li.lab";
  redisIP = "192.168.3.100";
  vaultIP = "192.168.3.172";
  authIP = "192.168.3.173";
  rockProxyIP = "192.168.3.162";
  lxcProxyIP = "192.168.3.174";
  homeCA = config.sops.secrets."fomm_ca".path;
in
{
  virtualisation.oci-containers.containers.${app} = {
    autoStart = true;
    image = "ghcr.io/aufomm/oauth2-token-inspector:${app-version}";
    ports = [
      "127.0.0.1:3000:3000/tcp"
    ];
    volumes = [
      "${homeCA}:/cert/ca.pem:ro"
    ];
    environment = {
      NODE_EXTRA_CA_CERTS = "/cert/ca.pem";
    };
    extraOptions = [
      "--network=kong"
      "--add-host=redis.li.lab:${redisIP}"
      "--add-host=vault.li.lab:${vaultIP}"
      "--add-host=auth.li.lab:${authIP}"
      "--add-host=proxy.li.rock:${rockProxyIP}"
      "--add-host=proxy.li.lab:${lxcProxyIP}"
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.${app} = {
      entrypoints = [ "websecure" ];
      rule = "Host(`${hostname}`)";
      service = "${app}";
      middlewares = [ ];
    };
    routers."${app}-insecure" = {
      entrypoints = [ "web" ];
      rule = "Host(`${hostname}`)";
      service = "${app}";
      middlewares = [ "redirect-to-https" ];
    };
    services.${app} = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://127.0.0.1:3000";
          }
        ];
      };
    };
  };
}
