#!/usr/bin/env bash
set -uo pipefail

DIAGNOSTIC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$DIAGNOSTIC_DIR/../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0' || exit 1

snapshot_dir="$(mktemp -d)"
trap 'rm -rf "$snapshot_dir"' EXIT
evidence_dir="${CKA_CKAD_PLACEMENT_EVIDENCE_DIR:-$ROOT_DIR/learner-state/weeks/week-00/placement}"

capture() {
  local output_name="$1"
  shift
  if ! lab_kubectl "$@" -o json >"$snapshot_dir/$output_name.json" 2>/dev/null; then
    printf '{}\n' >"$snapshot_dir/$output_name.json"
  fi
}

capture yaml_pod -n week0-diagnostic get pod yaml-proof
capture deployment -n week0-diagnostic get deployment web
capture service -n week0-diagnostic get service web
capture endpoint_slices -n week0-diagnostic get endpointslice -l kubernetes.io/service-name=web
capture configmap -n week0-diagnostic get configmap app-config
capture secret -n week0-diagnostic get secret api-credentials
capture scheduled_pod -n week0-diagnostic get pod scheduled
capture nodes get nodes
capture pvc -n week0-diagnostic get pvc work-data
capture storage_pod -n week0-diagnostic get pod storage-check

grader_args=(--snapshot-dir "$snapshot_dir")
if [[ -f "$evidence_dir/kinds.txt" ]] \
  && diff -q "$DIAGNOSTIC_DIR/fixtures/expected-kinds.txt" \
    "$evidence_dir/kinds.txt" >/dev/null 2>&1; then
  grader_args+=(--kinds-ok)
fi
if lab_kubectl get --raw '/api/v1/namespaces/week0-diagnostic/services/http:web:80/proxy/healthz' >/dev/null 2>&1; then
  grader_args+=(--http-ok)
fi

python3 "$DIAGNOSTIC_DIR/grader.py" "${grader_args[@]}"
