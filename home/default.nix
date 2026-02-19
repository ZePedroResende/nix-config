{ ... }:

{
  imports = [
    ./desktop.nix
    ./terminal.nix
    ./editors.nix
    ./git.nix
    ./cli.nix
  ];

  home.username = "resende";
  home.homeDirectory = "/home/resende";
  home.stateVersion = "24.11";
}
