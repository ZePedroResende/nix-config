{ pkgs, ... }:

{
  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME udev rules
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Remove GNOME bloat
  environment.gnome.excludePackages = with pkgs; [
    epiphany        # web browser
    geary           # email client
    gnome-music     # music player (use spotify-player)
    gnome-tour      # welcome tour
    gnome-contacts  # contacts
    gnome-maps      # maps
    totem           # video player
    yelp            # help viewer
    simple-scan     # scanner
  ];

  # Audio — PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
