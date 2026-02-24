{ lib, ... }:

{
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Gruvbox Dark color palette shared across all modules";
  };

  config.theme = {
    bg = "#282828";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    fg = "#ebdbb2";
    fg2 = "#d5c4a1";
    red = "#cc241d";
    green = "#98971a";
    yellow = "#d79921";
    blue = "#458588";
    purple = "#b16286";
    aqua = "#689d6a";
    orange = "#d65d0e";
    bright_red = "#fb4934";
    bright_green = "#b8bb26";
    bright_yellow = "#fabd2f";
    bright_blue = "#83a598";
    bright_purple = "#d3869b";
    bright_aqua = "#8ec07c";
    bright_orange = "#fe8019";
  };
}
