#!/usr/bin/env bash
set -uo pipefail

LAB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WEEK_DIR="$(cd -- "$LAB_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$LAB_DIR/../../../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0' || exit 1

snapshot_dir="$(mktemp -d)"
trap 'rm -rf "$snapshot_dir"' EXIT

capture() {
  local output_name="$1"
  shift
  if ! lab_kubectl "$@" -o json >"$snapshot_dir/$output_name.json" 2>/dev/null; then
    printf '{}\n' >"$snapshot_dir/$output_name.json"
  fi
}

capture namespace get namespace week1-objects
capture deployment -n week1-objects get deployment object-web
capture service -n week1-objects get service object-web
capture endpoint_slices -n week1-objects get endpointslice -l kubernetes.io/service-name=object-web
printf '{}\n' >"$snapshot_dir/pod.json"

grader_args=(--mode objects --snapshot-dir "$snapshot_dir")
for _ in $(seq 1 10); do
  if lab_kubectl get --raw '/api/v1/namespaces/week1-objects/services/http:object-web:80/proxy/healthz' >/dev/null 2>&1; then
    grader_args+=(--http-ok)
    break
  fi
  sleep 1
done

python3 "$WEEK_DIR/grader.py" "${grader_args[@]}"
