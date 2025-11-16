{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./ca.nix
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.fomm = ./home.nix;
    backupFileExtension = "backup";
  };

  users.users.fomm = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAKe2Dv58MInaZ9oy7R5m6OIgVDsYPIxWbTDtYPH0m3 pve"
    ];
  };

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "fomm" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.zsh.enable = true;
  system.stateVersion = "25.05";
}
