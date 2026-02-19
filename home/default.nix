{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  # Shell
  programs.fish.enable = true;

  # Terminal tools
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;

  # User packages
  home.packages = with pkgs; [
    firefox
    fd
    jq
    unzip
  ];
}
