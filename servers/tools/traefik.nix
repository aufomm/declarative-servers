{
  config,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.traefik = {
    enable = true;
    dynamicConfigOptions = {
      http.middlewares.admin-auth.basicAuth = {
        users = [
          "fomm:$2y$10$pTwgKfyhMDMNldMbRJBklODLDwYYlWWYUBWcmlh0UOIfTR9AvjMWC"
        ];
      };
      http.middlewares.redirect-to-https.redirectscheme = {
        scheme = "https";
        permanent = true;
      };
      http = {
        routers = {
          traefik-dash-insecure = {
            service = "api@internal";
            entryPoints = [ "web" ];
            middlewares = [ "redirect-to-https" ];
            rule = "Host(`traefik.li.lab`)";
            priority = 22;
          };

          traefik-dash = {
            service = "api@internal";
            entryPoints = [ "websecure" ];
            middlewares = [ "admin-auth" ];
            rule = "Host(`traefik.li.lab`)";
            priority = 23;
          };
        };
      };
      tls.options.default.minVersion = "VersionTLS12";
    };

    staticConfigOptions = {
      api.dashboard = true;
      log.level = "INFO";

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
