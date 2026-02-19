{ pkgs, ... }:

{
  # ── Fish shell ────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    shellAliases = {
      v = "nvim";
      ":q" = "exit";
      tl = "tmux list-sessions";
      ta = "tmux attach -t";
      ls = "eza --group-directories-first";
      ll = "eza -lbF --git --icons --group-directories-first";
      la = "eza -lbhHigmuSa@ --group-directories-first";
      gs = "git status";
      tb = "nc termbin.com 9999";
      weather = "curl -4 http://wttr.in";
      nr = "sudo nixos-rebuild switch --flake /etc/nixos#framework";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#framework";
      nu = "nix flake update --flake /etc/nixos";
    };
    shellInit = ''
      fish_add_path ~/.local/bin
      fish_add_path ~/.cargo/bin
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx PNPM_HOME $HOME/.local/share/pnpm
      fish_add_path $PNPM_HOME
    '';
    functions = {
      take = {
        description = "Create directory and cd into it";
        body = "mkdir -p -- $argv && cd -- $argv";
      };
      ttake = {
        description = "Create temp directory and cd into it";
        body = "cd (mktemp -d)";
      };
      t = {
        description = "Smart tmux session creator";
        body = ''
          set -l session_name ""
          set -l target ""

          set -l i 1
          while test $i -le (count $argv)
            switch $argv[$i]
              case -s
                set i (math $i + 1)
                set session_name $argv[$i]
              case -t
                set i (math $i + 1)
                set target $argv[$i]
              case '*'
                set session_name $argv[$i]
            end
            set i (math $i + 1)
          end

          if test -n "$target"
            tmux attach-session -t $target
          else if test -n "$session_name"
            tmux new-session -s $session_name
          else
            tmux new-session -s (basename $PWD)
          end
        '';
      };
    };
  };

  # ── Kitty terminal ────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      wayland_titlebar_decoration = true;
    };
  };

  # ── Tmux ──────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      copycat
      vim-tmux-navigator
      resurrect
    ];
    extraConfig = ''
      # Catppuccin Mocha colors
      set -g status-style "bg=#313244,fg=#cdd6f4"
      set -g pane-border-style "fg=#45475a"
      set -g pane-active-border-style "fg=#89b4fa"
      set -g window-status-current-style "fg=#89dceb,bold"
      set -g message-style "bg=#313244,fg=#a6e3a1"

      # Splits
      bind v split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"

      # Window navigation
      bind -n M-H previous-window
      bind -n M-L next-window
      bind -n M-0 select-window -t :0
      bind -n M-1 select-window -t :1
      bind -n M-2 select-window -t :2
      bind -n M-3 select-window -t :3
      bind -n M-4 select-window -t :4
      bind -n M-5 select-window -t :5
      bind -n M-6 select-window -t :6
      bind -n M-7 select-window -t :7
      bind -n M-8 select-window -t :8
      bind -n M-9 select-window -t :9

      # Pane zoom
      bind C-Q resize-pane -Z

      # Auto renumber windows
      set -g renumber-windows on
      set -g set-titles on
      set -g focus-events on

      # True color
      set -ga terminal-overrides ",*256col*:Tc"
    '';
  };
}
