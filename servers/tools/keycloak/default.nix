{
  imports = [
    ./service.nix
    ./sops.nix
    # ./traefik.nix
  ];

  users.users.keycloak = {
    isSystemUser = true;
    group = "keycloak";
    description = "Keycloak service user";
  };

  users.groups.keycloak = { };
}
