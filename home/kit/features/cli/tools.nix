{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf optionals;
  cfg = config.home-config.cli;
in {
  home.packages = mkIf cfg.commonTools.enable (
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
        tdf
        see-cat
        rsync
        # vault-tasks
        television
        restic
        unar

        hexyl
        nasm
        broot

        # Yazi functionality
        ffmpeg-headless
        p7zip
        poppler
        resvg
        imagemagick

        # Nix linting
        alejandra
        deadnix
        nixd
        nixfmt
        statix

        age
        aerc
        ast-grep
        claude-code
        hunspell
        semgrep
        shellcheck
        treefmt
        zathura
      ]
      ++ optionals pkgs.stdenv.isLinux [
        xclip
        grim
        slurp
        valgrind
        bandwhich
        proximity-sort
      ]
  );
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}
