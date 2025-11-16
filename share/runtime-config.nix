{
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
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
  
  services.journald = {
    extraConfig = ''
      SystemMaxUse=2G
      MaxRetentionSec=1month
    '';
  };
}
