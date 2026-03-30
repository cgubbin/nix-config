{
  config,
  pkgs,
  ...
}:
{
  services.ssh-agent = {
    enable = true;
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "cgubbin";
        email = "chris.gubbin@gmail.com";
      };
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          navigate = true;
          syntax-theme = "default";
        };
      };
      aliases = {
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' -abbrev-commit -date=relative";
        root = "rev-parse --show-toplevel";
      };
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = "";
      github.user = "cgubbin";
      push.default = "tracking";
      init.defaultBranch = "main";

      extraConfig = {
        core = {
          pager = "delta";
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        delta = {
          features = "side-by-side line-numbers";
        };

        pull = {
          rebase = true;
        };

        rebase = {
          autoStash = true;
        };

        init = {
          defaultBranch = "main";
        };

        alias = {
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
      };
    };
  };
}
