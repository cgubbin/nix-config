{
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    functions =
      let
        tmux = lib.getExe pkgs.tmux;
        zellij = lib.getExe pkgs.zellij;
        tv = lib.getExe pkgs.television;
        cut = lib.getExe' pkgs.coreutils "cut";
        basename = lib.getExe' pkgs.coreutils "basename";
        pwd = lib.getExe' pkgs.coreutils "pwd";
      in
      {
        fish_prompt.body = ''
          set -l last_status $status

          # Colors
          set -l c_reset (set_color normal)
          set -l c_path (set_color blue)
          set -l c_git (set_color magenta)
          set -l c_ok (set_color green)
          set -l c_err (set_color red)
          set -l c_dim (set_color brblack)
          set -l c_env (set_color cyan)
          set -l c_warn (set_color yellow)

          # CWD
          set -l cwd (prompt_pwd)

          # Git
          set -l git_segment
          if command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
            set -l branch (command git symbolic-ref --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)

            set -l dirty
            command git diff --quiet --ignore-submodules HEAD >/dev/null 2>/dev/null
            or set dirty "*"

            set -l staged
            command git diff --cached --quiet --ignore-submodules >/dev/null 2>/dev/null
            or set staged "+"

            set git_segment "$c_git$branch$staged$dirty$c_reset"
          end

          # Environment flags
          set -l env_segments

          if set -q DIRENV_DIR
            set env_segments $env_segments "$c_env"'[env]'"$c_reset"
          end

          if set -q IN_NIX_SHELL
            set env_segments $env_segments "$c_env"'[nix]'"$c_reset"
          end

          if set -q VIRTUAL_ENV
            set env_segments $env_segments "$c_env"'[venv]'"$c_reset"
          end

          if set -q ZELLIJ
            set env_segments $env_segments "$c_dim"'[zj]'"$c_reset"
          end

          # Line 1
          echo -n $c_path$cwd$c_reset

          if test -n "$git_segment"
            echo -n "  $git_segment"
          end

          if test (count $env_segments) -gt 0
            echo -n "  "(string join " " $env_segments)
          end

          echo

          # Line 2
          if test $last_status -eq 0
            echo -n $c_ok"❯ "$c_reset
          else
            echo -n $c_err"[$last_status] ❯ "$c_reset
          end
        '';

        fish_right_prompt.body = ''
          set -l c_reset (set_color normal)
          set -l c_dim (set_color brblack)
          set -l c_mode (set_color yellow)
          set -l c_ssh (set_color red)

          # Vi mode
          set -l mode_segment
          switch $fish_bind_mode
            case insert
              set mode_segment "$c_mode I$c_reset"
            case default
              set mode_segment "$c_mode N$c_reset"
            case visual
              set mode_segment "$c_mode V$c_reset"
            case replace_one
              set mode_segment "$c_mode R$c_reset"
            case '*'
              set mode_segment "$c_dim?$c_reset"
          end

          # SSH indicator
          set -l ssh_segment
          if set -q SSH_TTY
            set ssh_segment "$c_ssh[ssh]$c_reset"
          end

          # Duration
          set -l duration_segment
          if test $CMD_DURATION -gt 1500
            if test $CMD_DURATION -lt 10000
              set duration_segment "$c_dim$CMD_DURATION"'ms'"$c_reset"
            else if test $CMD_DURATION -lt 60000
              set -l seconds (math "$CMD_DURATION / 1000.0")
              set duration_segment "$c_dim"(printf "%.1fs" $seconds)"$c_reset"
            else
              set -l minutes (math "floor($CMD_DURATION / 60000)")
              set -l seconds (math "floor(($CMD_DURATION % 60000) / 1000)")
              set duration_segment "$c_dim"(printf "%dm%02ds" $minutes $seconds)"$c_reset"
            end
          end

          set -l parts
          if test -n "$ssh_segment"
            set parts $parts "$ssh_segment"
          end
          set parts $parts "$mode_segment"
          if test -n "$duration_segment"
            set parts $parts "$duration_segment"
          end

          echo -n (string join "  " $parts)
        '';

        tmn.body = "${tmux} new-session -A -s $(${basename} $(${pwd}))";
        tma.body = "${tmux} attach -t $(${tmux} list-sessions | ${tv} --preview 'tmux list-windows -t {0}' | ${cut} -d':' -f1)";
        tmw.body = ''
          set session (${tmux} list-sessions | ${tv} --preview 'tmux list-windows -t {0}' | ${cut} -d':' -f1)
          ${tmux} attach -t $session:(${tmux} list-windows -t $session | ${tv} | ${cut} -d':' -f1)
        '';

        ff.body = ''
          set -l file (
            fd --type f --hidden --strip-cwd-prefix --exclude .git \
            | fzf --preview 'bat --line-range :200 --color=always {}'
          )

          if test -n "$file"
            nvim "$file"
          end
        '';

        fdir.body = ''
          set -l dir (
            fd --type d --hidden --exclude .git --strip-cwd-prefix \
            | fzf --preview 'eza --tree --level=2 --color=always {} | head -200'
          )

          if test -n "$dir"
            cd "$dir"
          end
        '';

        frg.body = ''
          if test (count $argv) -eq 0
            echo "Usage: frg <pattern>"
            return 1
          end

          set -l selected (
            rg --line-number --no-heading --color=never --hidden --glob '!.git' $argv \
            | fzf --delimiter ':' \
                --preview 'bat --color=always --line-range :200 {1} --highlight-line {2}'
          )

          if test -z "$selected"
            return 0
          end

          set -l file (string split -m 2 ':' "$selected")[1]
          set -l rest (string split -m 2 ':' "$selected")[2]
          set -l line (string split -m 1 ':' "$rest")[1]

          nvim "+$line" "$file"
        '';

        frgl.body = ''
          set -l delim \t

          set -l selected (
            fzf \
              --ansi \
              --disabled \
              --prompt 'rg> ' \
              --header 'Enter: open | Ctrl-O: file | Ctrl-V: vsplit | Ctrl-S: split' \
              --bind "start:reload(if test -n '{q}'; rg --line-number --column --no-heading --color=always --hidden --glob '!.git' --smart-case --field-match-separator '$delim' -- {q}; end)" \
              --bind "change:reload(if test -n '{q}'; rg --line-number --column --no-heading --color=always --hidden --glob '!.git' --smart-case --field-match-separator '$delim' -- {q}; end)" \
              --bind 'ctrl-o:execute-silent(nvim {1})+abort' \
              --bind 'ctrl-v:execute-silent(nvim +{2} -c "vsplit" {1})+abort' \
              --bind 'ctrl-s:execute-silent(nvim +{2} -c "split" {1})+abort' \
              --delimiter "$delim" \
              --preview 'bat --color=always --line-range :200 --highlight-line {2} {1}' \
              --preview-window='right,60%,border-left'
          )

          if test -z "$selected"
            return 0
          end

          set -l parts (string split "$delim" "$selected")
          set -l file $parts[1]
          set -l line $parts[2]

          nvim "+$line" "$file"
        '';

        rerun = ''
          argparse 'd/dry-run' -- $argv
          if test (count $argv) -ne 1
              echo "Usage: rerun [--dry-run|-d] N"
              return 1
          end

          set -l n $argv[1]
          set -l count 0
          set -l commands

          for cmd in (history | grep -v '^rerun') # skip rerun calls
              if test $count -ge $n
                  break
              end
              set commands $cmd $commands  # prepend to preserve order
              set count (math $count + 1)
          end

          if test $count -lt $n
              echo "Only found $count non-rerun commands in history"
          end

          for cmd in $commands
              echo "> $cmd"
              if not set -q _flag_dry_run
                  eval $cmd
              end
          end
        '';

        fbr.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "fbr: not in a git repository"
            return 1
          end

          set -l refs (
            begin
              git for-each-ref \
                --sort=-committerdate \
                --format='local\t%(refname:short)' \
                refs/heads

              git for-each-ref \
                --sort=-committerdate \
                --format='remote\t%(refname:short)' \
                refs/remotes
            end | awk -F '\t' '!seen[$2]++'
          )

          set -l branch (
            printf '%s\n' $refs \
            | fzf \
                --delimiter '\t' \
                --with-nth 1,2 \
                --prompt 'git branch> ' \
                --preview '
                  ref=$(printf "%s" {} | cut -f2)
                  git log --oneline --graph --decorate --color=always -20 "$ref"
                ' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$branch"
            return 0
          end

          set -l ref (string split \t -- "$branch")[2]
          set -l target (string replace -r '^(origin|upstream)/' "" -- "$ref")

          if git show-ref --verify --quiet "refs/heads/$target"
            git switch "$target"
          else
            git switch --track "$ref" 2>/dev/null; or git switch "$target"
          end
        '';

        fco.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "fco: not in a git repository"
            return 1
          end

          set -l commit (
            git log \
              --color=always \
              --format='%h\t%s\t%cr\t%d' \
            | fzf \
                --ansi \
                --delimiter '\t' \
                --with-nth 1,2,3,4 \
                --prompt 'git commit> ' \
                --preview '
                  hash=$(printf "%s" {} | cut -f1)
                  git show --stat --patch --color=always "$hash"
                ' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$commit"
            return 0
          end

          set -l hash (printf '%s\n' "$commit" | cut -f1)
          git show "$hash"
        '';

        fst.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "fst: not in a git repository"
            return 1
          end

          set -l entry (
            git status --short \
            | fzf \
                --prompt 'git status> ' \
                --preview '
                  line="{}"
                  status=$(printf "%s" "$line" | cut -c1-2)
                  path=$(printf "%s" "$line" | sed -E "s/^.. //; s#.* -> ##")

                  if test (printf "%s" "$status" | cut -c1) != " "
                    git diff --cached --color=always -- "$path"
                  else
                    git diff --color=always -- "$path"
                  end
                ' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$entry"
            return 0
          end

          set -l path (printf '%s\n' "$entry" | sed -E 's/^.. //; s#.* -> ##')
          nvim "$path"
        '';

        fadd.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "fadd: not in a git repository"
            return 1
          end

          set -l entries (
            git status --short \
            | fzf \
                --multi \
                --prompt 'git add> ' \
                --preview '
                  path=$(printf "%s" "{}" | sed -E "s/^.. //; s#.* -> ##")
                  git diff --color=always -- "$path"
                ' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$entries"
            return 0
          end

          for entry in (string split \n -- "$entries")
            set -l path (printf '%s\n' "$entry" | sed -E 's/^.. //; s#.* -> ##')
            git add -- "$path"
          end
        '';

        freset.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "freset: not in a git repository"
            return 1
          end

          set -l files (
            git diff --name-only --cached \
            | fzf \
                --multi \
                --prompt 'git unstage> ' \
                --preview 'git diff --cached --color=always -- {}' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$files"
            return 0
          end

          for f in (string split \n -- "$files")
            git restore --staged -- "$f"
          end
        '';

        fstash.body = ''
          if not git rev-parse --git-dir >/dev/null 2>/dev/null
            echo "fstash: not in a git repository"
            return 1
          end

          set -l stash (
            git stash list \
            | fzf \
                --prompt 'git stash> ' \
                --preview '
                  ref=$(printf "%s" "{}" | cut -d: -f1)
                  git stash show -p --color=always "$ref"
                ' \
                --preview-window='right,60%,border-left'
          )

          if test -z "$stash"
            return 0
          end

          set -l ref (printf '%s\n' "$stash" | cut -d: -f1)
          git stash pop "$ref"
        '';

        fkill.body = ''
          set -l selected (
            procs \
            | fzf \
                --multi \
                --prompt 'kill> '
          )

          if test -z "$selected"
            return 0
          end

          for line in (string split \n -- "$selected")
            set -l pid (printf '%s\n' "$line" | awk '{print $1}')
            kill "$pid"
          end
        '';

        gcommit.body = ''
          if test (count $argv) -eq 0
            git commit
          else
            git commit -m "$argv[1]"
          end
        '';

        gfixup.body = ''
          set -l commit (
            git log --oneline --decorate \
            | fzf --prompt 'fixup> ' --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always'
          )

          if test -z "$commit"
            return 0
          end

          set -l hash (string split ' ' -- "$commit")[1]
          git commit --fixup "$hash"
        '';

        gunstage.body = ''
          set -l files (
            git diff --name-only --cached \
            | fzf --multi --prompt 'unstage> ' --preview 'git diff --cached --color=always -- {}'
          )

          if test -z "$files"
            return 0
          end

          for f in (string split \n -- "$files")
            git restore --staged -- "$f"
          end
        '';

        __zj_project_kind_for_dir.body = ''
          set -l dir "$argv[1]"
          set -l rel (string replace "$HOME/" "" -- "$dir")


          if test -e "$dir/Cargo.toml"
            echo rust
            return 0
          end

          if test -e "$dir/go.mod"
            echo rust
            return 0
          end

          if test -e "$dir/quarto.yml"
            echo quarto
            return 0
          end

          if test -e "$dir/pyproject.toml"
            echo python
            return 0
          end

          if test -e "$dir/main.tex"
            echo latex
            return 0
          end

          if find "$dir" -maxdepth 1 \( -name '*.qmd' -o -name '*.tex' \) | read
            echo quarto
            return 0
          end

          if test -e "$dir/flake.nix"
            if string match -rq 'nixos|home-manager|nix-config' -- "$rel"
              echo nix
              return 0
            end
          end

          echo default
        '';

        raw.body = ''
          env NO_ZELLIJ=1 fish
        '';

        __zj_layout_for_kind.body = ''
          set -l kind "$argv[1]"
          set -l candidate "$HOME/.config/zellij/layouts/$kind.kdl"
          set -l fallback "$HOME/.config/zellij/layouts/default.kdl"

          if test -r "$candidate"
            realpath "$candidate"
          else if test -r "$fallback"
            realpath "$fallback"
          else
            echo "ERROR: no readable Zellij layout for kind '$kind'" >&2
            return 1
          end
        '';

        __zj_layout_for_dir.body = ''
          set -l dir "$argv[1]"
          set -l kind (__zj_project_kind_for_dir "$dir")
          or return 1
          __zj_layout_for_kind "$kind"
        '';

        __zj_session_name_for_dir.body = ''
          set -l dir "$argv[1]"
          set -l rel (string replace "$HOME/" "" -- "$dir")
          string replace -a '/' '_' -- "$rel"
        '';

        zjsm.body = ''
          if set -q ZELLIJ
            zellij action launch-or-focus-plugin session-manager
          else
            zellij -l welcome
          end
        '';

        fzlay_raw.body = ''
          set -l layout_dir "$HOME/.config/zellij/layouts"

          if test ! -d "$layout_dir"
            echo "fzlay: layout directory not found: $layout_dir"
            return 1
          end

          set -l layout_file (
            fd -L --extension kdl --type f . "$layout_dir" \
            | fzf --prompt 'layout> '
          )

          if test -z "$layout_file"
            return 0
          end

          set -l default_name (path basename "$layout_file" .kdl)
          read -P "session name [$default_name]: " session_name

          if test -z "$session_name"
            set session_name "$default_name"
          end

          zellij attach --create-background "$session_name" options --default-layout "$layout_file"
          and zellij attach "$session_name"
        '';

        zj.body = ''
          if set -q ZELLIJ
            echo "zj: use the Zellij session manager inside Zellij"
            return 1
          end

          set -l dir (
            zoxide query -l | fzf --prompt 'project> '
          )

          if test -z "$dir"
            return 0
          end

          set -l name (__zj_session_name_for_dir "$dir")

          zellij attach --create-background "$name" options --default-cwd "$dir"
          and zellij attach "$name"
        '';

        zjl.body = ''
          if set -q ZELLIJ
            echo "zjl: use the Zellij session manager inside Zellij"
            return 1
          end

          set -l dir (
            zoxide query -l | fzf --prompt 'project> '
          )

          if test -z "$dir"
            return 0
          end

          set -l name (__zj_session_name_for_dir "$dir")
          set -l layout (__zj_layout_for_dir "$dir")

          if test ! -r "$layout"
              echo "zjl_path: layout not readable: $layout"
              return 1
          end

          zellij attach --create-background "$name" options --default-cwd "$dir" --default-layout "$layout"
          and zellij attach "$name"
        '';

        fzlay.body = ''
          if set -q ZELLIJ
            env NO_ZELLIJ=1 fish -ic fzlay_raw
          else
            fzlay_raw
          end
        '';

        zjl_path.body = ''
          if test (count $argv) -eq 0
            echo "Usage: zjl_path <directory>"
            return 1
          end

          set -l dir (realpath "$argv[1]" 2>/dev/null)
          if test -z "$dir"
            echo "zjl_path: could not resolve path"
            return 1
          end

          if test ! -d "$dir"
            echo "zjl_path: not a directory: $dir"
            return 1
          end

          if set -q ZELLIJ
            echo "zjl_path: run this from a raw shell"
            return 1
          end

          set -l name (__zj_session_name_for_dir "$dir")
          set -l layout (__zj_layout_for_dir "$dir")
          or return 1

          if test ! -r "$layout"
              echo "zjl_path: layout not readable: $layout"
              return 1
          end

          zellij attach --create-background "$name" options --default-cwd "$dir" --default-layout "$layout"
          and zellij attach "$name"
        '';

        __mkproj_template_for_kind.body = ''
          set -l kind "$argv[1]"

          switch "$kind"
            case python-app
              echo ~/src/nix-templates#python-app
            case python-lib
              echo ~/src/nix-templates#python-lib
            case rust
              echo ~/src/nix-templates#rust
            case go
              echo ~/src/nix-templates#go
            case quarto
              echo ~/src/nix-templates#quarto
            case latex
              echo ~/src/nix-templates#latex
            case c
              echo ~/src/nix-templates#c
            case cpp
              echo ~/src/nix-templates#cpp
            case shell
              echo ~/src/nix-templates#shell
            case '*'
              return 1
          end
        '';

        mk.body = ''
          if test (count $argv) -lt 2
            echo "Usage: mk <kind> <project-name> [--open]"
            return 1
          end

          set -l kind $argv[1]
          set -l name $argv[2]
          set -l rest $argv[3..-1]

          set -l template (__mkproj_template_for_kind "$kind")
          or begin
            echo "mk: unknown project kind: $kind"
            return 1
          end

          mkproj "$name" "$template" $rest
        '';

        mkproj.body = ''
          if test (count $argv) -lt 2
            echo "Usage: mkproj <project-name> <template-ref> [--open]"
            return 1
          end

          set -l project_name $argv[1]
          set -l template_ref $argv[2]
          set -l should_open 0

          if test (count $argv) -ge 3
            if test "$argv[3]" = "--open"
              set should_open 1
            end
          end

          if test -e "$project_name"
            echo "mkproj: path already exists: $project_name"
            return 1
          end

          nix flake new "$project_name" -t "$template_ref"
          or return 1

          cd "$project_name"
          or return 1

          if test ! -e .envrc
            printf '%s\n' 'use flake' > .envrc
          end

          if test ! -e .git
            git init >/dev/null 2>/dev/null
          end

          git add .

          direnv allow
          or begin
            echo "mkproj: direnv allow failed"
            return 1
          end

          set -l project_dir (pwd)

          echo "[project] created: $project_dir"
          echo "[project] direnv enabled"

          if test $should_open -eq 1
            zjl_path "$project_dir"
            return $status
          end

          echo "[project] next:"
          echo "  nvim ."
          echo "  zjl_path \"$project_dir\""
        '';

        mkpyapp.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkpyapp <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind python-app) $args
        '';

        mkpylib.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkpylib <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind python-lib) $args
        '';

        mkrust.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkrust <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind rust) $args
        '';

        mkgo.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkgo <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind go) $args
        '';

        mksh.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mksh <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind shell) $args
        '';

        mkla.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkla <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind latex) $args
        '';

        mkc.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkc <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind c) $args
        '';

        mkcpp.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkcpp <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind cpp) $args
        '';

        mkqp.body = ''
          if test (count $argv) -eq 0
            echo "Usage: mkqp <project-name> [--open]"
            return 1
          end

          set -l args $argv[2..-1]
          mkproj "$argv[1]" (__mkproj_template_for_kind quarto) $args
        '';
      };

    shellAbbrs = {
      # safety measures
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      mkdir = "mkdir -p";
    };

    shellAliases =
      let
        eza = lib.getExe pkgs.eza;
        dysk = lib.getExe pkgs.dysk;
        duf = lib.getExe pkgs.duf;
        bat = lib.getExe pkgs.bat;
        broot = lib.getExe pkgs.broot;
        dust = lib.getExe pkgs.dust;
        nh = lib.getExe pkgs.nh;
        git = lib.getExe pkgs.git;
        bandwhich = lib.getExe pkgs.bandwhich;
        procs = lib.getExe pkgs.procs;
        lazygit = lib.getExe pkgs.lazygit;
      in
      {
        which = "readlink -f (type -p $argv)";
        rebuild-dagon = "cd /home/louis/src/nixos-config && nixos-rebuild switch --flake .#dagon --target-host louis@dagon --use-remote-sudo --impure";
        rebuild-sys = "${nh} os switch /home/louis/src/nixos-config";
        update-sys = "${nh} os switch /home/louis/src/nixos-config --update";

        vim = "nvim";

        ls = "${eza} --long --header --binary --no-permissions --no-user --icons=auto";
        lss = "ls --total-size";
        lst = "ls --tree";
        lsg = "ls --git";

        lg = lazygit;

        cat = bat;
        tree = broot;
        du = dust;
        dff = duf;
        df = dysk;
        g = git;
        bw = bandwhich;
        ps = procs;

        # --- Nix Workflows ---
        nd = "nix develop";
        ns = "nix shell nixpkgs#";
        nb = "nix build";
        nr = "nix run";

        # # --- Nix flake templates ---
        # mkpy = "nix flake new $argv -t ~/src/nix-templates#python";
        # mkrust = "nix flake new $argv -t ~/src/nix-templates#rust";
        # mkc = "nix flake new $argv -t ~/src/nix-templates#c";
        # mkcpp = "nix flake new $argv -t ~/src/nix-templates#cpp";
        # mkj = "nix flake new $argv -t ~/src/nix-templates#jupyter";

        # --- Quick dev shells ---
        py = "nix shell nixpkgs#python313 nixpkgs#uv";
        rust = "nix shell nixpkgs#rustc nixpkgs#cargo nixpkgs#rustfmt nixpkgs#clippy";
        cc = "nix shell nixpkgs#gcc nixpkgs#gnumake nixpkgs#gdb";
        cpp = "nix shell nixpkgs#clang nixpkgs#cmake nixpkgs#ninja";

        # --- Jupyter quick env ---
        jl = "nix shell nixpkgs#python313 nixpkgs#python313Packages.jupyterlab -c jupyter lab";

        # --- Direnv ---
        da = "direnv allow";
        dr = "direnv reload";
      };

    interactiveShellInit = ''
      # Open command buffer in vim when alt+e is pressed
      bind \ee edit_command_buffer
      fish_vi_key_bindings
      if status is-interactive
          and not set -q ZELLIJ
          and not set -q SSH_TTY
          and not set -q NO_ZELLIJ
          zellij -l welcome
      end
    '';
  };
}
