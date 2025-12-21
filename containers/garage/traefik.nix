{ ... }:
let
  app = "garage";
  appGui = "garage-webui";
  garageApiPort = 3900;
  garageGuiPort = 3909;
  s3Hostname = "s3.li.lab";
  guiHostname = "admin.s3.li.lab";
in
{
  services.traefik = {
    enable = true;
    dynamicConfigOptions = {
      tls.options.default.minVersion = "VersionTLS12";
      http = {
        middlewares.redirect-to-https.redirectscheme = {
          scheme = "https";
          permanent = true;
        };
        routers."${app}-insecure" = {
          entrypoints = [ "web" ];
          rule = "Host(`${s3Hostname}`)";
          service = "${app}";
          middlewares = [ "redirect-to-https" ];
        };
        routers.${app} = {
          entrypoints = [ "websecure" ];
          rule = "Host(`${s3Hostname}`)";
          service = "${app}";
          middlewares = [ ];
        };

        routers."${appGui}-insecure" = {
          entrypoints = [ "web" ];
          rule = "Host(`${guiHostname}`)";
          service = "${appGui}";
          middlewares = [ "redirect-to-https" ];
        };
        routers.${appGui} = {
          entrypoints = [ "websecure" ];
          rule = "Host(`${guiHostname}`)";
          service = "${appGui}";
          middlewares = [ ];
        };

        services.${app} = {
          loadBalancer = {
            passHostHeader = true;
            servers = [
              {
                url = "http://127.0.0.1:${toString garageApiPort}";
              }
            ];
          };
        };

        services.${appGui} = {
          loadBalancer = {
            passHostHeader = true;
            servers = [
              {
                url = "http://127.0.0.1:${toString garageGuiPort}";
              }
            ];
          };
        };
      };
    };

    staticConfigOptions = {
      api.dashboard = false;
      log.level = "INFO";
      serversTransport.insecureSkipVerify = true;
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
          http.tls.certResolver = "vault";
        };
      };
      certificatesResolvers.vault.acme = {
        email = "d@aufomm.com";
        storage = "/var/lib/traefik/ecc-acme.json";
        caServer = "https://vault.li.lab:8200/v1/ecc/acme/directory";
        keyType = "EC384";
        httpChallenge.entryPoint = "web";
        certificatesDuration = 720;
      };
    };
  };
}
