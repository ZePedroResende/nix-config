{ lib, pkgs, ... }:

{
  imports = [
    ./terminal.nix
    ./editors.nix
    ./git.nix
    ./cli.nix
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    ./desktop.nix
  ];

  home.username = "resende";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/resende"
    else "/home/resende";
  home.stateVersion = "24.11";
}
