# shellcheck shell=bash
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: org-open-pdf FILE.pdf [PAGE]" >&2
  exit 2
fi

pdf=$(realpath -e -- "$1") || {
  echo "org-open-pdf: PDF does not exist: $1" >&2
  exit 2
}
if [[ ! -f "$pdf" || ! -r "$pdf" || "${pdf,,}" != *.pdf ]]; then
  echo "org-open-pdf: expected a readable local PDF file: $pdf" >&2
  exit 2
fi

page=${2:-}
if [[ -n "$page" && ! "$page" =~ ^[1-9][0-9]*$ ]]; then
  echo "org-open-pdf: page must be a positive integer" >&2
  exit 2
fi

wayland=${WAYLAND_DISPLAY:-}
runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
if [[ -n "$wayland" && "$wayland" != /* ]]; then
  if [[ -S "$runtime/$wayland" ]]; then
    wayland="$runtime/$wayland"
  elif [[ -S "/mnt/wslg/runtime-dir/$wayland" ]]; then
    wayland="/mnt/wslg/runtime-dir/$wayland"
  else
    wayland=
  fi
fi
if [[ -n "$wayland" && ! -S "$wayland" ]]; then
  wayland=
fi

display=${DISPLAY:-}
if [[ "$display" == :* ]]; then
  number=${display#:}
  number=${number%%.*}
  [[ -S "/tmp/.X11-unix/X$number" ]] || display=
fi

if [[ -z "$wayland" && -z "$display" ]]; then
  echo "org-open-pdf: no usable WSLg/graphical display; check WAYLAND_DISPLAY and DISPLAY" >&2
  exit 1
fi

export WAYLAND_DISPLAY="$wayland"
export DISPLAY="$display"
if [[ -n "$page" ]]; then
  exec zathura "--page=$page" "$pdf"
fi
exec zathura "$pdf"
