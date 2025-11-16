{
  imports = [
    ./service.nix
    ./postgres.nix
    ./sops.nix
  ];
  networking.hostName = "keycloak";

  users.users.keycloak = {
    isSystemUser = true;
    group = "keycloak";
    description = "Keycloak service user";
  };

  users.groups.keycloak = { };
}
