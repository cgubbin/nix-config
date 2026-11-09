{ inputs, self, ... }: {
  systems = [ "x86_64-linux" ];
  perSystem = { pkgs, system, ... }: {
    formatter = pkgs.nixfmt-rfc-style;
    checks.pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
      # A linked worktree's .git is a file pointing outside the build sandbox.
      # Let git-hooks initialise its own temporary repository instead.
      src = pkgs.lib.cleanSource ../.;
      hooks = {
        deadnix.enable = true;
        statix.enable = true;
      };
    };
    devShells.default = pkgs.mkShell {
      inherit (self.checks.${system}.pre-commit-check) shellHook;
      packages = [
        pkgs.just
        pkgs.home-manager
      ];
    };
  };
}
