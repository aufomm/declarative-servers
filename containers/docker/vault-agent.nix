{ config, pkgs, ... }:
let
  clusterConfig = "konnect/data/au/lxc/cluster-config";
  vaultAppRoleId = config.sops.secrets."vault-agent/approle_id".path;
  vaultAppRoleSecret = config.sops.secrets."vault-agent/approle_secret".path;
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/vault-agent 0750 root root -"
    "d /var/lib/vault-agent/kong 0750 root root -"
  ];

  services.vault-agent.instances.kong-vault-watcher = {
    enable = true;

    settings = {
      vault.address = "https://vault.li.lab:8200";

      auto_auth = {
        method = [
          {
            type = "approle";
            config = {
              role_id_file_path = vaultAppRoleId;
              secret_id_file_path = vaultAppRoleSecret;
              remove_secret_id_file_after_reading = false;
            };
          }
        ];
        sink = [
          {
            type = "file";
            config = {
              path = "/var/lib/vault-agent/token";
              mode = 0640;
            };
          }
        ];
      };
      template_config = {
        static_secret_render_interval = "1d";
      };
      template = [
        {
          destination = "/var/lib/vault-agent/kong/cluster-certificate.pem";

          contents = ''
            {{ with secret "${clusterConfig}" }}
            {{ .Data.data.certificate }}
            {{ end }}
          '';

          command = "${pkgs.systemd}/bin/systemctl try-restart docker-kong.service";
          
          wait = {
            min = "5s";
            max = "30s";
          };
        }
      ];
    };
  };
}
