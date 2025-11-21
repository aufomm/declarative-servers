{ config, pkgs, ... }:
let
  cp_name = "lxc";
  cp_region = "au";
  redisIP = "192.168.3.100";
  vaultIP = "192.168.3.172";
  authIP = "192.168.3.100";
  rockProxyIP = "192.168.3.162";
  homeCA = config.sops.secrets."fomm_ca".path;
in
{
  systemd.services.init-kong-network = {
    description = "Create the network bridge for kong.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${pkgs.docker}/bin/docker network ls | grep "kong" || true)
      if [ -z "$check" ];
        then ${pkgs.docker}/bin/docker network create kong
        else echo "Network kong already exists in docker"
      fi
    '';
  };

  virtualisation.oci-containers.containers.kong = {
    autoStart = true;
    image = "kong/kong-gateway:3.12.0.1";
    hostname = "homelab-lxc";
    # KONG_VAULT_HCV_TOKEN is injected via env file from sops secrets
    environmentFiles = [
      config.sops.secrets."env".path
    ];
    volumes = [
      "${homeCA}:/cert/ca.pem:ro"
    ];
    environment = {
      KONG_LOG_LEVEL = "info";
      KONG_DATABASE = "off";
      KONG_ROLE = "data_plane";
      KONG_ANONYMOUS_REPORTS = "off";
      KONG_NGINX_WORKER_PROCESSES = "1";
      KONG_CLUSTER_MTLS = "pki";
      KONG_ROUTER_FLAVOR = "expressions";
      KONG_CLUSTER_CONTROL_PLANE = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/cluster_control_plane}";
      KONG_CLUSTER_SERVER_NAME = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/cluster_server_name}";
      KONG_CLUSTER_TELEMETRY_ENDPOINT = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/cluster_telemetry_endpoint}";
      KONG_CLUSTER_TELEMETRY_SERVER_NAME = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/cluster_telemetry_server_name}";
      KONG_CLUSTER_CERT = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/certificate}";
      KONG_CLUSTER_CERT_KEY = "{vault://hcv/${cp_region}/${cp_name}/cluster-config/private_key}";
      KONG_STATUS_LISTEN= "0.0.0.0:8100";
      KONG_PROXY_LISTEN = "0.0.0.0:8443 http2 ssl reuseport backlog=16384";
      KONG_KONNECT_MODE = "on";
      KONG_LUA_SSL_TRUSTED_CERTIFICATE = "system,/cert/ca.pem";
      KONG_TRACING_INSTRUMENTATIONS = "all";
      KONG_TRACING_SAMPLING_RATE = "1.0";
      KONG_TRUSTED_IPS="172.18.0.1";
      KONG_REAL_IP_HEADER="X-Forwarded-For";
      KONG_REAL_IP_RECURSIVE="on";
      KONG_VAULT_HCV_PROTOCOL="https";
      KONG_VAULT_HCV_HOST="vault.li.lab";
      KONG_VAULT_HCV_PORT="8200";
      KONG_VAULT_HCV_MOUNT="konnect";
      KONG_VAULT_HCV_KV="v2";
      KONG_VAULT_HCV_AUTH_METHOD="token";
    };
    extraOptions = [ 
      "--network=kong"
      "--add-host=redis.li.lab:${redisIP}"
      "--add-host=vault.li.lab:${vaultIP}"
      "--add-host=auth.li.lab:${authIP}"
      "--add-host=proxy.li.rock:${rockProxyIP}"
    ];
    ports = [
      "127.0.0.1:8443:8443/tcp"
    ];
  };
}
