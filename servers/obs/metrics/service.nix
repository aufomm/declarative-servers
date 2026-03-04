{ ... }:
{
  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:8428";
    prometheusConfig = {
      scrape_configs = [
        {
          job_name = "nodes";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "192.168.3.100:9100" ];
              labels = {
                type = "vm";
                instance = "tools";
              };
            }
            {
              targets = [ "192.168.3.200:9100" ];
              labels = {
                type = "vm";
                instance = "bastion";
              };
            }
            {
              targets = [ "192.168.3.150:9100" ];
              labels = {
                type = "vm";
                instance = "mesh-universal";
              };
            }
            {
              targets = [ "192.168.3.162:9100" ];
              labels = {
                type = "sbc";
                instance = "rockpi";
              };
            }
            {
              targets = [ "192.168.3.171:9100" ];
              labels = {
                type = "lxc";
                instance = "vault";
              };
            }
            {
              targets = [ "192.168.3.172:9100" ];
              labels = {
                type = "lxc";
                instance = "vault";
              };
            }
            {
              targets = [ "192.168.3.173:9100" ];
              labels = {
                type = "lxc";
                instance = "keycloak";
              };
            }
            {
              targets = [ "192.168.3.174:9100" ];
              labels = {
                type = "lxc";
                instance = "kong-lxc";
              };
            }
            {
              targets = [ "192.168.3.175:9100" ];
              labels = {
                type = "lxc";
                instance = "garage";
              };
            }
            {
              targets = [ "127.0.0.1:9100" ];              
              labels = {
                type = "lxc";
                instance = "obs";
              };
            }
          ];
        }
        {
          job_name = "obs-apps";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:9428" ];
              labels = {
                type = "logs";
              };
            }
            {
              targets = [ "127.0.0.1:8428" ];
              labels = {
                type = "metrics";
              };
            }
            {
              targets = [ "127.0.0.1:10428" ];
              labels = {
                type = "traces";
              };
            }
          ];
        }
      ];
    };
  };
}
