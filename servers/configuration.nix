{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./ca.nix
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.fomm = ./home.nix;
    backupFileExtension = "backup";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      warn-dirty = false;
      auto-optimise-store = true;
      download-buffer-size = 128 * 1024 * 1024; # 128 MiB
      trusted-users = [ "fomm" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

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

  programs.zsh = {
    enable = true;
  };

  system.stateVersion = "25.05";
  services.journald = {
    extraConfig = ''
      SystemMaxUse=2G
      MaxRetentionSec=1month
    '';
  };
}
