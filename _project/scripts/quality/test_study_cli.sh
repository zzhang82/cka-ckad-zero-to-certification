#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fake_root="$tmp/repo"
mkdir -p \
  "$fake_root/_project/scripts/learner" \
  "$fake_root/_project/diagnostics/week0-placement" \
  "$fake_root/_project/labs/shared/week0-smoke" \
  "$fake_root/_project/labs/cka/week1/objects" \
  "$fake_root/_project/labs/cka/week1/debug" \
  "$fake_root/_project/labs/cka/week1/sprint" \
  "$fake_root/_project/templates/private-week" \
  "$fake_root/weeks/week-00" \
  "$fake_root/weeks/week-01"
cp "$ROOT_DIR/study" "$fake_root/study"
cp "$ROOT_DIR/_project/scripts/learner/study.sh" "$fake_root/_project/scripts/learner/study.sh"
cp "$ROOT_DIR/_project/templates/private-week/"*.md "$fake_root/_project/templates/private-week/"
cp "$ROOT_DIR/.gitignore" "$fake_root/.gitignore"
printf '# fixture\n' >"$fake_root/weeks/week-00/README.md"
printf '# fixture\n' >"$fake_root/weeks/week-00/RESOURCES.md"
printf '# fixture\n' >"$fake_root/weeks/week-01/README.md"
printf '# fixture\n' >"$fake_root/weeks/week-01/RESOURCES.md"
for action in seed grade reset; do
  cat >"$fake_root/_project/diagnostics/week0-placement/$action.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR"
EOF
done

for target in shared/week0-smoke cka/week1/objects cka/week1/debug cka/week1/sprint; do
  for action in seed grade reset; do
    cat >"$fake_root/_project/labs/$target/$action.sh" <<EOF
#!/usr/bin/env bash
printf '%s\n' '_project/labs/$target/$action.sh'
EOF
  done
done

git -C "$fake_root" init -q
git -C "$fake_root" config user.name 'Study CLI Test'
git -C "$fake_root" config user.email 'study-cli@example.invalid'
git -C "$fake_root" add .
git -C "$fake_root" commit -qm 'fixture'

for help_command in help -h --help; do
  help_output="$(bash "$fake_root/study" "$help_command")"
  for expected_target in \
    'bash ./study init --profile {beginner|rusty|operator}' \
    'bash ./study open {week-00..week-12} [--code]' \
    'bash ./study status' \
    'bash ./study shell' \
    'bash ./study doctor {windows|wsl} [--preflight|--ready]' \
    'bash ./study tools bootstrap' \
    'bash ./study env {up|status|reset|down|evidence} {week0-single|shared-multinode}' \
    'bash ./study lab {seed|grade|reset} week0-smoke' \
    'bash ./study lab {seed|grade|reset} week1-objects' \
    'bash ./study lab {seed|grade|reset} week1-debug' \
    'bash ./study diagnostic {seed|grade|reset} week0-placement' \
    'bash ./study diagnostic {seed|grade|reset} week1-sprint'; do
    grep -Fq "$expected_target" <<<"$help_output"
  done
done

bash "$fake_root/study" init --profile rusty >/dev/null
test -f "$fake_root/learner-state/weeks/week-00/PLAN.md"
test -z "$(git -C "$fake_root" status --porcelain)"

week_one_output="$(bash "$fake_root/study" open week-01)"
grep -Fq 'Week:          week-01' <<<"$week_one_output"
test -f "$fake_root/learner-state/weeks/week-01/PLAN.md"
test "$(<"$fake_root/learner-state/current-week")" = 'week-01'

set +e
bash "$fake_root/study" status unexpected >/dev/null 2>&1
usage_exit_code=$?
set -e
if [[ "$usage_exit_code" -ne 2 ]]; then
  echo "FAIL  study usage error exited $usage_exit_code instead of 2" >&2
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

external_repo="$tmp/private companion"
external_dir="$external_repo/journal"
mkdir -p "$external_repo"
git -C "$external_repo" init -q
git -C "$external_repo" config user.name 'Private Companion Test'
git -C "$external_repo" config user.email 'private-companion@example.invalid'

external_relative='../private companion/journal'
CKA_CKAD_LEARNER_DIR="$external_relative" bash "$fake_root/study" init --profile operator >/dev/null
test -f "$external_dir/profile.yaml"
test -f "$external_dir/weeks/week-00/PLAN.md"
grep -Fqx 'profile: operator' "$external_dir/profile.yaml"
grep -Fqx 'profile: rusty' "$fake_root/learner-state/profile.yaml"
test -d "$fake_root/.state"
test -z "$(git -C "$fake_root" status --porcelain)"

diagnostic_output="$(
  CKA_CKAD_LEARNER_DIR="$external_relative" \
    bash "$fake_root/study" diagnostic seed week0-placement
)"
test "$diagnostic_output" = "$external_dir/weeks/week-00/placement"

for action in seed grade reset; do
  test "$(bash "$fake_root/study" lab "$action" week0-smoke)" = \
    "_project/labs/shared/week0-smoke/$action.sh"
  test "$(bash "$fake_root/study" lab "$action" week1-objects)" = \
    "_project/labs/cka/week1/objects/$action.sh"
  test "$(bash "$fake_root/study" lab "$action" week1-debug)" = \
    "_project/labs/cka/week1/debug/$action.sh"
  test "$(bash "$fake_root/study" diagnostic "$action" week1-sprint)" = \
    "_project/labs/cka/week1/sprint/$action.sh"
done

git -C "$external_repo" add journal
CKA_CKAD_LEARNER_DIR="$external_relative" bash "$fake_root/study" status >/dev/null

python3 - "$external_dir/cka-ckad-study.code-workspace" "$fake_root" "$external_dir/weeks/week-00" <<'PY'
import json
import sys

workspace = json.load(open(sys.argv[1], encoding="utf-8"))
paths = [folder["path"] for folder in workspace["folders"]]
assert paths == [sys.argv[2], sys.argv[3]], paths
PY

mkdir -p "$fake_root/unsafe-internal"
printf 'profile: PRIVATE_STATUS_MARKER\n' >"$fake_root/unsafe-internal/profile.yaml"
printf 'PRIVATE_STATUS_MARKER\n' >"$fake_root/unsafe-internal/current-week"
set +e
unsafe_status_output="$(
  CKA_CKAD_LEARNER_DIR='unsafe-internal' bash "$fake_root/study" status 2>&1
)"
unsafe_status_exit_code=$?
set -e
if [[ "$unsafe_status_exit_code" -eq 0 ]]; then
  echo 'FAIL  study accepted an unignored internal learner workspace' >&2
  exit 1
fi
if grep -Fq PRIVATE_STATUS_MARKER <<<"$unsafe_status_output"; then
  echo 'FAIL  study leaked private status content before rejecting an unsafe workspace' >&2
  exit 1
fi

printf '/custom-private/\n' >>"$fake_root/.git/info/exclude"
CKA_CKAD_LEARNER_DIR='custom-private' bash "$fake_root/study" init --profile beginner >/dev/null
test -f "$fake_root/custom-private/profile.yaml"
grep -Fqx 'profile: beginner' "$fake_root/custom-private/profile.yaml"

ln -s "$fake_root/unsafe-symlink-target" "$tmp/external-looking-link"
if CKA_CKAD_LEARNER_DIR="$tmp/external-looking-link" bash "$fake_root/study" status >/dev/null 2>&1; then
  echo 'FAIL  study accepted a symlink that resolves into an unsafe internal workspace' >&2
  exit 1
fi

for unsafe_dir in '.' '.git/learner' '.state/learner' '..' '/'; do
  if CKA_CKAD_LEARNER_DIR="$unsafe_dir" bash "$fake_root/study" status >/dev/null 2>&1; then
    echo "FAIL  study accepted unsafe learner workspace: $unsafe_dir" >&2
    exit 1
  fi
done

ln -s "$fake_root" "$tmp/public-repo-link"
if CKA_CKAD_LEARNER_DIR='unsafe-through-public-link' \
  bash "$tmp/public-repo-link/study" status >/dev/null 2>&1; then
  echo 'FAIL  study misclassified an unsafe internal path through a public-repository symlink' >&2
  exit 1
fi

custom_home="$tmp/home"
mkdir -p "$custom_home"
printf 'export KUBECONFIG=/tmp/wrong-work-kubeconfig\nexport CKA_CKAD_STATE_DIR=/tmp/wrong-study-state\nexport CKA_CKAD_LEARNER_DIR=/tmp/wrong-learner-state\nexport CKA_CKAD_PLACEMENT_EVIDENCE_DIR=/tmp/wrong-placement-state\n' >"$custom_home/.bashrc"
shell_output="$(
  printf 'test "$KUBECONFIG" = "%s/.state/kubeconfig" && test "$CKA_CKAD_STATE_DIR" = "%s/.state" && test "$CKA_CKAD_LEARNER_DIR" = "%s" && test "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR" = "%s/weeks/week-00/placement" && echo HARDENED\nexit\n' "$fake_root" "$fake_root" "$external_dir" "$external_dir" \
    | HOME="$custom_home" CKA_CKAD_LEARNER_DIR="$external_relative" bash "$fake_root/study" shell 2>&1
)"
grep -Fq HARDENED <<<"$shell_output"

echo 'PASS  learner CLI preserves default behavior, supports safe external workspaces, and isolates runtime state'
