{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      bindkey '^w' forward-word
      bindkey '^b' backward-kill-word
      bindkey '^f' autosuggest-accept
    '';
  };

  home.username = "fomm";
  home.homeDirectory = "/home/fomm";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    openssl
  ];
}
