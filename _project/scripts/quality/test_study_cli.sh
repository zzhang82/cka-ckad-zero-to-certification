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
  "$fake_root/_project/templates/private-week" \
  "$fake_root/weeks/week-00"
cp "$ROOT_DIR/study" "$fake_root/study"
cp "$ROOT_DIR/_project/scripts/learner/study.sh" "$fake_root/_project/scripts/learner/study.sh"
cp "$ROOT_DIR/_project/templates/private-week/"*.md "$fake_root/_project/templates/private-week/"
cp "$ROOT_DIR/.gitignore" "$fake_root/.gitignore"
printf '# fixture\n' >"$fake_root/weeks/week-00/README.md"
printf '# fixture\n' >"$fake_root/weeks/week-00/RESOURCES.md"
for action in seed grade reset; do
  cat >"$fake_root/_project/diagnostics/week0-placement/$action.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR"
EOF
done

git -C "$fake_root" init -q
git -C "$fake_root" config user.name 'Study CLI Test'
git -C "$fake_root" config user.email 'study-cli@example.invalid'
git -C "$fake_root" add .
git -C "$fake_root" commit -qm 'fixture'

bash "$fake_root/study" init --profile rusty >/dev/null
test -f "$fake_root/learner-state/weeks/week-00/PLAN.md"
test -z "$(git -C "$fake_root" status --porcelain)"

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

git -C "$external_repo" add journal
CKA_CKAD_LEARNER_DIR="$external_relative" bash "$fake_root/study" status >/dev/null

python3 - "$external_dir/cka-ckad-study.code-workspace" "$fake_root" "$external_dir/weeks/week-00" <<'PY'
import json
import sys

workspace = json.load(open(sys.argv[1], encoding="utf-8"))
paths = [folder["path"] for folder in workspace["folders"]]
assert paths == [sys.argv[2], sys.argv[3]], paths
PY

if CKA_CKAD_LEARNER_DIR='unsafe-internal' bash "$fake_root/study" status >/dev/null 2>&1; then
  echo 'FAIL  study accepted an unignored internal learner workspace' >&2
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
