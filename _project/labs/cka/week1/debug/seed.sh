#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$LAB_DIR/../../../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'

lab_kubectl delete namespace week1-debug --ignore-not-found --wait=true --timeout=120s
lab_kubectl apply -f "$LAB_DIR/seed.yaml"
echo 'READY  week1-debug contains an image failure and an independent Service selector failure'
