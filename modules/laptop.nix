{ ... }:

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
  hardware.graphics.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Firmware
  hardware.enableRedistributableFirmware = true;
}
