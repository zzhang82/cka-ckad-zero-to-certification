#!/usr/bin/env bash
set -euo pipefail

DIAGNOSTIC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$DIAGNOSTIC_DIR/../../.." && pwd)"
source "$ROOT_DIR/_project/scripts/environment/lab-guard.sh"
require_project_context 'kind-cka-ckad-week0' 'cka-ckad-week0'

lab_kubectl label node --all diagnostic-ready- >/dev/null 2>&1 || true
lab_kubectl delete namespace week0-diagnostic --ignore-not-found --wait=true --timeout=120s
lab_kubectl apply -f "$DIAGNOSTIC_DIR/manifest.yaml"

evidence_dir="${CKA_CKAD_PLACEMENT_EVIDENCE_DIR:-$ROOT_DIR/learner-state/weeks/week-00/placement}"
mkdir -p "$evidence_dir"
if [[ ! -f "$evidence_dir/SCORECARD.md" ]]; then
  cp "$DIAGNOSTIC_DIR/SCORECARD_TEMPLATE.md" "$evidence_dir/SCORECARD.md"
fi
cp "$DIAGNOSTIC_DIR/fixtures/objects.txt" "$evidence_dir/objects.txt"
echo "Placement diagnostic seeded. Start the 90-minute timer now."
