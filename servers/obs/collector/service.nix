{
  config,
  pkgs,
  lib,
  stdenv,
  ...
}:
let
  hostname = "obs.li.lab";
  acmeCertDir = config.security.acme.certs."${hostname}".directory;
  authCert = config.sops.secrets."auth_cert".path;
  sslCert = "${acmeCertDir}/fullchain.pem";
  sslCertKey = "${acmeCertDir}/key.pem";
  homeCA = config.sops.secrets."fomm_ca".path;
  otelcol-contrib =
    (import ../../../share/pkgs/opentelemetry-collector {
      inherit (pkgs)
        pkgs
        lib
        buildGoModule
        fetchFromGitHub
        installShellFiles
        stdenv
        go
        git
        cacert
        ;
    }).otelcol-contrib;
in
{
  networking.firewall.allowedTCPPorts = [
    4317
    4318
  ];

  systemd.services.opentelemetry-collector = {
    serviceConfig.SupplementaryGroups = [
      # allow to read acme certificates for opentelemetry-collector
      "nginx"
    ];
  };

  services.opentelemetry-collector = {
    enable = true;
    package = otelcol-contrib;
    settings = {
      extensions = {
        "oidc/obs" = {
          # The version on nixpkgs used an old format as below
          ####################################################
          # issuer_url = "https://auth.li.lab/realms/obs";
          # issuer_ca_path = authCert;
          # audience = "collector";
          # username_claim = "azp";
          ####################################################
          providers = [
            {
              issuer_url = "https://auth.li.lab/realms/obs";
              issuer_ca_path = homeCA;
              audience = "collector";
              username_claim = "azp";
            }
          ];
        };
      };
      receivers = {
        otlp = {
          protocols = {
            grpc = {
              auth.authenticator = "oidc/obs";
              endpoint = "0.0.0.0:4317";
              tls = {
                cert_file = sslCert;
                key_file = sslCertKey;
                ca_file = homeCA;
              };
            };
            http = {
              auth.authenticator = "oidc/obs";
              endpoint = "0.0.0.0:4318";
              tls = {
                cert_file = sslCert;
                key_file = sslCertKey;
                ca_file = homeCA;
              };
            };
          };
        };
      };

      processors = {
        memory_limiter = {
          check_interval = "5s";
          limit_percentage = 80;
          spike_limit_percentage = 15;
        };
        batch = {
          timeout = "5s";
          send_batch_size = 100000;
        };
        "resource/auth" = {
          attributes = [
            {
              key = "lab_env";
              from_context = "auth.subject";
              action = "upsert";
            }
          ];
        };
      };

      exporters = {
        "otlphttp/victorialogs" = {
          logs_endpoint = "http://127.0.0.1:9428/insert/opentelemetry/v1/logs";
          # VictoriaLogs header support https://docs.victoriametrics.com/victorialogs/data-ingestion/#http-headers
          # headers = {
          #   "VL-Msg-Field" = "body";
          # };
        };
        "otlphttp/victoriametrics" = {
          compression = "gzip";
          encoding = "proto";
          endpoint = "http://127.0.0.1:8428/opentelemetry";
        };
        "otlphttp/victoriatraces" = {
          traces_endpoint = "http://127.0.0.1:10428/insert/opentelemetry/v1/traces";
          # Victoriatraces header support https://docs.victoriametrics.com/victoriatraces/data-ingestion/#http-headers
          # headers = {
          #   "VL-Ignore-Fields" = "foo,bar";
          # };
        };
      };

      service = {
        extensions = [ "oidc/obs" ];
        pipelines = {
          logs = {
            receivers = [ "otlp" ];
            processors = [
              "memory_limiter"
              "resource/auth"
              "batch"
            ];
            exporters = [ "otlphttp/victorialogs" ];
          };
          metrics = {
            receivers = [ "otlp" ];
            processors = [
              "memory_limiter"
              "resource/auth"
              "batch"
            ];
            exporters = [ "otlphttp/victoriametrics" ];
          };
          traces = {
            receivers = [ "otlp" ];
            processors = [
              "memory_limiter"
              "resource/auth"
              "batch"
            ];
            exporters = [ "otlphttp/victoriatraces" ];
          };
        };
      };
    };
  };
}
