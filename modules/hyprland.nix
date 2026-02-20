{ pkgs, ... }:

{
  # Hyprland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # XDG Desktop Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Electron / Chromium Wayland hint
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Polkit — needed for privilege escalation prompts
  security.polkit.enable = true;

  # System packages for Hyprland session
  environment.systemPackages = with pkgs; [
    brightnessctl
    grim
    slurp
    swappy
    wl-clipboard
    hyprlock
    hypridle
    hyprpaper
    cliphist
    lm_sensors
    playerctl
  ];
}
