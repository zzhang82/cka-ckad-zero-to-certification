#!/usr/bin/env bash

# Source this file from lab scripts. It pins kubectl to the project kubeconfig and
# refuses destructive or mutating work unless the declared kind cluster is the
# current project context.

require_project_context() {
  local expected_context="$1"
  local expected_cluster="$2"

  export CKA_CKAD_STATE_DIR="${HOME}/.local/state/cka-ckad-lab"
  export KUBECONFIG="${CKA_CKAD_STATE_DIR}/kubeconfig"
  export CKA_CKAD_EXPECTED_CONTEXT="$expected_context"

  command -v kubectl >/dev/null 2>&1 || { echo 'REFUSE  kubectl is unavailable' >&2; return 1; }
  command -v kind >/dev/null 2>&1 || { echo 'REFUSE  kind is unavailable' >&2; return 1; }
  [[ -f "$KUBECONFIG" ]] || { echo "REFUSE  project kubeconfig is missing: $KUBECONFIG" >&2; return 1; }
  kind get clusters 2>/dev/null | grep -Fxq "$expected_cluster" || {
    echo "REFUSE  expected project cluster is absent: $expected_cluster" >&2
    return 1
  }

  local current_context
  current_context="$(kubectl --kubeconfig "$KUBECONFIG" config current-context 2>/dev/null || true)"
  [[ "$current_context" == "$expected_context" ]] || {
    echo "REFUSE  project kubeconfig context is '$current_context'; expected '$expected_context'" >&2
    return 1
  }
}

lab_kubectl() {
  kubectl --kubeconfig "$KUBECONFIG" --context "$CKA_CKAD_EXPECTED_CONTEXT" "$@"
}
