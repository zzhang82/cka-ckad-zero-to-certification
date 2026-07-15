#!/usr/bin/env bash
set -euo pipefail

DIAGNOSTIC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$DIAGNOSTIC_DIR/../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'

lab_kubectl label node --all diagnostic-ready- >/dev/null 2>&1 || true
lab_kubectl delete namespace week0-diagnostic --ignore-not-found --wait=true --timeout=120s
