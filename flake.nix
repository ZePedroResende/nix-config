{
  description = "Nix — Framework 13 · MacBook · VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    foundry = {
      url = "github:shazow/foundry.nix/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-hardware,
      lanzaboote,
      nix-darwin,
      foundry,
      claude-code,
      ...
    }@inputs:
    {
      nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ foundry.overlay ]; }

          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.framework-amd-ai-300-series

          ./hosts/framework
          ./modules/base.nix
          ./modules/desktop.nix
          ./modules/hardware.nix
          ./modules/security.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.resende = import ./home;
          }
        ];
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.resende = import ./home;
          }
        ];
      };

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ foundry.overlay ]; }
          ./hosts/vm
          ./modules/base.nix
          ./modules/desktop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.resende = import ./home;
          }
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;

      # Project templates — usage: nix flake init --template /etc/nixos#rust
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust dev environment (clang, mold, bacon, sccache)";
        };
        elixir = {
          path = ./templates/elixir;
          description = "Elixir/Phoenix dev environment (elixir, erlang, node)";
        };
        node = {
          path = ./templates/node;
          description = "Node.js/TypeScript dev environment (node, pnpm)";
        };
        python = {
          path = ./templates/python;
          description = "Python dev environment (python3, uv)";
        };
      };
    };
}
