{ pkgs, ... }:
let
  fluentbitVersion = "5.0.4";
  fluentbitConfigFile = pkgs.writeText "fluent-bit.conf" ''
    [SERVICE]
        Flush        1
        Log_Level    info

    [INPUT]
        Name         http
        Tag          kong_http_log
        Port         8888

    [OUTPUT]
        Name         opentelemetry
        Match        kong_http_log
        Host         otel-collector
        Port         4318
        Logs_uri     /v1/logs
        Log_response_payload true
        Tls          off
        logs_body_key $message
        logs_trace_id_message_key traceid
        logs_span_id_message_key  spanid
  '';
in
{
  virtualisation.oci-containers.containers.fluent-bit = {
    autoStart = true;
    image = "fluent/fluent-bit:${fluentbitVersion}";
    volumes = [
      "${fluentbitConfigFile}:/fluent-bit/etc/fluent-bit.conf:ro"
    ];
    extraOptions = [
      "--network=kong"
    ];
  };
}
