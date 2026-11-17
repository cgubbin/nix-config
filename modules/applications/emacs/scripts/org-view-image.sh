# shellcheck shell=bash
# Show one image in the current terminal pane, then wait for Enter. Org opens it in a Zellij pane
# from terminal Emacs frames, which cannot draw images themselves.
if [[ $# -ne 2 ]]; then
  echo "Usage: org-view-image PROTOCOL FILE (PROTOCOL: sixels, kitty or symbols)" >&2
  exit 2
fi

protocol=$1
case "$protocol" in
  sixels | kitty | symbols) ;;
  *)
    echo "org-view-image: protocol must be sixels, kitty or symbols, not: $protocol" >&2
    exit 2
    ;;
esac

image=$(realpath -e -- "$2") || {
  echo "org-view-image: image does not exist: $2" >&2
  exit 2
}
if [[ ! -f "$image" || ! -r "$image" ]]; then
  echo "org-view-image: expected a readable file: $image" >&2
  exit 2
fi
case "${image,,}" in
  *.png | *.jpg | *.jpeg | *.gif | *.svg | *.webp) ;;
  *)
    echo "org-view-image: not an image (png, jpg, gif, svg, webp): $image" >&2
    exit 2
    ;;
esac

chafa --format "$protocol" "$image" || echo "org-view-image: chafa could not draw $image" >&2
printf '\n%s: press Enter to close\n' "$(basename -- "$image")"
read -r _ || true
