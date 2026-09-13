{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.home-config.dev;
in {
  home.packages = mkIf cfg.devTools.enable (
    with pkgs; [
      nix-tree
      tokei
      gh
      hub
      git-lfs
      git-open

      typst
      tinymist

      clang
      gnumake
      tree-sitter

      # Cloud
      ansible
      doctl
      goofys
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      krew
      kubectl
      kubectx
      kubelogin-oidc
      k9s
      opentofu
      terraform
    ]
  );

  programs.awscli = {
    enable = true;
  };

  programs.lazygit = mkIf cfg.devTools.enable {
    enable = true;
    settings.git = {
      overrideGpg = true;
    };
  };

  programs.tmux = mkIf cfg.devTools.enable {
    enable = true;
    clock24 = true;
    prefix = "C-a";
    baseIndex = 1;
    mouse = true;
    disableConfirmationPrompt = true;
    escapeTime = 0;
    historyLimit = 5000;
    # plugins =
    #   # let
    #   #   inherit (pkgs.tmuxPlugins) resurrect continuum;
    #   # in
    #   # [
    #   #   {
    #   #     plugin = resurrect;
    #   #     extraConfig = "set -g @resurrect-processes '\"~hx->hx *\" lazygit vault-tasks spotify-player'";
    #   #   }
    #   #   {
    #   #     plugin = continuum;
    #   #     extraConfig = ''
    #   #       set -g @continuum-restore 'on'
    #   #       set -g @continuum-save-interval '5' # minutes
    #   #     '';
    #   #   }
    #   # ];
  };
}
