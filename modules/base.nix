{ pkgs, ... }:

{
  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "resende" ];
      keep-outputs = true;
      keep-derivations = true;

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Locale
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved"; # Use systemd-resolved for DNS-over-TLS
  };

  # Mullvad VPN
  services.mullvad-vpn.enable = true;

  # Swap — zram with tuned kernel params
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    memoryPercent = 50;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # direnv + nix-direnv — per-project dev environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Podman with Docker compatibility
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # System packages — only universally needed tools
  # Language runtimes/build tools go in per-project devShells (see templates/)
  environment.systemPackages = with pkgs; [
    # Core
    vim
    git
    curl
    wget

    # CLI tools
    fd
    jq
    htop
    btop
    nvtopPackages.amd
    tree
    unzip
    wl-clipboard
    strace

    # Build essentials (needed by too many things)
    gcc
    gnumake
    cmake

    # GNOME extras
    gnome-tweaks
    gnome-extension-manager

    # Fonts
    nerd-fonts.jetbrains-mono
    source-sans-pro
    source-serif-pro
    noto-fonts-color-emoji
  ];

  # Font configuration — optimized for Framework's high-DPI display
  fonts = {
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "Source Serif Pro" ];
        sansSerif = [ "Source Sans Pro" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
      hinting.enable = false; # better on high-DPI
    };
  };

  # Printing (CUPS)
  services.printing.enable = true;

  # Geolocation — enables GNOME weather, auto-timezone
  services.geoclue2.enable = true;
}
