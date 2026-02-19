# Hardware configuration for Framework 13 (AMD AI 300)
# LUKS UUID is a placeholder — replace after partitioning in Phase 2.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Latest kernel for AMD Strix Point (Ryzen AI 9 HX 370) support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];

  # Systemd initrd — required for Plymouth to render LUKS password prompt
  boot.initrd.systemd.enable = true;
  boot.kernelModules = [ "kvm-amd" ];

  # LUKS encryption — replace UUID after creating partition in Phase 2
  boot.initrd.luks.devices."nixos-crypt" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-LUKS-UUID";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  # Btrfs subvolumes on LUKS
  fileSystems."/" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "ssd" "discard=async" "space_cache=v2" "noatime" ];
  };

  fileSystems."/.swapvol" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  # Shared EFI partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1AB0-FB2C";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
