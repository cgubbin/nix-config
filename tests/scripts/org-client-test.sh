#!/usr/bin/env bash
set -euo pipefail

script=${1:?org-client.sh path required}
script=$(realpath -e -- "$script")
scratch=$(mktemp -d "${TMPDIR:-/tmp}/org-client-test.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
runtime="$scratch/runtime"
repo="$scratch/project"
outside="$scratch/outside"
stub="$scratch/emacsclient"
log="$scratch/client-args"
mkdir -p "$runtime" "$stub" "$repo" "$outside"
chmod 700 "$runtime"
git -C "$repo" init -q
mkdir -p "$repo/src"
printf 'first line\nsource line\n' > "$repo/src/main.c"
git -C "$repo" -c user.name=Org-Test -c user.email=org-test@example.invalid \
  add src/main.c
git -C "$repo" -c user.name=Org-Test -c user.email=org-test@example.invalid \
  commit -q -m fixture
commit=$(git -C "$repo" rev-parse HEAD)
printf 'uncommitted source line\n' >> "$repo/src/main.c"
printf '#!%s\n' "$BASH" > "$stub/emacsclient"
cat >> "$stub/emacsclient" <<'EOF'
printf '%s\n' "$*" >> "$ORG_CLIENT_TEST_LOG"
EOF
chmod +x "$stub/emacsclient"
export HOME="$scratch/home"
export XDG_RUNTIME_DIR="$runtime"
export ORG_CLIENT_TEST_LOG="$log"
mkdir -p "$HOME"

run_launcher() (
  # The sourced production script consumes these shell variables.
  # shellcheck disable=SC2034
  local action=$1
  shift
  # shellcheck disable=SC2034
  local client="$stub/emacsclient"
  # shellcheck disable=SC2034
  local terminalClient=true
  # These stubs are invoked by the sourced production script.
  # shellcheck disable=SC2329
  systemctl() { return 0; }
  # shellcheck disable=SC2329
  timeout() { shift; "$@"; }
  cd "$2"
  shift 2 || true
  # shellcheck disable=SC1090
  source "$script" "$@"
)

if run_launcher project-todo ignored "$outside" 2>"$scratch/outside-error"; then
  echo "project-todo unexpectedly accepted a directory outside Git" >&2
  exit 1
fi
grep -F 'run this command inside a Git project' "$scratch/outside-error" >/dev/null

run_launcher project-todo ignored "$repo"
run_launcher project-agenda ignored "$repo"
run_launcher project-capture ignored "$repo" src/main.c 17
grep -F -- '--frame-parameters=' "$log" >/dev/null
grep -F 'project-todo' "$log" >/dev/null
grep -F 'project-agenda' "$log" >/dev/null
grep -F 'src/main.c' "$log" >/dev/null
grep -F '17' "$log" >/dev/null
grep -F "$repo" "$log" >/dev/null
if grep -F 'blob/' "$log" >/dev/null; then
  echo "a local repository unexpectedly received a remote permalink" >&2
  exit 1
fi

: > "$log"
git -C "$repo" remote add origin git@github.com:kit/private.git
run_launcher project-capture ignored "$repo" src/main.c 17
grep -F "https://github.com/kit/private/blob/$commit/src/main.c#L17" "$log" >/dev/null

: > "$log"
git -C "$repo" remote set-url origin "file://$scratch/private.git"
run_launcher project-capture ignored "$repo" src/main.c 17
if grep -F 'blob/' "$log" >/dev/null; then
  echo "a local file remote unexpectedly received a GitHub permalink" >&2
  exit 1
fi
