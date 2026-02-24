{ config, ... }:

{
  assertions = [{
    assertion = config.networking.firewall.enable;
    message = "Firewall must be enabled on non-VM hosts";
  }];

  imports = [
    ./hardware.nix
    ./users.nix
  ];

  networking.hostName = "bolhao";

  # Bootloader — systemd-boot on shared EFI partition
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Plymouth — graphical LUKS unlock + boot splash
  boot.plymouth.enable = true;

  # AMD P-State driver for power management
  boot.kernelParams = [ "amd_pstate=active" "quiet" "loglevel=3" ];

  # CapsLock → hold: Ctrl, tap: Escape
  services.evremap = {
    enable = true;
    settings.device_name = "AT Translated Set 2 keyboard";
    settings.dual_role = [
      {
        input = "KEY_CAPSLOCK";
        hold = [ "KEY_LEFTCTRL" ];
        tap = [ "KEY_ESC" ];
      }
    ];
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  system.stateVersion = "24.11";
}
