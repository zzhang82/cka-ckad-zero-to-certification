#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
tmp="$(mktemp -d)"
fake_root="$tmp/repo"
mkdir -p "$fake_root/_project/scripts/environment" "$fake_root/.state" "$tmp/bin"
cp "$ROOT_DIR/_project/scripts/environment/lab-guard.sh" "$fake_root/_project/scripts/environment/lab-guard.sh"
touch "$fake_root/.state/kubeconfig"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/bin/kind" <<'EOF'
#!/usr/bin/env bash
echo cka-ckad-week0
EOF

cat >"$tmp/bin/kubectl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_KUBECTL_LOG"
if [[ "$*" == *'config current-context'* ]]; then
  echo "${FAKE_CONTEXT:-unrelated-context}"
fi
EOF
chmod +x "$tmp/bin/kind" "$tmp/bin/kubectl"

export HOME="$tmp/home"
export PATH="$tmp/bin:$PATH"
export FAKE_KUBECTL_LOG="$tmp/kubectl.log"
source "$fake_root/_project/scripts/environment/lab-guard.sh"

export FAKE_CONTEXT='unrelated-context'
if require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0' 2>/dev/null; then
  echo 'FAIL  guard accepted the wrong context' >&2
  exit 1
fi

export FAKE_CONTEXT='kind-cka-ckad-week0'
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'
lab_kubectl get namespace week0-smoke
grep -Fq -- '--context kind-cka-ckad-week0 get namespace week0-smoke' "$FAKE_KUBECTL_LOG"
grep -Fq -- "--kubeconfig $fake_root/.state/kubeconfig" "$FAKE_KUBECTL_LOG"
echo 'PASS  target guard refuses a wrong context and injects explicit project targeting'
