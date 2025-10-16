{ config, pkgs, ... }:
let
  app = "minio";
  minioRootCredential = config.sops.secrets."minio-root-credential".path;
in
{
  services.minio = {
    enable = true;
    browser = true;
    region = "us-east-1";
    package = (pkgs.callPackage ./minio.nix { });
    rootCredentialsFile = "${minioRootCredential}";
  };

  systemd.services.minio = {
    environment = {
      MINIO_BROWSER_REDIRECT_URL = "http://${app}-console.li.lab:9001";
    };
  };
}
