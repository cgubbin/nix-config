_: {
  flake.modules.homeManager."home-kit-global-tools-nushell" = _: {
    programs.nushell = {
      enable = true;

      # Keep the declarative bits in Nix where possible.
      settings = {
        show_banner = false;

        edit_mode = "vi";

        history = {
          max_size = 100000;
          sync_on_enter = true;
          file_format = "sqlite";
        };

        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
          algorithm = "fuzzy";
          external = {
            enable = true;
            max_results = 100;
          };
        };

        cursor_shape = {
          emacs = "line";
          vi_insert = "line";
          vi_normal = "block";
        };

        footer_mode = "rows";
        use_ansi_coloring = true;
        highlight_resolved_externals = true;
        buffer_editor = "nvim";
      };

      shellAliases = {
        ll = "ls -la";
        la = "ls -a";
        l = "ls";
        g = "git";
        v = "nvim";
        c = "clear";
      };

      environmentVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less -FR";
        MANPAGER = "less -FR";
      };

      extraEnv = ''
        # Put Nu-specific environment setup here.
        # Keep this small unless you really need more.

        # Example PATH extension pattern:
        # $env.PATH = ($env.PATH | append "~/.local/bin")

        # Better file size / time display defaults can wait until you know
        # what you actually like.
      '';

      extraConfig = ''
        # Small helper commands that are actually pleasant in Nu.

        def mkcd [dir: path] {
          mkdir $dir
          cd $dir
        }

        def take [dir: path] {
          mkdir $dir
          cd $dir
        }

        def dots [] {
          cd ~/.config
        }

        def nixcfg [] {
          cd /etc/nixos
        }

        # Quick JSON/YAML/TOML inspection helpers.
        def j [file: path] {
          open $file
        }

        def y [file: path] {
          open $file
        }

        # Git overview that's nice in Nu tables.
        def gst [] {
          git status --short
        }

        # Large files in the current tree.
        def bigfiles [
          path: path = ".",
          --count (-n): int = 20
        ] {
          ls -la $path
          | where type == file
          | sort-by size
          | last $count
        }

        # Processes by memory.
        def topmem [
          --count (-n): int = 15
        ] {
          ps
          | sort-by mem
          | reverse
          | first $count
        }
      '';
    };
  };
}
