#!/usr/bin/env bash
set -euo pipefail

script=${1:?org-view-image.sh path required}
script=$(realpath -e -- "$script")
scratch=$(mktemp -d "${TMPDIR:-/tmp}/org-view-image-test.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
mockbin="$scratch/bin"
log="$scratch/chafa-args"
image="$scratch/a figure.png"
mkdir -p "$mockbin"
printf 'png' > "$image"
printf 'text' > "$scratch/notes.txt"
cat > "$mockbin/chafa" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$MOCK_CHAFA_LOG"
EOF
chmod +x "$mockbin/chafa"

# Same shell options as writeShellApplication.
run() { MOCK_CHAFA_LOG="$log" PATH="$mockbin:$PATH" bash -euo pipefail "$script" "$@"; }
expect_usage_error() {
  if run "$@" < /dev/null > /dev/null 2>&1; then
    echo "expected exit 2 for: $*" >&2
    exit 1
  else
    status=$?
    [[ $status -eq 2 ]] || { echo "expected exit 2, got $status for: $*" >&2; exit 1; }
  fi
}

expect_usage_error
expect_usage_error sixels
expect_usage_error bogus "$image"
expect_usage_error sixels "$scratch/missing.png"
expect_usage_error sixels "$scratch/notes.txt"
[[ ! -e "$log" ]] || { echo "chafa ran for an invalid call" >&2; exit 1; }

# A valid call passes the protocol and the resolved path (spaces kept) to chafa, then waits for a
# line on stdin before exiting.
output=$(printf '\n' | run sixels "$image")
mapfile -t args < "$log"
[[ "${args[*]}" == "--format sixels $image" && ${#args[@]} -eq 3 ]] || {
  echo "unexpected chafa arguments: ${args[*]}" >&2
  exit 1
}
[[ "$output" == *"a figure.png: press Enter to close"* ]] || { echo "no close hint: $output" >&2; exit 1; }

# End of input also ends the wait.
run kitty "$image" < /dev/null > /dev/null
mapfile -t args < "$log"
[[ "${args[1]}" == kitty ]] || { echo "protocol not passed: ${args[*]}" >&2; exit 1; }

echo "org-view-image tests passed"
