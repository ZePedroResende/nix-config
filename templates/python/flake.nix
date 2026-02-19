{
  description = "Python development environment";

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
          python3
          uv

          # LSP + formatters (LazyVim picks these up from PATH)
          pyright
          ruff
        ];

        shellHook = ''
          echo "Python $(python3 --version) + uv devShell active"
        '';
      };
    };
}
