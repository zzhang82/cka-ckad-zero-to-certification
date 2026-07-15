#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$LAB_DIR/../../.." && pwd)"
source "$ROOT_DIR/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'

fail() {
  echo "FAIL  $*" >&2
  exit 1
}

[[ "$(lab_kubectl -n week0-smoke get deployment web -o jsonpath='{.status.availableReplicas}')" == '2' ]] || fail 'Deployment web does not have two available replicas'

ready_endpoints="$(lab_kubectl -n week0-smoke get endpointslice -l kubernetes.io/service-name=web -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}')"
[[ -n "$ready_endpoints" ]] || fail 'Service web has no ready endpoint'

for _ in $(seq 1 20); do
  if lab_kubectl get --raw '/api/v1/namespaces/week0-smoke/services/http:web:80/proxy/healthz' >/dev/null 2>&1; then
    echo 'PASS  Week 0 smoke lab: replicas, Service endpoints, and HTTP traffic are healthy'
    exit 0
  fi
  sleep 1
done

fail 'HTTP request through the Service proxy did not succeed'
