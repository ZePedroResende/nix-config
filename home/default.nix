{ lib, pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./terminal.nix
    ./editors.nix
    ./git.nix
    ./cli.nix
  ];

  home.username = "resende";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/resende"
    else "/home/resende";
  home.stateVersion = "24.11";
}
