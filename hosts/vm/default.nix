{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  networking.hostName = "nixos-vm";

  # VM-specific user (simple password for convenience)
  users.users.resende = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    initialPassword = "vm";
  };
  programs.fish.enable = true;

  # VM resources — qemu-vm.nix handles boot, filesystems, and QEMU flags
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    graphics = true;
  };

  # Disable firewall in VM (easy access, NAT networking)
  networking.firewall.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";
}
