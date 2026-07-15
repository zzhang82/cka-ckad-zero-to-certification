#!/usr/bin/env bash
set -uo pipefail

MODE="${1:---preflight}"
if [[ "$MODE" != "--preflight" && "$MODE" != "--ready" ]]; then
  echo "Usage: $0 [--preflight|--ready]" >&2
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/environments/versions.env"

failures=0
warnings=0
pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] && pass "Ubuntu ${VERSION_ID:-unknown}" || warn "Expected Ubuntu; found ${PRETTY_NAME:-unknown}"
else
  fail '/etc/os-release is unreadable'
fi

if [[ "$(ps -p 1 -o comm= 2>/dev/null | xargs)" == "systemd" ]]; then pass 'systemd is PID 1'; else fail 'systemd is not PID 1'; fi
if [[ "$(stat -fc %T /sys/fs/cgroup 2>/dev/null)" == "cgroup2fs" ]]; then pass 'cgroup v2 active'; else fail 'cgroup v2 not active'; fi

cpus="$(nproc 2>/dev/null || echo 0)"
mem_gib="$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 0)"
free_gib="$(df -Pk / 2>/dev/null | awk 'NR==2 {printf "%d", $4/1024/1024}')"
(( cpus >= 4 )) && pass "$cpus CPUs available" || fail "Only $cpus CPUs available"
(( mem_gib >= 8 )) && pass "${mem_gib} GiB memory available" || fail "Only ${mem_gib} GiB memory available"
(( free_gib >= 30 )) && pass "${free_gib} GiB filesystem space available" || warn "Only ${free_gib} GiB filesystem space available"

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    pass "Docker server $(docker info --format '{{.ServerVersion}}') reachable"
    pass "Docker context $(docker context show 2>/dev/null || echo default)"
  else
    fail 'Docker client exists but the native WSL server is unreachable'
  fi
else
  fail 'Docker is missing'
fi

check_tool() {
  local name="$1" expected="$2" actual="$3"
  if ! command -v "$name" >/dev/null 2>&1; then
    if [[ "$MODE" == "--ready" ]]; then fail "$name missing; expected $expected"; else warn "$name missing; bootstrap will install $expected"; fi
    return
  fi
  if [[ "$actual" == "$expected" ]]; then
    pass "$name $expected"
  elif [[ "$MODE" == "--ready" ]]; then
    fail "$name version mismatch; expected $expected; reported: ${actual:-unknown}"
  else
    warn "$name found but expected $expected; reported: ${actual:-unknown}"
  fi
}

check_tool kubectl "$KUBECTL_VERSION" "$(kubectl version --client 2>/dev/null | awk '/^Client Version:/ {print $3}' || true)"
check_tool kind "$KIND_VERSION" "$(kind version 2>/dev/null | awk '{print $2}' || true)"
check_tool helm "$HELM_VERSION" "$(helm version --template '{{.Version}}' 2>/dev/null || true)"
check_tool helm3 "$HELM3_VERSION" "$(helm3 version --template '{{.Version}}' 2>/dev/null || true)"
check_tool yq "$YQ_VERSION" "$(yq --version 2>/dev/null | awk '{print $NF}' || true)"

for tool in jq git python3 vim ssh curl wget sha256sum tar; do
  command -v "$tool" >/dev/null 2>&1 && pass "$tool available" || fail "$tool missing"
done

state_dir="${HOME}/.local/state/cka-ckad-lab"
mkdir -p "$state_dir"
[[ -w "$state_dir" ]] && pass "Project state directory writable: $state_dir" || fail "Project state directory not writable: $state_dir"

printf '\nPinned node image: %s\n' "$KIND_NODE_IMAGE"
printf 'Summary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
