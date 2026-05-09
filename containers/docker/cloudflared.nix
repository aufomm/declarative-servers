# https://olai.dev/blog/nix-cloudflare-tunnels/
{
  config,
  ...
}:
let
  hostname = "jwt.fomm.dev";
  tunnelCreds = config.sops.secrets."cf/tunnel_creds".path;
in
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "jwt-inspector" = {
        credentialsFile = "${tunnelCreds}";
        default = "http_status:404";
        ingress = {
          "${hostname}" = {
            service = "http://127.0.0.1:3000";
          };
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
  # Increase UDP buffer sizes to satisfy cloudflared's requirements. See https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 7500000; # 7.5 MB
    "net.core.wmem_max" = 7500000; # 7.5 MB
  };
}
