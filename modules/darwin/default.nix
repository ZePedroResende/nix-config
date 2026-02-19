{ ... }:

{
  # Homebrew — manages GUI apps (casks) that aren't in nixpkgs for Darwin
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "1password"
      "firefox"
      "google-chrome"
      "slack"
      "spotify"
      "kitty"
    ];
  };

  # macOS system preferences (declarative)
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      minimize-to-application = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
  };

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
