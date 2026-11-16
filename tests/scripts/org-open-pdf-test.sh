#!/usr/bin/env bash
set -euo pipefail

script=${1:?org-open-pdf.sh path required}
script=$(realpath -e -- "$script")
scratch=$(mktemp -d "${TMPDIR:-/tmp}/org-open-pdf-test.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
runtime="$scratch/runtime"
mockbin="$scratch/bin"
pdf="$scratch/a paper.pdf"
log="$scratch/zathura-args"
mkdir -p "$runtime" "$mockbin"
touch "$pdf"
chmod 700 "$runtime"
cat > "$mockbin/zathura" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$MOCK_ZATHURA_LOG"
EOF
chmod +x "$mockbin/zathura"

python3 - "$runtime/wayland-0" <<'PY'
import socket
import sys

listener = socket.socket(socket.AF_UNIX)
listener.bind(sys.argv[1])
listener.close()
PY

MOCK_ZATHURA_LOG="$log" PATH="$mockbin:$PATH" XDG_RUNTIME_DIR="$runtime" \
  WAYLAND_DISPLAY=wayland-0 DISPLAY='' bash "$script" "$pdf" 17
mapfile -t args < "$log"
[[ ${#args[@]} -eq 2 && ${args[0]} == --page=17 && ${args[1]} == "$pdf" ]]

if MOCK_ZATHURA_LOG="$log" PATH="$mockbin:$PATH" XDG_RUNTIME_DIR="$runtime" \
  WAYLAND_DISPLAY=wayland-0 bash "$script" "$pdf" 0 2>"$scratch/bad-page"; then
  echo "org-open-pdf accepted page zero" >&2
  exit 1
fi
grep -F 'page must be a positive integer' "$scratch/bad-page" >/dev/null

if MOCK_ZATHURA_LOG="$log" PATH="$mockbin:$PATH" XDG_RUNTIME_DIR="$runtime" \
  WAYLAND_DISPLAY=wayland-0 bash "$script" "$scratch/missing.pdf" 2>"$scratch/missing"; then
  echo "org-open-pdf accepted a missing PDF" >&2
  exit 1
fi
grep -F 'PDF does not exist' "$scratch/missing" >/dev/null

if MOCK_ZATHURA_LOG="$log" PATH="$mockbin:$PATH" XDG_RUNTIME_DIR="$runtime" \
  bash "$script" "$pdf" 2>"$scratch/no-display"; then
  echo "org-open-pdf launched without a graphical display" >&2
  exit 1
fi
grep -F 'no usable WSLg/graphical display' "$scratch/no-display" >/dev/null

if MOCK_ZATHURA_LOG="$log" PATH="$mockbin:$PATH" XDG_RUNTIME_DIR="$runtime" \
  WAYLAND_DISPLAY=missing-wayland bash "$script" "$pdf" 2>"$scratch/stale-display"; then
  echo "org-open-pdf accepted a stale Wayland socket" >&2
  exit 1
fi
grep -F 'no usable WSLg/graphical display' "$scratch/stale-display" >/dev/null

echo "org-open-pdf launcher tests passed"
