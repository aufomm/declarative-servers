{
  imports = [
    ./service.nix
    ./postgres.nix
    ./sops.nix
    ./cloudflared.nix
  ];
  networking.hostName = "pskc";

  users.users.keycloak = {
    isSystemUser = true;
    group = "keycloak";
    description = "Keycloak service user";
  };

  users.groups.keycloak = { };
}
