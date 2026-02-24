{
  description = "Node.js / TypeScript development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          default = pkgs.mkShell {
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
        });
    };
}
