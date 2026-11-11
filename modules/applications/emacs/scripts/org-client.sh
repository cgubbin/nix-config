# shellcheck shell=bash
# shellcheck disable=SC2154
# Shared body for the three Nix-packaged launchers. action/client are supplied
# by writeShellApplication, not by the caller's environment.
if [[ ( "$action" == project-capture && $# -gt 2 ) || ( "$action" == capture && $# -gt 1 ) || ( "$action" != project-capture && "$action" != capture && $# -ne 0 ) ]]; then
  echo "Usage: org-$action$([[ "$action" == capture ]] && printf ' [template-key]')$([[ "$action" == project-capture ]] && printf ' [file [line]]')" >&2
  exit 2
fi
key=${1:-}
projectContext=
if [[ "$action" == project-capture ]]; then
  file=${1:-${NVIM_FILE:-}}
  line=${2:-${NVIM_LINE:-}}
  root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  branch=$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$root" rev-parse --short HEAD 2>/dev/null || true)
  commit=$(git -C "$root" rev-parse HEAD 2>/dev/null || true)
  if [[ -n "$file" && "$file" != /* ]]; then
    file=$(realpath -m -- "$file")
  fi
  if [[ -n "$file" && "$file" == "$root"/* ]]; then
    file=${file#"$root"/}
  fi
  projectContext=$(jq -cn --arg root "$root" --arg branch "$branch" --arg commit "$commit" --arg file "$file" --arg line "$line" \
    '{root:$root,branch:$branch,commit:$commit,file:$file,line:$line}')
  key=P
fi
runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
if [[ ! -d "$runtime" || ! -O "$runtime" ]]; then
  echo "org-$action: no owned user runtime directory: $runtime" >&2
  exit 1
fi
export XDG_RUNTIME_DIR="$runtime"
# Serialize environment import and daemon startup. systemd is
# the only daemon owner; emacsclient is never allowed to spawn an alternate.
exec 9>"$runtime/org-emacs-launch.lock"
flock -w 70 9
if ! "$terminalClient"; then
  wayland=${WAYLAND_DISPLAY:-}
  if [[ -n "$wayland" && "$wayland" != /* ]]; then
    if [[ -S "$runtime/$wayland" ]]; then
      wayland="$runtime/$wayland"
    elif [[ -n "${WSL_INTEROP:-}" && -S "/mnt/wslg/runtime-dir/$wayland" ]]; then
      wayland="/mnt/wslg/runtime-dir/$wayland"
    else
      wayland=
    fi
  fi
  [[ -z "$wayland" || -S "$wayland" ]] || wayland=
  display=${DISPLAY:-}
  if [[ "$display" == :* ]]; then
    number=${display#:}
    number=${number%%.*}
    [[ -S "/tmp/.X11-unix/X$number" ]] || display=
  fi
  if [[ -n "$wayland" ]]; then
    backend=wayland
  elif [[ -n "$display" ]]; then
    backend=x11
  else
    echo "org-$action: no usable graphical display. Start a graphical session or enable WSLg; check DISPLAY, WAYLAND_DISPLAY and XDG_RUNTIME_DIR." >&2
    exit 1
  fi
  systemctl --user set-environment "DISPLAY=$display" "WAYLAND_DISPLAY=$wayland" \
    "XAUTHORITY=${XAUTHORITY:-}" "GDK_BACKEND=$backend"
fi
if ! timeout 65 systemctl --user start emacs.service; then
  echo "org-$action: Emacs service failed. Inspect: journalctl --user -u emacs.service -b" >&2
  exit 1
fi
ready=false
for ((attempt=0; attempt<100; attempt++)); do
  if "$client" --socket-name "$runtime/emacs/server" --alternate-editor=false --eval t >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 0.1
done
if ! "$ready"; then
  echo "org-$action: daemon socket did not become ready. Inspect: journalctl --user -u emacs.service -b" >&2
  exit 1
fi
if "$terminalClient"; then
  keyLiteral=$(printf '%s' "$key" | jq -Rs '.')
  if [[ "$action" == project-capture ]]; then
    contextLiteral=$(printf '%s' "$projectContext" | jq -Rs '.')
    frameParameters="((kit-org-action . \"project\") (kit-org-capture-key . $keyLiteral) (kit-org-project-context . $contextLiteral))"
  else
    frameParameters="((kit-org-action . \"$action\") (kit-org-capture-key . $keyLiteral))"
  fi
  flock -u 9
  exec "$client" --socket-name "$runtime/emacs/server" --alternate-editor=false \
    --tty --frame-parameters="$frameParameters"
else
  workflow=$action
  [[ "$action" == project-capture ]] && workflow=project
  payload=$(jq -cn --arg action "$workflow" --arg key "$key" \
    --arg display "$display" --arg wayland "$wayland" \
    --arg authority "${XAUTHORITY:-}" --arg backend "$backend" --arg projectContext "$projectContext" \
    '{action:$action,key:$key,display:$display,wayland:$wayland,authority:$authority,backend:$backend,projectContext:$projectContext}')
  # Quote JSON as a Lisp string; user text is never interpolated as Lisp syntax.
  quoted=$(printf '%s' "$payload" | jq -Rs '.')
  # A template/node picker can remain interactive; do not hold the launch lock
  # while the user chooses a note. Each request carries its own GUI environment.
  flock -u 9
  exec "$client" --socket-name "$runtime/emacs/server" --alternate-editor=false \
    --eval "(kit/org-open $quoted)" >/dev/null
fi
