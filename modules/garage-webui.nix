{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.garage-webui;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in {
  options.services.garage-webui = {
    enable = mkEnableOption "garage-webui";
    package = lib.mkPackageOption pkgs "garage-webui" { };

    waitForServices = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of services that garage-webui should wait for before starting.
        This allows proper dependency management for services like garage.
      '';
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the default port in the firewall";
    };
    port = mkOption {
      type = types.port;
      default = 3909;
      description = "The port for garage-webui to listen";
    };



    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/garage-webui.env";
      description = ''
        Path to a file containing environment variables for garage-webui.

        IMPORTANT: Variables in this file take precedence over the corresponding module options.
        However, if a variable is NOT defined in environmentFile, the module option value will be used.

        Example:
        - If you set `s3EndpointUrl = "http://foo"` in the module config
        - And environmentFile contains `S3_ENDPOINT_URL=http://bar`
        - Result: `http://bar` is used (environmentFile wins)

        - If you set `s3EndpointUrl = "http://foo"` in the module config
        - And environmentFile does NOT contain `S3_ENDPOINT_URL`
        - Result: `http://foo` is used (module option is used)

        This is useful for:
        - Storing secrets (API_ADMIN_KEY, AUTH_USER_PASS)
        - Overriding specific config at runtime without rebuilding
        - Managing secrets via sops-nix, agenix, or systemd credentials

        Available variables:
          API_ADMIN_KEY=your-admin-key-here
          AUTH_USER_PASS=username:$2y$10$hashedpassword
          API_BASE_URL=http://127.0.0.1:3903
          S3_REGION=us-east-1
          S3_ENDPOINT_URL=http://127.0.0.1:3900
          BASE_PATH=/garage
      '';
    };
    basePath = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/garage";
      description = ''
        Base path or prefix for the Web UI.

        Environment variable: BASE_PATH
      '';
    };
    apiBaseUrl = mkOption {
      type = types.nullOr types.str;
      default = "http://127.0.0.1:3903";
      example = "http://127.0.0.1:3903";
      description = ''
        Garage admin API endpoint URL.

        Environment variable: API_BASE_URL
        Default: "http://127.0.0.1:3903" (Garage's default admin port)
      '';
    };
    apiAdminKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Garage admin API key.

        WARNING: This value will be stored in the Nix store and is world-readable.
        For production, use `environmentFile` instead to store this securely.

        Environment variable: API_ADMIN_KEY
      '';
    };
    s3Region = mkOption {
      type = types.nullOr types.str;
      default = "us-east-1";
      example = "us-east-1";
      description = ''
        S3 Region.

        Environment variable: S3_REGION
      '';
    };
    s3EndpointUrl = mkOption {
      type = types.nullOr types.str;
      default = "http://127.0.0.1:3900";
      example = "http://127.0.0.1:3900";
      description = ''
        S3 Endpoint URL.

        Environment variable: S3_ENDPOINT_URL
        Default: "http://127.0.0.1:3900" (Garage's default S3 API port)
      '';
    };
    authUserPass = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "username:$2y$10$kdiv4rdKoAjMpOj5/91LmebEnHwE6FEkRJUf28SrzUi8jHGELQEbm";
      description = ''
        Enable authentication in the format `username:password_hash`.
        The password_hash must be a bcrypt hash.

        WARNING: This value will be stored in the Nix store and is world-readable.
        For production, use `environmentFile` instead to store this securely.

        To generate the password hash:
        ```bash
        nix shell nixpkgs/nixpkgs-unstable#apacheHttpd
        htpasswd -nbBC 10 "yourusername" "your-password" | tr -d '\n'
        # Output: yourusername:$2y$10$hashedpassword
        ```

        Environment variable: AUTH_USER_PASS
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.garage-webui = {
      description = "Garage Web UI";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"] ++ cfg.waitForServices;
      after = ["network-online.target"] ++ cfg.waitForServices;

      environment =
        {
          PORT = toString cfg.port;
        }
        // lib.optionalAttrs (cfg.basePath != null) { BASE_PATH = cfg.basePath; }
        // lib.optionalAttrs (cfg.apiBaseUrl != null) { API_BASE_URL = cfg.apiBaseUrl; }
        // lib.optionalAttrs (cfg.apiAdminKey != null) { API_ADMIN_KEY = cfg.apiAdminKey; }
        // lib.optionalAttrs (cfg.s3Region != null) { S3_REGION = cfg.s3Region; }
        // lib.optionalAttrs (cfg.s3EndpointUrl != null) { S3_ENDPOINT_URL = cfg.s3EndpointUrl; }
        // lib.optionalAttrs (cfg.authUserPass != null) { AUTH_USER_PASS = cfg.authUserPass; };

      serviceConfig = {
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package}";
        Type = "simple";

        # Dynamic user for security
        DynamicUser = true;
        StateDirectory = "garage-webui";
        WorkingDirectory = "/var/lib/garage-webui";

        # Basic security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = ["/var/lib/garage-webui"];

        # Network capabilities (only bind privileged ports if needed)
        AmbientCapabilities = lib.optionals (cfg.port < 1024) ["CAP_NET_BIND_SERVICE"];

        # Restart policy
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];
  };
}
