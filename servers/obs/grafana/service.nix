{ pkgs, config, ... }:
let
  domain = "grafana.li.lab";
  homeCA = config.sops.secrets."fomm_ca".path;
  client_secret = config.sops.secrets."grafana/client_secret".path;
  secretKey = config.sops.secrets."grafana/secret_key".path;
in
{
  systemd.services.nginx.serviceConfig.SupplementaryGroups = [
    "grafana"
  ];

  services.grafana = {
    enable = true;
    provision.enable = true;
    declarativePlugins = [
      pkgs.grafanaPlugins.victoriametrics-metrics-datasource
      pkgs.grafanaPlugins.victoriametrics-logs-datasource
    ];
    settings = {
      server = {
        inherit domain;
        root_url = "https://${domain}";
      };
      auth = {
        disable_login_form = true;
        disable_signout_menu = true;
      };
      "auth.basic".enabled = false;
      "auth.generic_oauth" = {
        name = "Keycloak";
        enabled = true;
        allow_sign_up = true;
        client_id = "grafana";
        client_secret = "$__file{${client_secret}}";
        scopes = "openid offline_access profile email";
        auth_url = "https://auth.li.lab/realms/terraform/protocol/openid-connect/auth";
        token_url = "https://auth.li.lab/realms/terraform/protocol/openid-connect/token";
        api_url = "https://auth.li.lab/realms/terraform/protocol/openid-connect/token/introspect";
        signout_redirect_url = "https://auth.li.lab/realms/terraform/protocol/openid-connect/logout?post_logout_redirect_uri=https%3A%2F%2${domain}%2Flogin";
        role_attribute_strict = true;
        role_attribute_path = "contains(roles[*], 'grafanaadmin') && 'GrafanaAdmin'";
        allow_assign_grafana_admin = true;
        skip_org_role_sync = false;
        tls_client_ca = homeCA;
        use_refresh_token = true;
      };
      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
      security.secret_key = "$__file{${secretKey}}";
    };
  };
}
