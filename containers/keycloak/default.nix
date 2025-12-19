{
  imports = [
    ./service.nix
    ./postgres.nix
    ./sops.nix
    ./acme.nix
  ];
  networking.hostName = "keycloak";

  users.users.keycloak = {
    isSystemUser = true;
    group = "keycloak";
    extraGroups = [ "nginx" ];
    description = "Keycloak service user";
  };

  users.groups.keycloak = { };
}
