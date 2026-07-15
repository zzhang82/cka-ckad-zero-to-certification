#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fake_root="$tmp/repo"
mkdir -p \
  "$fake_root/_project/scripts/learner" \
  "$fake_root/_project/templates/private-week" \
  "$fake_root/weeks/week-00"
cp "$ROOT_DIR/study" "$fake_root/study"
cp "$ROOT_DIR/_project/scripts/learner/study.sh" "$fake_root/_project/scripts/learner/study.sh"
cp "$ROOT_DIR/_project/templates/private-week/"*.md "$fake_root/_project/templates/private-week/"
cp "$ROOT_DIR/.gitignore" "$fake_root/.gitignore"
printf '# fixture\n' >"$fake_root/weeks/week-00/README.md"
printf '# fixture\n' >"$fake_root/weeks/week-00/RESOURCES.md"

git -C "$fake_root" init -q
bash "$fake_root/study" init --profile rusty >/dev/null
test -f "$fake_root/learner-state/weeks/week-00/PLAN.md"

if bash "$fake_root/study" status unexpected >/dev/null 2>&1; then
  echo 'FAIL  study status accepted a surplus argument' >&2
  exit 1
fi

touch "$fake_root/learner-state/tracked.txt"
git -C "$fake_root" add -f learner-state/tracked.txt
if bash "$fake_root/study" status >/dev/null 2>&1; then
  echo 'FAIL  study accepted a tracked learner-state file' >&2
  exit 1
fi
git -C "$fake_root" reset -q -- learner-state/tracked.txt
rm -f "$fake_root/learner-state/tracked.txt"

touch "$fake_root/.state/tracked.txt"
git -C "$fake_root" add -f .state/tracked.txt
if bash "$fake_root/study" status >/dev/null 2>&1; then
  echo 'FAIL  study accepted a tracked .state file' >&2
  exit 1
fi
git -C "$fake_root" reset -q -- .state/tracked.txt
rm -f "$fake_root/.state/tracked.txt"

custom_home="$tmp/home"
mkdir -p "$custom_home"
printf 'export KUBECONFIG=/tmp/wrong-work-kubeconfig\nexport CKA_CKAD_STATE_DIR=/tmp/wrong-study-state\n' >"$custom_home/.bashrc"
shell_output="$(
  printf 'test "$KUBECONFIG" = "%s/.state/kubeconfig" && test "$CKA_CKAD_STATE_DIR" = "%s/.state" && echo HARDENED\nexit\n' "$fake_root" "$fake_root" \
    | HOME="$custom_home" bash "$fake_root/study" shell 2>&1
)"
grep -Fq HARDENED <<<"$shell_output"

echo 'PASS  learner CLI rejects surplus args and tracked private paths; study shell overrides a hostile bashrc'
