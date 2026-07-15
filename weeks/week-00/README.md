# Week 0 — Environment Contract and Diagnostic Baseline

Suggested time: 8–10 focused hours.

## Target

Prove that the workstation can create, use, destroy, and recreate an isolated Kubernetes v1.35 lab, then measure current command and troubleshooting ability.

Week 0 is not a Kubernetes installation course. It separates three environments:

1. **Physical exam host** — Windows runs PSI Secure Browser.
2. **Remote exam environment** — Linux desktop, then SSH into the designated task host; task hosts provide `kubectl`, `yq`, curl/wget, man pages, and sudo.
3. **Local study environment** — WSL2 supplies a repeatable lab. Client tools are installed here; cluster-node installation work is practiced later in disposable machines.

## Part A — Administrative baseline

Record in ignored `learner-state/`, not public Git:

- CKA and CKAD eligibility dates;
- LFS258/LFS259 access dates;
- exact bundle SKU;
- retake and Killer.sh entitlement;
- weekly study blocks and blackout dates.

## Part B — Verify the measured host

Run the Windows doctor and confirm, rather than reconfigure:

- Windows build, CPU, RAM, and disk headroom;
- firmware virtualization and hypervisor state;
- Hyper-V, Virtual Machine Platform, and WSL2;
- default `Ubuntu-24.04-D` distro;
- systemd and cgroup v2;
- native WSL Docker client/server health;
- Docker Desktop is not the active dependency.

Commands:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/environment/doctor-windows.ps1
wsl -d Ubuntu-24.04-D -- bash -lc "cd /mnt/c/Users/frank/Documents/CKAD && bash scripts/environment/doctor-wsl.sh --preflight"
```

## Part C — Minimal WSL toolchain

Install only:

- `kubectl` pinned to the current exam minor;
- `kind` with a digest-pinned Kubernetes v1.35 node image;
- current Helm 4 as `helm` plus maintained Helm 3 as `helm3` for course/chart compatibility;
- `yq` v4.

Existing Docker, jq, Git, Python, vim, SSH, curl, wget, and Bash completion are sufficient.

Do not install minikube, k3d, Podman, `kubeadm`, `kubelet`, `crictl`, or a standalone Kustomize binary in Week 0. CKA node installation, upgrades, runtime, systemd, and failure recovery will use disposable Linux nodes in Week 3.

Bootstrap command, after reviewing the version lock:

```bash
bash scripts/environment/bootstrap-wsl.sh
bash scripts/environment/doctor-wsl.sh --ready
```

## Part D — Isolation contract

- Use cluster name `cka-ckad-week0`.
- Use project kubeconfig `${HOME}/.local/state/cka-ckad-lab/kubeconfig`.
- Do not merge with `~/.kube/config` or a workplace kubeconfig.
- Every reset/teardown command must name the project cluster explicitly.
- Report the active Docker context and server before creating a cluster.
- Use the repo-provided exam-mode shell setup rather than permanent aliases.

## Part E — Environment proof, repeated twice

1. Run ready-mode doctor.
2. Create the digest-pinned cluster.
3. Inspect context, cluster info, nodes, namespaces, and API resources.
4. Run `labs/shared/week0-smoke/seed.sh`.
5. Run `labs/shared/week0-smoke/grade.sh` and inspect the workload manually.
6. Run `labs/shared/week0-smoke/reset.sh`.
9. Delete `cka-ckad-week0`.
10. Verify no project cluster remains.
11. Recreate and repeat.

Use [the smoke-lab instructions](../../labs/shared/week0-smoke/README.md) for the exact commands and acceptance criteria.

## Part F — 60–90 minute placement diagnostic

Use the runnable [Week 0 placement diagnostic](../../diagnostics/week0-placement/README.md). It fixes the task denominator, timebox, allowed resources, machine-checked score, manual evidence rubric, Green/Yellow/Red rules, and remediation trigger.

Sample:

- shell navigation, pipes, redirection, search, permissions, and editing;
- YAML structure and fast field changes;
- contexts, namespaces, discovery, and API resources;
- Pods, Deployments, Services, ConfigMaps, and Secrets;
- rollout, scale, logs, events, describe, exec, and port-forward;
- one broken image/configuration workload;
- one Service selector or DNS failure;
- basic scheduling, storage, and architecture reasoning;
- final-state verification.

Classification:

- **Green** — unseen task completed without hints and explained correctly; compress related lessons.
- **Yellow** — correct model but slow or documentation-dependent; retain drills and a short review.
- **Red** — unable to complete or diagnose; complete the full lesson and remediation lab.

Recognition of terminology alone is not Green.

## Acceptance gate

- [ ] Windows/WSL doctors contain no blocker.
- [ ] All pinned client tools, including both Helm lanes, match the version lock.
- [ ] Docker Desktop is not an accidental dependency.
- [ ] Project kubeconfig is isolated.
- [ ] Cluster lifecycle succeeds twice.
- [ ] Teardown is scoped to project resources.
- [ ] Diagnostic evidence covers every sampled area.
- [ ] Every Yellow/Red result has a scheduled follow-up.
- [ ] No VM platform, site framework, or full mock bank was built prematurely.

Verdict: `PASS` / `CONDITIONAL` / `REPEAT`
