#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
source "$ROOT_DIR/_project/environments/versions.env"

usage() {
  echo "Usage: $0 {up|status|reset|down|evidence} {week0-single|shared-multinode}" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
action="$1"
profile="$2"

case "$profile" in
  week0-single)
    cluster_name='cka-ckad-week0'
    config="$ROOT_DIR/_project/environments/kind/week0-single.yaml"
    ;;
  shared-multinode)
    cluster_name='cka-ckad-shared-multinode'
    config="$ROOT_DIR/_project/environments/kind/shared-multinode.yaml"
    ;;
  *) echo "Unknown profile: $profile" >&2; exit 2 ;;
esac

context="kind-${cluster_name}"

export CKA_CKAD_STATE_DIR="$ROOT_DIR/.state"
export KUBECONFIG="${CKA_CKAD_STATE_DIR}/kubeconfig"
mkdir -p "$CKA_CKAD_STATE_DIR"

require_ready() {
  bash "$SCRIPT_DIR/doctor-wsl.sh" --ready
}

project_kubectl() {
  kubectl --kubeconfig "$KUBECONFIG" --context "$context" "$@"
}

up() {
  require_ready
  if kind get clusters | grep -Fxq "$cluster_name"; then
    echo "Cluster already exists: $cluster_name"
  else
    kind create cluster --name "$cluster_name" --image "$KIND_NODE_IMAGE" --config "$config" --kubeconfig "$KUBECONFIG"
  fi
  project_kubectl wait --for=condition=Ready nodes --all --timeout=180s
  project_kubectl get nodes -o wide
}

down() {
  if command -v kind >/dev/null 2>&1 && kind get clusters | grep -Fxq "$cluster_name"; then
    kind delete cluster --name "$cluster_name" --kubeconfig "$KUBECONFIG"
  else
    echo "Cluster not present: $cluster_name"
  fi
}

status() {
  echo "Profile: $profile"
  echo "Cluster: $cluster_name"
  echo "Kubeconfig: $KUBECONFIG"
  if command -v kind >/dev/null 2>&1 && kind get clusters | grep -Fxq "$cluster_name"; then
    project_kubectl cluster-info
    project_kubectl get nodes -o wide
  else
    echo 'State: absent'
  fi
}

evidence() {
  echo "profile=$profile"
  echo "cluster=$cluster_name"
  echo "kubeconfig=$KUBECONFIG"
  echo "kubectl_expected=$KUBECTL_VERSION"
  echo "kind_expected=$KIND_VERSION"
  echo "node_image=$KIND_NODE_IMAGE"
  echo "helm_expected=$HELM_VERSION"
  echo "helm3_expected=$HELM3_VERSION"
  echo "yq_expected=$YQ_VERSION"
  docker version --format 'docker_client={{.Client.Version}} docker_server={{.Server.Version}}'
  status
}

case "$action" in
  up) up ;;
  status) status ;;
  reset) down; up ;;
  down) down ;;
  evidence) evidence ;;
  *) usage ;;
esac
