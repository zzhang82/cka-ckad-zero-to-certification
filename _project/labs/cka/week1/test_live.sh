#!/usr/bin/env bash
set -euo pipefail

WEEK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$WEEK_DIR/../../../.." && pwd)"
export KUBECONFIG="$ROOT_DIR/.state/kubeconfig"
context='kind-cka-ckad-week0'
sentinel_namespace='cka-ckad-week1-sentinel'

cleanup() {
  for target in objects debug sprint; do
    bash "$WEEK_DIR/$target/reset.sh" >/dev/null 2>&1 || true
  done
  kubectl --kubeconfig "$KUBECONFIG" --context "$context" \
    delete namespace "$sentinel_namespace" --ignore-not-found --wait=true --timeout=120s >/dev/null 2>&1 || true
  bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single >/dev/null 2>&1 || true
}
trap cleanup EXIT

expect_fail() {
  local target="$1"
  local output
  if output="$(bash "$WEEK_DIR/$target/grade.sh" 2>&1)"; then
    echo "FAIL  week1-$target grader accepted an invalid state" >&2
    return 1
  fi
  grep -Fq "RESULT=FAIL mode=$target" <<<"$output"
}

expect_pass() {
  local target="$1"
  local output
  output="$(bash "$WEEK_DIR/$target/grade.sh")"
  printf '%s\n' "$output"
  grep -Fq "RESULT=PASS mode=$target" <<<"$output"
}

apply_golden() {
  local target="$1"
  local deployment_name
  case "$target" in
    objects) deployment_name='object-web' ;;
    debug) deployment_name='debug-web' ;;
    sprint) deployment_name='sprint-web' ;;
  esac
  kubectl --kubeconfig "$KUBECONFIG" --context "$context" apply \
    -f "$WEEK_DIR/fixtures/$target-golden.yaml"
  kubectl --kubeconfig "$KUBECONFIG" --context "$context" \
    -n "week1-$target" rollout status "deployment/$deployment_name" --timeout=180s
}

bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single
bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" up week0-single
kubectl --kubeconfig "$KUBECONFIG" --context "$context" create namespace "$sentinel_namespace"
kubectl --kubeconfig "$KUBECONFIG" --context "$context" label namespace "$sentinel_namespace" \
  app.kubernetes.io/part-of=cka-ckad-week1

for target in objects debug sprint; do
  bash "$WEEK_DIR/$target/seed.sh"
  expect_fail "$target"
  apply_golden "$target"
  if [[ "$target" == sprint ]]; then
    kubectl --kubeconfig "$KUBECONFIG" --context "$context" \
      -n week1-sprint wait --for=condition=Ready pod/sprint-probe --timeout=180s
  fi
  expect_pass "$target"
  bash "$WEEK_DIR/$target/reset.sh"
  expect_fail "$target"
  if ! kubectl --kubeconfig "$KUBECONFIG" --context "$context" \
    get namespace "$sentinel_namespace" >/dev/null 2>&1; then
    echo "FAIL  week1-$target reset removed an unrelated project sentinel namespace" >&2
    exit 1
  fi
done

bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" down week0-single
if kind get clusters 2>/dev/null | grep -Fxq 'cka-ckad-week0'; then
  echo 'FAIL  Week 1 live test left the project cluster behind' >&2
  exit 1
fi
trap - EXIT

echo 'PASS  Week 1 blank/golden/post-reset states and scoped teardown for all three targets'
