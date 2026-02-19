{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  networking.hostName = "bolhao";

  # Bootloader — systemd-boot on shared EFI partition
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    timeout = 5;
  };

  # User account
  users.users.resende = {
    isNormalUser = true;
    description = "resende";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  system.stateVersion = "24.11";
}
