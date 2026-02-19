{ config, pkgs, inputs, ... }:

{
  # ── XDG directories ──────────────────────────────────────────
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };

  # ── GNOME settings (dconf) ────────────────────────────────────
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      show-battery-percentage = true;
      clock-show-weekday = true;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };
    # Super+Return → kitty
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "kitty";
      name = "Terminal";
    };
  };

  # ── Apps ─────────────────────────────────────────────────────
  home.packages = with pkgs; [
    firefox
    google-chrome
    librewolf
    slack
    bitwarden
    spotify-player

    # Foundry (forge, cast, anvil, chisel)
    foundry-bin

    # Claude Code (native binary + sandbox deps)
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    bubblewrap
    socat
  ];
}
