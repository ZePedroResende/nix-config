{ pkgs, ... }:

{
  users.users.resende = {
    isNormalUser = true;
    description = "resende";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.fish;
    initialPassword = "nixos"; # Change immediately after first login!
  };

  programs.fish.enable = true;

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "resende" ];
  };
}
