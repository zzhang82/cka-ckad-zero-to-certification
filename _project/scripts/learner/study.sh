#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
PRIVATE_DIR="$ROOT_DIR/learner-state"
STATE_DIR="$ROOT_DIR/.state"
TEMPLATE_DIR="$ROOT_DIR/_project/templates/private-week"

usage() {
  cat <<'EOF'
Usage:
  bash ./study init --profile {beginner|rusty|operator}
  bash ./study open week-00 [--code]
  bash ./study status
  bash ./study shell
  bash ./study doctor {windows|wsl} [--preflight|--ready]
  bash ./study tools bootstrap
  bash ./study env {up|status|reset|down|evidence} {week0-single|shared-multinode}
  bash ./study lab {seed|grade|reset} week0-smoke
  bash ./study diagnostic {seed|grade|reset} week0-placement
EOF
  exit 2
}

require_wsl() {
  [[ "$(uname -s 2>/dev/null)" == "Linux" ]] || {
    echo 'Run this command from the repository in WSL.' >&2
    exit 1
  }
}

assert_private_paths_ignored() {
  command -v git >/dev/null 2>&1 || { echo 'git is required.' >&2; exit 1; }
  local tracked_private
  tracked_private="$(git -C "$ROOT_DIR" ls-files -- learner-state .state)"
  [[ -z "$tracked_private" ]] || {
    echo 'REFUSE: a private learner or runtime path is already tracked by Git:' >&2
    printf '%s\n' "$tracked_private" >&2
    exit 1
  }
  git -C "$ROOT_DIR" check-ignore -q learner-state/.ignore-check || {
    echo 'REFUSE: learner-state/ is not ignored by Git.' >&2
    exit 1
  }
  git -C "$ROOT_DIR" check-ignore -q .state/.ignore-check || {
    echo 'REFUSE: .state/ is not ignored by Git.' >&2
    exit 1
  }
}

normalize_week() {
  local value="${1:-}"
  if [[ "$value" =~ ^week-(0[0-9]|1[0-2])$ ]]; then
    printf '%s\n' "$value"
  elif [[ "$value" =~ ^([0-9]|1[0-2])$ ]]; then
    printf 'week-%02d\n' "$value"
  else
    echo "Unknown week: $value (expected week-00 through week-12)" >&2
    exit 2
  fi
}

create_week_workspace() {
  local week="$1"
  local week_dir="$PRIVATE_DIR/weeks/$week"
  mkdir -p "$week_dir/placement" "$STATE_DIR"

  local template target
  for template in "$TEMPLATE_DIR"/*.md; do
    target="$week_dir/$(basename "$template")"
    if [[ ! -f "$target" ]]; then
      sed -e "s/{{WEEK_ID}}/$week/g" -e "s/{{DATE}}/$(date +%F)/g" "$template" >"$target"
    fi
  done
}

write_code_workspace() {
  local week="$1"
  cat >"$PRIVATE_DIR/cka-ckad-study.code-workspace" <<EOF
{
  "folders": [
    {"name": "Study guide (read-only mindset)", "path": ".."},
    {"name": "My $week work", "path": "weeks/$week"}
  ],
  "settings": {
    "files.exclude": {"**/.git": true},
    "terminal.integrated.cwd": "\${workspaceFolder:Study guide (read-only mindset)}"
  }
}
EOF
}

init_profile() {
  local profile=''
  [[ $# -eq 2 && "${1:-}" == '--profile' && -n "${2:-}" ]] || usage
  profile="$2"
  case "$profile" in beginner|rusty|operator) ;; *) usage ;; esac

  require_wsl
  assert_private_paths_ignored
  mkdir -p "$PRIVATE_DIR" "$STATE_DIR"
  if [[ ! -f "$PRIVATE_DIR/profile.yaml" ]]; then
    cat >"$PRIVATE_DIR/profile.yaml" <<EOF
profile: $profile
created: $(date +%F)
route_decision: pending-week-00-diagnostic
weekly_hours: null
cka_eligibility_end: null
ckad_eligibility_end: null
course_access_end: null
EOF
  else
    echo "Keeping existing profile: $PRIVATE_DIR/profile.yaml"
  fi
  create_week_workspace week-00
  write_code_workspace week-00
  printf 'week-00\n' >"$PRIVATE_DIR/current-week"

  echo 'Private study workspace initialized.'
  echo "Profile: $PRIVATE_DIR/profile.yaml"
  echo "Start:   bash ./study open week-00"
  echo "Git:     learner-state/ and .state/ are ignored"
}

open_week() {
  [[ $# -eq 1 || ($# -eq 2 && "${2:-}" == '--code') ]] || usage
  local week
  week="$(normalize_week "${1:-}")"
  local launch_code=0
  [[ "${2:-}" == '--code' ]] && launch_code=1
  [[ -f "$PRIVATE_DIR/profile.yaml" ]] || {
    echo 'Initialize your private workspace first: bash ./study init --profile rusty' >&2
    exit 1
  }
  assert_private_paths_ignored
  [[ -f "$ROOT_DIR/weeks/$week/README.md" ]] || {
    echo "The public guide for $week is not published yet." >&2
    exit 1
  }
  create_week_workspace "$week"
  write_code_workspace "$week"
  printf '%s\n' "$week" >"$PRIVATE_DIR/current-week"

  cat <<EOF
Week:          $week
Guide:         weeks/$week/README.md
Resources:     weeks/$week/RESOURCES.md
Private plan:  learner-state/weeks/$week/PLAN.md
Private notes: learner-state/weeks/$week/NOTES.md
Evidence:      learner-state/weeks/$week/EVIDENCE.md
Lab state:     .state/

Next: open the guide, then use 'bash ./study shell' for an isolated terminal.
EOF

  if (( launch_code )); then
    command -v code >/dev/null 2>&1 || {
      echo "VS Code's 'code' command is unavailable; the workspace was still created." >&2
      exit 1
    }
    code "$PRIVATE_DIR/cka-ckad-study.code-workspace"
  fi
}

show_status() {
  echo "Repository: $ROOT_DIR"
  if [[ -f "$PRIVATE_DIR/profile.yaml" ]]; then
    sed -n '1,3p' "$PRIVATE_DIR/profile.yaml"
  else
    echo 'profile: not initialized'
  fi
  if [[ -f "$PRIVATE_DIR/current-week" ]]; then
    echo "current_week: $(<"$PRIVATE_DIR/current-week")"
  else
    echo 'current_week: not selected'
  fi
  assert_private_paths_ignored
  echo 'private_paths: ignored'
}

open_shell() {
  [[ $# -eq 0 ]] || usage
  require_wsl
  assert_private_paths_ignored
  mkdir -p "$STATE_DIR"
  local rc_file="$STATE_DIR/study-shell.rc"
  {
    printf 'source ~/.bashrc 2>/dev/null || true\n'
    printf 'export CKA_CKAD_STATE_DIR=%q\n' "$STATE_DIR"
    printf 'export KUBECONFIG=%q\n' "$STATE_DIR/kubeconfig"
    printf 'alias k=kubectl\n'
    printf 'if command -v kubectl >/dev/null 2>&1; then\n'
    printf '  source <(kubectl completion bash)\n'
    printf '  complete -o default -F __start_kubectl k\n'
    printf 'fi\n'
    printf 'if [[ -f "$KUBECONFIG" ]]; then\n'
    printf '  printf "Study context: %%s\\n" "$(kubectl config current-context 2>/dev/null || echo unavailable)"\n'
    printf 'else\n'
    printf '  echo "Study context: cluster not created yet"\n'
    printf 'fi\n'
  } >"$rc_file"
  chmod 600 "$rc_file"
  echo "Study shell: KUBECONFIG=$STATE_DIR/kubeconfig"
  echo 'Exit the shell to return to your normal terminal.'
  exec bash --noprofile --rcfile "$rc_file" -i
}

run_doctor() {
  [[ $# -ge 1 && $# -le 2 ]] || usage
  case "${1:-}" in
    windows)
      [[ $# -eq 1 ]] || usage
      require_wsl
      local powershell
      powershell="$(command -v powershell.exe 2>/dev/null || true)"
      if [[ -z "$powershell" && -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]]; then
        powershell='/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
      fi
      [[ -n "$powershell" ]] || { echo 'Windows PowerShell is unavailable from WSL.' >&2; exit 1; }
      "$powershell" -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$ROOT_DIR/_project/scripts/environment/doctor-windows.ps1")" -DistroName "${WSL_DISTRO_NAME:-}"
      ;;
    wsl)
      [[ $# -eq 1 || ($# -eq 2 && ("${2:-}" == '--preflight' || "${2:-}" == '--ready')) ]] || usage
      require_wsl
      bash "$ROOT_DIR/_project/scripts/environment/doctor-wsl.sh" "${2:---preflight}"
      ;;
    *) usage ;;
  esac
}

run_lab() {
  [[ $# -eq 2 ]] || usage
  local action="${1:-}" target="${2:-}"
  [[ "$target" == 'week0-smoke' ]] || usage
  case "$action" in seed|grade|reset) ;; *) usage ;; esac
  bash "$ROOT_DIR/_project/labs/shared/week0-smoke/$action.sh"
}

run_diagnostic() {
  [[ $# -eq 2 ]] || usage
  local action="${1:-}" target="${2:-}"
  [[ "$target" == 'week0-placement' ]] || usage
  case "$action" in seed|grade|reset) ;; *) usage ;; esac
  bash "$ROOT_DIR/_project/diagnostics/week0-placement/$action.sh"
}

command="${1:-}"
shift || true
case "$command" in
  init) init_profile "$@" ;;
  open) open_week "$@" ;;
  status) [[ $# -eq 0 ]] || usage; show_status ;;
  shell) open_shell "$@" ;;
  doctor) run_doctor "$@" ;;
  tools)
    [[ $# -eq 1 && "${1:-}" == 'bootstrap' ]] || usage
    require_wsl
    bash "$ROOT_DIR/_project/scripts/environment/bootstrap-wsl.sh"
    ;;
  env)
    [[ $# -eq 2 ]] || usage
    require_wsl
    bash "$ROOT_DIR/_project/scripts/environment/labctl.sh" "$@"
    ;;
  lab)
    require_wsl
    run_lab "$@"
    ;;
  diagnostic)
    require_wsl
    run_diagnostic "$@"
    ;;
  *) usage ;;
esac
