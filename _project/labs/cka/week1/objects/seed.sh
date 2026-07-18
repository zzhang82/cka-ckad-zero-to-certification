#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$LAB_DIR/../../../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'

lab_kubectl delete namespace week1-objects --ignore-not-found --wait=true --timeout=120s
lab_kubectl create namespace week1-objects
lab_kubectl label namespace week1-objects app.kubernetes.io/part-of=cka-ckad-week1
echo 'READY  week1-objects is clean; create the guided Deployment and Service'
