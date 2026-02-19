{ pkgs, ... }:

{
  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Locale
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # SSD maintenance
  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  # Swap
  zramSwap.enable = true;

  # Base packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];
}
