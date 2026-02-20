{ config, lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  # ── dwl autostart script ──────────────────────────────────────
  home.file.".config/dwl/autostart.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Polkit authentication agent
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      # Notification daemon
      mako &
      # Wallpaper (picks a random image from ~/Pictures/Wallpapers)
      swaybg -m fill -i "$(find "$HOME/Pictures/Wallpapers" -type f | shuf -n 1)" &
      # Night light (warm colors at night)
      wlsunset -T 6500 -t 3500 &
      # Network tray applet
      nm-applet --indicator &
      # Auto-mount USB drives
      udiskie --automount --tray &
      # Status bar
      waybar &
      # Idle management
      swayidle -w \
        timeout 300 'swaylock -f' \
        timeout 600 'wlr-randr --output eDP-1 --off' \
          resume 'wlr-randr --output eDP-1 --on' \
        before-sleep 'swaylock -f' &
      # Clipboard history
      wl-paste --type text --watch cliphist store &
      wl-paste --type image --watch cliphist store &
    '';
  };

  # ── Waybar (status bar) ───────────────────────────────────────
  programs.waybar = {
    enable = true;
    style = ''
      #tags button {
        background: transparent;
        border: none;
        color: #585b70;
        padding: 0 6px;
      }

      #tags button.occupied {
        color: #cdd6f4;
      }

      #tags button.focused {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }

      #tags button.urgent {
        color: #f38ba8;
      }

      #battery.critical {
        background-color: #ff0000;
        color: #ffffff;
        font-weight: bold;
        font-size: 16px;
        padding: 0 12px;
        border-radius: 4px;
        animation: blink 1s infinite;
      }

      @keyframes blink {
        50% { background-color: #990000; }
      }

      #battery.warning {
        color: #f9e2af;
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "dwl/tags" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "battery" "network" "tray" ];

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%a %d %b %Y}";
          tooltip-format = "{:%A, %B %d, %Y}";
        };

        battery = {
          states = {
            warning = 30;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-critical = "  {capacity}% LOW BATTERY";
          format-icons = [ "" "" "" "" "" ];
          interval = 10;
        };

        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = " {ipaddr}";
          format-disconnected = "Disconnected";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "Muted";
          format-icons = { default = [ "" "" "" ]; };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        tray = {
          spacing = 10;
        };
      };
    };
  };

  # ── Cursor theme ─────────────────────────────────────────────
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # ── GTK theme ───────────────────────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # ── Mako (notifications) ───────────────────────────────────
  home.file.".config/mako/config".text = ''
    default-timeout=5000
    border-size=2
    border-radius=5
    background-color=#1e1e2eff
    text-color=#cdd6f4ff
    border-color=#89b4faff
    font=JetBrainsMono Nerd Font 10
    width=350
    margin=10
    padding=10
  '';

  # ── Swaylock (screen locker) ──────────────────────────────────
  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      font = "JetBrainsMono Nerd Font";
      indicator-radius = 100;
      indicator-thickness = 7;
      inside-color = "1e1e2e";
      key-hl-color = "89b4fa";
      ring-color = "45475a";
      ring-ver-color = "89b4fa";
      text-color = "cdd6f4";
      show-failed-attempts = true;
    };
  };
}
