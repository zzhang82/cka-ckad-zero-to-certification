# Start Here — Week 0

## This week's direction

- **Goal:** Prove a clean, isolated Kubernetes v1.35 lab lifecycle twice and establish the diagnostic baseline.
- **Why it matters:** Every later lab, scenario, grader, and mock depends on a trustworthy resettable environment.
- **Expected focused hours:** 8–10.
- **Definition of done:** Doctors pass, pinned tools match, two lifecycle runs succeed, and every diagnostic weakness has a next action.

## Before you begin

Read in this order:

1. [Linux Foundation CKA/CKAD exam environment](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)
2. [Allowed exam resources](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed)
3. [Install kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
4. [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)
5. [Environment lifecycle](../../docs/en/ENVIRONMENT_LIFECYCLE.md)
6. [Detailed Week 0 plan](README.md)

Do not copy paid LFS material into this repository. LFS258 module mapping starts after its table of contents is inventoried.

## Topics you will touch

- physical Windows versus WSL study shell versus remote Linux exam hosts;
- virtualization, systemd, cgroup v2, Docker client/server, and project isolation;
- pinned client tools and checksum verification;
- kubeconfig, context, cluster, node, namespace, and API discovery;
- environment recreation versus topology scale versus workload scale;
- diagnostic classification: Green, Yellow, Red.

## Do the work in this order

### 1. Host preflight

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/environment/doctor-windows.ps1
wsl -d Ubuntu-24.04-D -- bash -lc "cd /mnt/c/Users/frank/Documents/CKAD && bash scripts/environment/doctor-wsl.sh --preflight"
```

### 2. Review and install the minimal toolchain

```bash
cat environments/versions.env
bash scripts/environment/bootstrap-wsl.sh
bash scripts/environment/doctor-wsl.sh --ready
```

### 3. Enter the isolated exam-mode shell

```bash
source scripts/environment/exam-shell.sh
```

### 4. First lifecycle

```bash
bash scripts/environment/labctl.sh up week0-single
bash scripts/environment/labctl.sh status week0-single
bash labs/shared/week0-smoke/seed.sh
bash labs/shared/week0-smoke/grade.sh
bash labs/shared/week0-smoke/reset.sh
bash scripts/environment/labctl.sh evidence week0-single
bash scripts/environment/labctl.sh down week0-single
```

### 5. Second lifecycle

Repeat the full lifecycle, including the smoke lab. Record both results with [the evidence template](../../templates/EVIDENCE_TEMPLATE.md), then run the fixed [Week 0 placement diagnostic](../../diagnostics/week0-placement/README.md).

## Scale-up and scale-down reference

```bash
# Small environment
bash scripts/environment/labctl.sh up week0-single
bash scripts/environment/labctl.sh down week0-single

# Larger disposable topology for later shared labs
bash scripts/environment/labctl.sh up shared-multinode
bash scripts/environment/labctl.sh down shared-multinode

# Recreate the same profile from a clean baseline
bash scripts/environment/labctl.sh reset week0-single
```

Do not confuse these environment operations with workload scaling such as `kubectl scale` or HPA.

## Evidence

Personal results belong in ignored `learner-state/`. Do not commit portal dates, credentials, kubeconfigs, or unseen mock forms.

Record:

- doctor summaries;
- version output and node-image digest;
- create/delete duration for both runs;
- active Docker context/server;
- failures and recovery;
- diagnostic Green/Yellow/Red map.

## Completion gate

- [ ] Windows and WSL doctors have no blocker.
- [ ] `kubectl`, `kind`, `helm`, `helm3`, and `yq` match `environments/versions.env`.
- [ ] Project kubeconfig is isolated.
- [ ] `week0-single` creates and deletes twice.
- [ ] No unrelated cluster or kubeconfig changed.
- [ ] Diagnostic evidence and remediation map exist.

Verdict: `PASS` / `CONDITIONAL` / `REPEAT`
