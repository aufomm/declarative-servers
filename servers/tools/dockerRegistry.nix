{
  pkgs,
  ...
}:
# Need to check this
# https://github.com/input-output-hk/bitte/blob/c3b506c7b319b1f997eef629c4257bdc52bb2361/modules/docker-registry.nix#L136 
{
  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "0.0.0.0";
    storagePath = null; # We want to store in s3
    garbageCollectDates = "weekly";
    extraConfig = {
      # S3 Storages
      storage.s3 = {
        regionendpoint = "https://o.xirion.net";
        bucket = "docker-registry-proxy";
        region = "us-east-1"; # Fake but needed
      };

      # The actual proxy
      proxy.remoteurl = "https://registry-1.docker.io";

      # Enable prom under :5001/metrics
      http.debug.addr = "0.0.0.0:5001";
      http.debug.prometheus.enabled = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    5001
  ];
}
