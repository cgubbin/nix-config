_: {
  flake.modules.homeManager."home-kit-features-cli-tools-core" =
    {
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) optionals;
    in
    {
      home.packages =
        with pkgs;
        [
          trash-cli
          dust
          duf
          dysk
          ripgrep
          htop
          procs

          yq-go
          jq
          just
          eza
          fd
          tree
          watch

          watchexec
          hurl

          nix-output-monitor
          nix-direnv
          noti
          killall
          wget
          rsync
          unar

          hexyl
          broot

          # Yazi functionality
          ffmpeg-headless
          p7zip
          poppler
          resvg
          imagemagick

        ]
        ++ optionals pkgs.stdenv.isLinux [
          xclip
        ];
      programs.eza = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  flake.modules.homeManager."home-kit-features-cli-tools-extras" = { lib, pkgs, ... }: {
    home.packages =
      with pkgs;
      [
        tdf
        see-cat
        television
        restic
        nasm
        alejandra
        deadnix
        nixd
        nixfmt
        statix
        age
        sops
        aerc
        ast-grep
        hunspell
        semgrep
        shellcheck
        treefmt
        zathura
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        grim
        slurp
        valgrind
        bandwhich
        proximity-sort
      ];
  };
}
