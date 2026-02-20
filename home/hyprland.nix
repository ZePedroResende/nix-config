{ config, lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  # ── Hyprland window manager ────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # using UWSM instead

    settings = {
      # ── Variables ──────────────────────────────────────────────
      "$mod" = "SUPER";
      "$terminal" = "kitty";

      # ── Monitor ────────────────────────────────────────────────
      monitor = [ ", preferred, auto, auto" ];

      # ── Input ──────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
        };
        sensitivity = 0;
      };

      # ── General ────────────────────────────────────────────────
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(89b4fa) rgb(cba6f7) 45deg";
        "col.inactive_border" = "rgb(45475a)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # ── Decoration ─────────────────────────────────────────────
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "rgba(1a1a2eee)";
        };
      };

      # ── Animations ─────────────────────────────────────────────
      animations = {
        enabled = true;
        bezier = [
          "ease, 0.25, 0.1, 0.25, 1"
          "easeOut, 0, 0, 0.58, 1"
          "easeInOut, 0.42, 0, 0.58, 1"
        ];
        animation = [
          "windows, 1, 4, ease, slide"
          "windowsOut, 1, 4, easeOut, slide"
          "fade, 1, 4, ease"
          "workspaces, 1, 3, easeInOut, slide"
          "border, 1, 5, ease"
        ];
      };

      # ── Layout ─────────────────────────────────────────────────
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      # ── Startup ────────────────────────────────────────────────
      exec-once = [
        "systemctl --user start graphical-session.target"
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # ── Key bindings (i3-familiar) ─────────────────────────────
      bind = [
        # Launch
        "$mod, Return, exec, $terminal"
        "$mod, d, exec, caelestia shell drawers toggle launcher"
        "$mod, period, exec, caelestia toggle launcher emoji"

        # Window management
        "$mod SHIFT, q, killactive"
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, space, togglefloating"
        "$mod, p, pseudo"
        "$mod, v, togglesplit"

        # Focus (vim-style / i3-style)
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Move windows
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Special workspace (scratchpad)
        "$mod, s, togglespecialworkspace, magic"
        "$mod SHIFT, s, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Session
        "$mod, Escape, exec, hyprlock"
        "$mod SHIFT, e, exit"
        "$mod SHIFT, c, exec, hyprctl reload"

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, Print, exec, grim - | swappy -f -"

        # Clipboard history
        "$mod SHIFT, v, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # Resize submap
        "$mod, r, submap, resize"
      ];

      # Volume / brightness (repeatable)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Mute / play-pause (locked)
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ── Window rules ───────────────────────────────────────────
      windowrule = [
        "float on, match:class ^(pavucontrol)$"
        "float on, match:class ^(nm-connection-editor)$"
        "float on, match:class ^(blueman-manager)$"
        "float on, match:class ^(org.gnome.Nautilus)$, match:title ^(.*Properties.*)$"
        "float on, match:title ^(Open File)$"
        "float on, match:title ^(Save As)$"
        "float on, match:title ^(Open Folder)$"
        "float on, match:class ^(xdg-desktop-portal-gtk)$"
        "opacity 0.92 0.88, match:class ^(kitty)$"
      ];
    };

    # Resize submap
    extraConfig = ''
      submap = resize
      binde = , h, resizeactive, -20 0
      binde = , l, resizeactive, 20 0
      binde = , k, resizeactive, 0 -20
      binde = , j, resizeactive, 0 20
      bind = , escape, submap, reset
      bind = , Return, submap, reset
      submap = reset
    '';
  };

  # ── Hyprlock ─────────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
      };

      background = [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        noise = 1.17e-2;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
      }];

      label = [{
        text = "$TIME";
        color = "rgb(cdd6f4)";
        font_size = 64;
        font_family = "JetBrainsMono Nerd Font";
        position = "0, 120";
        halign = "center";
        valign = "center";
      }];

      input-field = [{
        size = "250, 50";
        outline_thickness = 2;
        dots_size = 0.26;
        dots_spacing = 0.15;
        dots_center = true;
        outer_color = "rgb(89b4fa)";
        inner_color = "rgb(1e1e2e)";
        font_color = "rgb(cdd6f4)";
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;
        position = "0, -20";
        halign = "center";
        valign = "center";
      }];
    };
  };

  # ── Hypridle ─────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
          on-resume = "";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # ── Caelestia Shell ──────────────────────────────────────────────
  programs.caelestia = {
    enable = true;
    settings = {
      bar.status.showBattery = true;
      paths.wallpaperDir = "~/Pictures/Wallpapers/";
    };
    cli = {
      enable = true;
    };
  };
}
