{ pkgs, ... }:

{
  # ── Neovim + LazyVim ──────────────────────────────────────────
  # LSP servers provided by Nix — disable mason in ~/.config/nvim/lua/plugins/nix.lua:
  #   { "mason-org/mason.nvim", enabled = false },
  #   { "mason-org/mason-lspconfig.nvim", enabled = false },
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil                          # nix
      vscode-langservers-extracted # html, css, json, eslint
      yaml-language-server
      bash-language-server
      marksman                     # markdown
      # Project-specific LSPs (rust-analyzer, pyright, etc.) go in devShell templates

      # Formatters / linters
      stylua
      nixfmt
      shellcheck
      shfmt

      # Tools LazyVim expects on PATH
      tree-sitter
    ];
  };
}
