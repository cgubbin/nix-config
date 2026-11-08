_: {
  flake.modules.homeManager.shared-git = { config, lib, ... }: {
    programs.git = {
      enable = true;
      settings = {
        alias = {
          cleanup = "!git branch --merged | grep -Ev '(^[*+]|^[[:space:]]*(main|master|develop)$)' | xargs -r git branch -d";
          prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
          root = "rev-parse --show-toplevel";
          s = "status -sb";
          l = "log --oneline --graph --decorate";
          ll = "log --stat --graph --decorate";
          d = "diff";
          dc = "diff --cached";
          co = "checkout";
          sw = "switch";
          br = "branch";
          ci = "commit";
          amend = "commit --amend";
          unstage = "restore --staged";
        };
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = "";
        core.pager = lib.getExe config.programs.delta.package;
        push.default = "tracking";
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
        syntax-theme = "default";
      };
    };
  };
}
