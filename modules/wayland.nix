{ pkgs, ... }:

{
  # Electron / Chromium Wayland hint
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  # Polkit — needed for privilege escalation prompts
  security.polkit.enable = true;

  # Shared packages for all Wayland compositors
  environment.systemPackages = with pkgs; [
    brightnessctl
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    lm_sensors
    playerctl
  ];
}
