{ config, pkgs, ... }:
let
  homeCA = config.sops.secrets."fomm_ca".path;
  obsClientId = config.sops.secrets."obs/client_id".path;
  obsClientSecret = config.sops.secrets."obs/client_secret".path;
  authIP = "192.168.3.173";
  obsIP = "192.168.3.180";
  otelVersion = "0.144.0";
  otelConfigFile = pkgs.writeText "otel-config.yaml" ''
    extensions:
      oauth2client:
        client_id_file: /etc/oauth2/client_id
        client_secret_file: /etc/oauth2/client_secret
        token_url: https://auth.li.lab/realms/obs/protocol/openid-connect/token
        tls:
          insecure: false
          ca_file: /etc/certs/ca.pem
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      prometheus:
        config:
          scrape_configs:
            - job_name: "kong-gateway"
              scrape_interval: 5s
              static_configs:
                - targets: ["kong:8100"]
            - job_name: "otel-collector"
              scrape_interval: 5s
              static_configs:
                - targets: ["0.0.0.0:8888"]
    processors:
      transform/metrics:
        error_mode: ignore
        metric_statements:
          - context: resource
            conditions:
              - attributes["instance"] == nil
            statements:
              - set(attributes["instance"], Concat(["lxc-docker", attributes["service.instance.id"]], "-"))
      transform/logs:
        log_statements:
          - context: log
            conditions:
              - IsMap(body)
            statements:
              - set(attributes["_msg"], String(body))
      resource/add_labels:
        attributes:
          - key: job
            from_attribute: "service.name"
            action: upsert
      resource/logs:
        attributes:
          - action: upsert
            key: service.name
            value: lxc-docker
      memory_limiter:
        check_interval: 1s
        limit_percentage: 80
        spike_limit_percentage: 15
      batch:
    exporters:
      otlp/lab:
        endpoint: obs.li.lab:4317
        tls:
          insecure: false
          ca_file: /etc/certs/ca.pem
        auth:
          authenticator: oauth2client
    service:
      extensions:
        - oauth2client
      telemetry:
        metrics:
          readers:
            - pull:
                exporter:
                  prometheus:
                    host: "0.0.0.0"
                    port: 8888
      pipelines:
        logs:
          receivers:
            - otlp
          processors:
            - memory_limiter
            - resource/logs
            - transform/logs
            - batch
          exporters:
            - otlp/lab
        metrics:
          receivers:
            - prometheus
          processors:
            - memory_limiter
            - resource/add_labels
            - transform/metrics
            - batch
          exporters:
            - otlp/lab
        traces:
          receivers:
            - otlp
          processors:
            - memory_limiter
            - batch
          exporters:
            - otlp/lab
  '';
in
{
  virtualisation.oci-containers.containers.otel-collector = {
    autoStart = true;
    image = "otel/opentelemetry-collector-contrib:${otelVersion}";
    volumes = [
      "${homeCA}:/etc/certs/ca.pem:ro"
      "${otelConfigFile}:/etc/otelcol-contrib/config.yaml:ro"
      "${obsClientId}:/etc/oauth2/client_id:ro"
      "${obsClientSecret}:/etc/oauth2/client_secret:ro"
    ];
    extraOptions = [
      "--network=kong"
      "--add-host=auth.li.lab:${authIP}"
      "--add-host=obs.li.lab:${obsIP}"
    ];
  };
}
