#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Source this file instead of executing it: source $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

export CKA_CKAD_STATE_DIR="$ROOT_DIR/.state"
export KUBECONFIG="${CKA_CKAD_STATE_DIR}/kubeconfig"
mkdir -p "$CKA_CKAD_STATE_DIR"

alias k=kubectl
if command -v kubectl >/dev/null 2>&1; then
  # kubectl emits the completion script at runtime.
  # shellcheck disable=SC1090
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl k
fi

printf 'Exam-mode shell ready. KUBECONFIG=%s\n' "$KUBECONFIG"
