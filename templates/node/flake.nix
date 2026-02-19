{
  description = "Node.js / TypeScript development environment";

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
          nodejs_22
          pnpm

          # LSP + formatters (LazyVim picks these up from PATH)
          typescript-language-server
          prettierd
          tailwindcss-language-server
        ];

        shellHook = ''
          echo "Node $(node --version) + pnpm devShell active"
        '';
      };
    };
}
