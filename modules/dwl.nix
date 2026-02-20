{ pkgs, ... }:

let
  # dwl with custom config.h + community patches
  dwl-custom = (pkgs.dwl.override {
    configH = builtins.readFile ./dwl-config.h;
  }).overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./patches/pertag.patch
      ./patches/movestack.patch
      ./patches/focusdir.patch
      ./patches/warpcursor.patch
    ];
  });

  # Wrapper script to launch dwl with user autostart
  dwl-wrapped = pkgs.writeShellScriptBin "dwl-session" ''
    exec ${dwl-custom}/bin/dwl -s "$HOME/.config/dwl/autostart.sh"
  '';

  # Wayland session entry for GDM
  dwl-desktop = (pkgs.writeTextDir "share/wayland-sessions/dwl.desktop" ''
    [Desktop Entry]
    Name=dwl
    Comment=dwm for Wayland
    Exec=${dwl-wrapped}/bin/dwl-session
    Type=Application
    DesktopNames=dwl
  '').overrideAttrs (_: { passthru.providedSessions = [ "dwl" ]; });
in
{
  # Register dwl as a session in the display manager
  services.displayManager.sessionPackages = [ dwl-desktop ];

  # XDG Desktop Portal for wlroots compositors
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Electron / Chromium Wayland hint
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Polkit — needed for privilege escalation prompts
  security.polkit.enable = true;

  # System packages for dwl session
  environment.systemPackages = with pkgs; [
    dwl-custom
    kitty
    wmenu
    brightnessctl
    grim
    slurp
    swappy
    wl-clipboard
    swaylock
    swayidle
    waybar
    lm_sensors
    playerctl
    wlr-randr
    mako
    swaybg
    cliphist
    wlsunset
    networkmanagerapplet
    udiskie
    xfce.thunar
    xfce.tumbler
  ];

  # Trash / mount support for Thunar
  services.gvfs.enable = true;
}
