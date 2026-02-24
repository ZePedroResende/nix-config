{
  description = "Elixir / Phoenix development environment";

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
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              elixir_1_18
              erlang_27
              nodejs_22
              postgresql_17

              # LSP + formatters (LazyVim picks these up from PATH)
              elixir-ls
              prettierd
            ] ++ lib.optionals stdenv.hostPlatform.isLinux [
              inotify-tools # Phoenix live reload (Linux only)
            ];

            shellHook = ''
              export MIX_HOME="$PWD/.nix-mix"
              export HEX_HOME="$PWD/.nix-hex"
              export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"

              # Project-local Postgres
              export PGDATA="$PWD/.nix-postgres"
              export PGHOST="$PWD/.nix-postgres"
              export DATABASE_URL="postgresql://localhost/$(basename $PWD)_dev"

              if [ ! -d "$PGDATA" ]; then
                initdb --no-locale --encoding=UTF8 -D "$PGDATA"
                echo "unix_socket_directories = '$PGHOST'" >> "$PGDATA/postgresql.conf"
                echo "listen_addresses = '''" >> "$PGDATA/postgresql.conf"
              fi

              if ! pg_isready -q -h "$PGHOST" 2>/dev/null; then
                pg_ctl -D "$PGDATA" -l "$PGDATA/postgres.log" start
              fi

              echo "Elixir devShell active — mix/hex isolated to project"
              echo "Postgres running (unix socket at $PGHOST)"
            '';
          };
        });
    };
}
