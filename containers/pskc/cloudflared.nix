# https://olai.dev/blog/nix-cloudflare-tunnels/
{
  config,
  ...
}:
let
  hostname = "auth.konghqps.com";
  tunnelCreds = config.sops.secrets."cf/tunnel_creds".path;
in
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "psck" = {
        credentialsFile = "${tunnelCreds}";
        default = "http_status:404";
        ingress = {
          "${hostname}" = {
            service = "http://127.0.0.1:8080";
          };
        };
        originRequest = {
          noTLSVerify = true;
        };
      };
    };
  };
  services.openssh.settings.Macs = [
    # Current defaults:
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
    # Added:
    "hmac-sha2-256"
  ];
}
