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

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    hyprpaper
  ];
}
