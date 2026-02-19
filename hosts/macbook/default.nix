{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "macbook";

  # Nix settings (mirrors base.nix for NixOS)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # auto-optimise-store corrupts the store on macOS — use nix.optimise instead
    trusted-users = [ "resende" ];
    keep-outputs = true;
    keep-derivations = true;
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
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; };
    options = "--delete-older-than 14d";
  };

  # Fish + Nix daemon shell init
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
  '';

  environment.shells = with pkgs; [ fish ];
  nixpkgs.config.allowUnfree = true;

  # User
  users.users.resende = {
    home = "/Users/resende";
    shell = pkgs.fish;
  };
  system.primaryUser = "resende";

  system.stateVersion = 5;
}
