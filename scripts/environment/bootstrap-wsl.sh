#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/environments/versions.env"

[[ "$(uname -s)" == "Linux" ]] || { echo 'This bootstrap supports Linux/WSL only.' >&2; exit 1; }
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

for tool in curl sha256sum tar sudo install awk grep; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

echo "Installing kubectl $KUBECTL_VERSION"
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl"
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl.sha256"
printf '%s  kubectl\n' "$(cat kubectl.sha256)" | sha256sum --check --status
sudo install -m 0755 kubectl /usr/local/bin/kubectl

echo "Installing kind $KIND_VERSION"
curl -fsSL -o kind-linux-amd64 "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
curl -fsSL -o kind-linux-amd64.sha256sum "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64.sha256sum"
sha256sum --check --status kind-linux-amd64.sha256sum
sudo install -m 0755 kind-linux-amd64 /usr/local/bin/kind

echo "Installing Helm $HELM_VERSION"
helm_archive="helm-${HELM_VERSION}-linux-${arch}.tar.gz"
curl -fsSLO "https://get.helm.sh/${helm_archive}"
curl -fsSLO "https://get.helm.sh/${helm_archive}.sha256sum"
sha256sum --check --status "${helm_archive}.sha256sum"
tar -xzf "$helm_archive"
sudo install -m 0755 "linux-${arch}/helm" /usr/local/bin/helm

echo "Installing Helm 3 compatibility binary $HELM3_VERSION"
helm3_archive="helm-${HELM3_VERSION}-linux-${arch}.tar.gz"
curl -fsSLO "https://get.helm.sh/${helm3_archive}"
curl -fsSLO "https://get.helm.sh/${helm3_archive}.sha256sum"
sha256sum --check --status "${helm3_archive}.sha256sum"
rm -rf "linux-${arch}"
tar -xzf "$helm3_archive"
sudo install -m 0755 "linux-${arch}/helm" /usr/local/bin/helm3

echo "Installing yq $YQ_VERSION"
curl -fsSL -o yq_linux_amd64 "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
curl -fsSL -o yq-checksums-bsd "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/checksums-bsd"
yq_sha256="$(awk '/^SHA256 \(yq_linux_amd64\)/ {print $4}' yq-checksums-bsd)"
[[ "$yq_sha256" =~ ^[0-9a-f]{64}$ ]] || { echo 'Unable to extract yq SHA256.' >&2; exit 1; }
printf '%s  yq_linux_amd64\n' "$yq_sha256" | sha256sum --check --status
sudo install -m 0755 yq_linux_amd64 /usr/local/bin/yq

echo 'Installed versions:'
kubectl version --client
kind version
helm version --short
helm3 version --short
yq --version
