{ pkgs, ... }:

{
  # Power management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Thunderbolt device authorization
  services.hardware.bolt.enable = true;

  # AMD GPU
  hardware.amdgpu.opencl.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  # Framework fan control
  hardware.fw-fanctrl.enable = true;

  # Ambient light sensor (auto-brightness)
  hardware.sensor.iio.enable = true;

  # Firmware blobs
  hardware.enableRedistributableFirmware = true;

  # Ethernet expansion card — prevent USB autosuspend for Realtek RTL8156
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="-1"
  '';

  # SSD maintenance — fstrim not needed with discard=async in mount options
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # SMART disk health monitoring
  services.smartd.enable = true;

  # Framework laptop tools
  environment.systemPackages = with pkgs; [
    fw-ectool
    framework-tool
  ];
}
