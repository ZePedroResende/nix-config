# Hardware configuration for Framework 13 (AMD AI 300)
# Dual-boot with Fedora — shares /home and EFI partition
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

  # LUKS encryption — reuses Fedora's LUKS partition
  # NixOS names its own mapper "nixos-crypt" (only used when NixOS boots)
  boot.initrd.luks.devices."nixos-crypt" = {
    device = "/dev/disk/by-uuid/a73321fc-3b59-4b4c-9c79-deefc97c2d05";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  # Btrfs subvolumes on LUKS (created by scripts/install.sh)
  fileSystems."/" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@nixos" "compress=zstd:1" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=@nix-store" "compress=zstd:1" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  # Shared /home — uses Fedora's existing "home" subvolume
  fileSystems."/home" = {
    device = "/dev/mapper/nixos-crypt";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd:1" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  # Shared EFI partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1AB0-FB2C";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # No btrfs swap subvolume — zram swap is configured in base.nix

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
