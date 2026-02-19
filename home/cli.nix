{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    devenv
  ];

  # Cargo config — use mold linker on Linux (available in Rust devShells)
  home.file.".cargo/config.toml".text = ''
    [target.'cfg(target_os = "linux")']
    linker = "clang"
    rustflags = ["-C", "link-arg=-fuse-ld=mold"]

    [build]
    rustflags = ["-Z", "threads=8"]
  '';
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      update_check = false;
    };
  };
}
