#!/usr/bin/env bash
set -euo pipefail

DIAGNOSTIC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$DIAGNOSTIC_DIR/../../.." && pwd)"
export CKA_CKAD_PLACEMENT_EVIDENCE_DIR="$ROOT_DIR/.state/placement-fixture-evidence"
export KUBECONFIG="$ROOT_DIR/.state/kubeconfig"
image='registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85'

cleanup() {
  bash "$DIAGNOSTIC_DIR/reset.sh" >/dev/null 2>&1 || true
  bash "$ROOT_DIR/_project/labs/shared/week0-smoke/reset.sh" >/dev/null 2>&1 || true
  bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single >/dev/null 2>&1 || true
  rm -rf "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR"
}
trap cleanup EXIT

run_smoke_cycle() {
  bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" up week0-single
  bash "$ROOT_DIR/_project/labs/shared/week0-smoke/seed.sh"
  bash "$ROOT_DIR/_project/labs/shared/week0-smoke/grade.sh"
  bash "$ROOT_DIR/_project/labs/shared/week0-smoke/reset.sh"
  bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single
}

bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single
run_smoke_cycle
run_smoke_cycle

bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" up week0-single
bash "$DIAGNOSTIC_DIR/seed.sh"
blank_output="$(bash "$DIAGNOSTIC_DIR/grade.sh")"
grep -Fq 'AUTOMATED_SCORE=0/80' <<<"$blank_output"

cp "$DIAGNOSTIC_DIR/fixtures/expected-kinds.txt" "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR/kinds.txt"
kubectl -n week0-diagnostic run yaml-proof \
  --image="$image" \
  --labels=diagnostic=yaml \
  --command -- /agnhost pause

kubectl -n week0-diagnostic set image deployment/web "web=$image"
kubectl -n week0-diagnostic scale deployment/web --replicas=3
kubectl -n week0-diagnostic patch service web --type=merge \
  -p '{"spec":{"selector":{"app":"diagnostic-web"}}}'
kubectl -n week0-diagnostic create configmap app-config \
  --from-literal=MODE=diagnostic \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n week0-diagnostic create secret generic api-credentials \
  --from-literal=token=ready
kubectl -n week0-diagnostic set env deployment/web --from=configmap/app-config
kubectl -n week0-diagnostic patch deployment web --type=strategic \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"web","env":[{"name":"API_TOKEN","valueFrom":{"secretKeyRef":{"name":"api-credentials","key":"token"}}}]}]}}}}'
kubectl label node --all diagnostic-ready=true --overwrite

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: work-data
  namespace: week0-diagnostic
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 64Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: storage-check
  namespace: week0-diagnostic
spec:
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: work-data
  containers:
    - name: storage
      image: $image
      args: [pause]
      volumeMounts:
        - name: data
          mountPath: /data
EOF

kubectl -n week0-diagnostic rollout status deployment/web --timeout=180s
kubectl -n week0-diagnostic wait --for=condition=Ready pod/yaml-proof pod/scheduled pod/storage-check --timeout=180s

golden_output="$(bash "$DIAGNOSTIC_DIR/grade.sh")"
printf '%s\n' "$golden_output"
grep -Fq 'AUTOMATED_SCORE=80/80' <<<"$golden_output"

bash "$DIAGNOSTIC_DIR/reset.sh"
rm -f "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR/kinds.txt"
post_reset_output="$(bash "$DIAGNOSTIC_DIR/grade.sh")"
grep -Fq 'AUTOMATED_SCORE=0/80' <<<"$post_reset_output"

bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single
rm -rf "$CKA_CKAD_PLACEMENT_EVIDENCE_DIR"
trap - EXIT

echo 'PASS  two clean lifecycles, blank/golden/post-reset placement states, and scoped teardown'
