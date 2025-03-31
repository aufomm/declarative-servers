{ config, ... }:
let
  app = "keycloak";
  hostname = "auth.li.lab";
in
{
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
            url = "http://127.0.0.1:${toString config.services.keycloak.settings.http-port}";
          }
        ];
      };
    };
  };
}
