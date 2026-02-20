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
      wlsunset -T 6500 -t 3500 -S 06:00 -s 20:00 &
      # Network tray applet
      nm-applet --indicator &
      # Auto-mount USB drives
      udiskie --automount --tray &
      # Idle management
      swayidle -w \
        timeout 300 'swaylock -f' \
        timeout 600 'wlr-randr --output eDP-1 --off' \
          resume 'wlr-randr --output eDP-1 --on' \
        before-sleep 'swaylock -f' &
      # Clipboard history
      wl-paste --type text --watch cliphist store &
      wl-paste --type image --watch cliphist store &
      # Status bar
      exec waybar
    '';
  };


  # ── Waybar config ────────────────────────────────────────────
  home.file.".config/waybar/config.jsonc".text = builtins.toJSON {
    layer = "top";
    position = "top";
    height = 24;
    spacing = 0;
    modules-left = [ "dwl/tags" "dwl/window#layout" "dwl/window" ];
    modules-right = [ "tray" "network" "wireplumber" "battery" "clock" ];

    "dwl/tags" = {
      num-tags = 9;
    };

    "dwl/window#layout" = {
      format = "{layout}";
    };

    "dwl/window" = {
      format = "{title}";
      max-length = 50;
    };

    tray = {
      spacing = 8;
    };

    network = {
      format-wifi = "󰤨 {essid}";
      format-ethernet = "󰈀 Wired";
      format-disconnected = "󰤭 Off";
      tooltip-format = "{ifname}: {ipaddr}/{cidr}";
    };

    wireplumber = {
      format = "{icon} {volume}%";
      format-muted = "󰝟 Mute";
      format-icons = [ "󰖀" "󰕾" ];
    };

    battery = {
      states = {
        warning = 30;
        critical = 10;
      };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-icons = [ "󰂃" "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
    };

    clock = {
      format = "󰥔 {:%a %b %d  %H:%M}";
    };
  };

  home.file.".config/waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
      min-height: 0;
      border: none;
      border-radius: 0;
    }

    window#waybar {
      background-color: #005577;
      color: #eeeeee;
    }

    #tags button {
      padding: 0 5px;
      background: transparent;
      color: #bbbbbb;
      border-bottom: 2px solid transparent;
    }

    #tags button.occupied {
      color: #eeeeee;
    }

    #tags button.focused {
      color: #ffffff;
      background-color: #004466;
      border-bottom: 2px solid #ffffff;
    }

    #tags button.urgent {
      color: #ff6666;
    }

    #window.layout {
      padding: 0 8px;
      color: #ffffff;
    }

    #window {
      padding: 0 8px;
      color: #bbbbbb;
    }

    #tray,
    #network,
    #wireplumber,
    #battery,
    #clock {
      padding: 0 8px;
      color: #eeeeee;
    }

    #battery.warning {
      color: #ffaa00;
    }

    #battery.critical {
      color: #ff6666;
    }
  '';

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
