{
  description = "Elixir / Phoenix development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          elixir_1_18
          erlang_27
          nodejs_22
          inotify-tools  # Phoenix live reload

          # LSP + formatters (LazyVim picks these up from PATH)
          elixir-ls
          prettierd
        ];

        shellHook = ''
          export MIX_HOME="$PWD/.nix-mix"
          export HEX_HOME="$PWD/.nix-hex"
          export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"
          echo "Elixir devShell active — mix/hex isolated to project"
        '';
      };
    };
}
