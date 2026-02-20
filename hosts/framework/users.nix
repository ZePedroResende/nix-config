{ pkgs, ... }:

{
  users.users.root.hashedPassword = "!"; # disable root login

  users.users.resende = {
    isNormalUser = true;
    description = "resende";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.fish;
    initialPassword = "nixos"; # Change immediately after first login!
  };

  programs.fish.enable = true;
}
