#!/usr/bin/env bash
set -uo pipefail

DIAGNOSTIC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$DIAGNOSTIC_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0' || exit 1

score=0
pass_area() { printf 'PASS  %-12s %s\n' "$1" "$2"; score=$((score + 10)); }
fail_area() { printf 'FAIL  %-12s %s\n' "$1" "$2"; }

if [[ -f "$ROOT_DIR/learner-state/week-00-placement/kinds.txt" ]] && diff -q "$DIAGNOSTIC_DIR/fixtures/expected-kinds.txt" "$ROOT_DIR/learner-state/week-00-placement/kinds.txt" >/dev/null 2>&1; then
  pass_area 'area-01' 'shell pipeline output is exact'
else
  fail_area 'area-01' 'kinds.txt is missing or incorrect'
fi

yaml_ready="$(lab_kubectl -n week0-diagnostic get pod yaml-proof -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
yaml_label="$(lab_kubectl -n week0-diagnostic get pod yaml-proof -o jsonpath='{.metadata.labels.diagnostic}' 2>/dev/null || true)"
yaml_image="$(lab_kubectl -n week0-diagnostic get pod yaml-proof -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || true)"
if [[ "$yaml_ready" == 'True' && "$yaml_label" == 'yaml' && "$yaml_image" == *@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85 ]]; then
  pass_area 'area-02' 'yaml-proof is Ready and matches the contract'
else
  fail_area 'area-02' 'yaml-proof is absent, unready, or does not match the contract'
fi

web_available="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
web_image="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [[ "$web_available" == '3' && "$web_image" == *@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85 ]]; then
  pass_area 'area-04' 'web has three available replicas and the pinned image'
else
  fail_area 'area-04' 'web replicas or image are incorrect'
fi

service_selector="$(lab_kubectl -n week0-diagnostic get service web -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)"
ready_endpoints="$(lab_kubectl -n week0-diagnostic get endpointslice -l kubernetes.io/service-name=web -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' 2>/dev/null || true)"
if [[ "$service_selector" == 'diagnostic-web' && -n "$ready_endpoints" ]] && lab_kubectl get --raw '/api/v1/namespaces/week0-diagnostic/services/http:web:80/proxy/healthz' >/dev/null 2>&1; then
  pass_area 'area-05' 'Service selector, endpoints, and HTTP are healthy'
else
  fail_area 'area-05' 'Service routing is not healthy'
fi

mode="$(lab_kubectl -n week0-diagnostic get configmap app-config -o jsonpath='{.data.MODE}' 2>/dev/null || true)"
mode_ref="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].valueFrom.configMapKeyRef.name}' 2>/dev/null || true)"
mode_key="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].valueFrom.configMapKeyRef.key}' 2>/dev/null || true)"
if [[ "$mode" == 'diagnostic' && "$mode_ref" == 'app-config' && "$mode_key" == 'MODE' ]]; then
  pass_area 'area-06' 'ConfigMap value and Deployment reference are correct'
else
  fail_area 'area-06' 'ConfigMap value or Deployment reference is incorrect'
fi

token="$(lab_kubectl -n week0-diagnostic get secret api-credentials -o jsonpath='{.data.token}' 2>/dev/null | base64 --decode 2>/dev/null || true)"
secret_ref="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="API_TOKEN")].valueFrom.secretKeyRef.name}' 2>/dev/null || true)"
secret_key="$(lab_kubectl -n week0-diagnostic get deployment web -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="API_TOKEN")].valueFrom.secretKeyRef.key}' 2>/dev/null || true)"
if [[ "$token" == 'ready' && "$secret_ref" == 'api-credentials' && "$secret_key" == 'token' ]]; then
  pass_area 'area-07' 'Secret value and Deployment reference are correct'
else
  fail_area 'area-07' 'Secret value or Deployment reference is incorrect'
fi

scheduled_ready="$(lab_kubectl -n week0-diagnostic get pod scheduled -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
node_label="$(lab_kubectl get node -l diagnostic-ready=true -o name 2>/dev/null || true)"
if [[ "$scheduled_ready" == 'True' && -n "$node_label" ]]; then
  pass_area 'area-08' 'scheduled Pod is Ready on a correctly labeled node'
else
  fail_area 'area-08' 'scheduled Pod is not Ready or the required label is absent'
fi

pvc_phase="$(lab_kubectl -n week0-diagnostic get pvc work-data -o jsonpath='{.status.phase}' 2>/dev/null || true)"
storage_ready="$(lab_kubectl -n week0-diagnostic get pod storage-check -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
storage_claim="$(lab_kubectl -n week0-diagnostic get pod storage-check -o jsonpath='{.spec.volumes[?(@.name=="data")].persistentVolumeClaim.claimName}' 2>/dev/null || true)"
storage_mount="$(lab_kubectl -n week0-diagnostic get pod storage-check -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="data")].mountPath}' 2>/dev/null || true)"
if [[ "$pvc_phase" == 'Bound' && "$storage_ready" == 'True' && "$storage_claim" == 'work-data' && "$storage_mount" == '/data' ]]; then
  pass_area 'area-09' 'PVC is Bound and storage-check mounts it at /data'
else
  fail_area 'area-09' 'PVC or storage-check contract is incomplete'
fi

printf '\nAUTOMATED_SCORE=%d/80\n' "$score"
echo 'MANUAL_SCORE_REQUIRED=areas-03-and-10/20'
echo 'Complete learner-state/week-00-placement/SCORECARD.md; this diagnostic does not auto-declare readiness.'
