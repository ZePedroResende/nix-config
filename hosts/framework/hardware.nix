# Hardware configuration for Framework 13 (AMD AI 300)
# Filesystem UUIDs are placeholders — replace after partitioning in Phase 2.
{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];

  # LUKS encryption — replace device UUID after creating partition
  boot.initrd.luks.devices."nixos-crypt" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-LUKS-UUID";
    allowDiscards = true;
  };

  # Btrfs subvolumes on LUKS — replace UUIDs after formatting
  fileSystems."/" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/.swapvol" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  # Shared EFI partition — replace UUID after verifying
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1AB0-FB2C";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
