{ config, ... }:
let
  app = "minio";
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.${app} = {
      entrypoints = [ "websecure" ];
      rule = "Host(`${app}.li.lab`)";
      service = "${app}";
      middlewares = [ ];
    };
    routers."${app}-insecure" = {
      entrypoints = [ "web" ];
      rule = "Host(`${app}.li.lab`)";
      service = "${app}";
      middlewares = [ "redirect-to-https" ];
    };
    routers."${app}-console" = {
      entrypoints = [ "websecure" ];
      rule = "Host(`${app}-console.li.lab`)";
      service = "${app}-console";
      middlewares = [ ];
    };
    routers."${app}-console-insecure" = {
      entrypoints = [ "web" ];
      rule = "Host(`${app}-console.li.lab`)";
      service = "${app}-console";
      middlewares = [ "redirect-to-https" ];
    };
    services.${app} = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://127.0.0.1:9000";
          }
        ];
      };
    };
    services."${app}-console" = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://127.0.0.1:9001";
          }
        ];
      };
    };
  };
}
