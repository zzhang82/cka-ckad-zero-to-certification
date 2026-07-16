# Windows and WSL Study Environment

The supported V1 path is Windows 11 plus WSL2. Windows remains the physical host; WSL is the local Linux practice shell; the real exam supplies a separate remote Linux environment.

## What the repository owns

- `.state/kubeconfig` — isolated local lab credentials;
- kind clusters whose names begin with `cka-ckad-`;
- pinned clients and node image recorded under the internal project lock;
- namespace-scoped lab and diagnostic resources.

The study tooling never merges with `~/.kube/config` and never targets a workplace cluster.

## Check before installing

From the repository in WSL:

```bash
bash ./study doctor windows
bash ./study doctor wsl --preflight
```

The Windows doctor checks the OS, hardware capacity, firmware virtualization, Hyper-V, Virtual Machine Platform, and WSL features. The WSL doctor checks Ubuntu, systemd, cgroup v2, Docker, required base tools, and pinned client versions.

## Bootstrap the minimal client set

Only after reviewing preflight output:

```bash
bash ./study tools bootstrap
bash ./study doctor wsl --ready
```

Week 0 intentionally does not install minikube, k3d, Podman, kubeadm, kubelet, `crictl`, or standalone Kustomize. Later CKA node work belongs in disposable nodes, not the canonical WSL shell.

## Environment lifecycle

```bash
# Small Week 0 environment
bash ./study env up week0-single
bash ./study env status week0-single
bash ./study env down week0-single

# Recreate the same profile from a clean state
bash ./study env reset week0-single

# Larger topology reserved for later implemented labs
bash ./study env up shared-multinode
bash ./study env down shared-multinode
```

Recreating a lab is different from scaling a workload. `kubectl scale`, HPA behavior, scheduling, rollout, and disruption are Kubernetes operations inside a running environment.

## Private coding session

```bash
bash ./study open week-00 --code
bash ./study shell
```

The optional VS Code workspace opens the public repository and your configured private week directory together. The study shell loads your Bash preferences first and then overrides `KUBECONFIG` with `.state/kubeconfig`; use that prompt for every learner `kubectl` command. Exit it to return to your normal shell.

## Safety rules

- Inspect `kubectl config current-context` before every timed task.
- Use the namespace named by the task; do not depend on a remembered default.
- Never copy a work kubeconfig into `.state/`.
- Run `down` only for the named project profile.
- Treat grader success as final-state evidence, not as the explanation.
- Never store credentials, tokens, private keys, or kubeconfig in learner files. Keep portal dates, personal scores, and unseen mock state in the configured private learner directory only.

If a doctor fails, stop at that check. Do not add another cluster engine or bypass the isolation guard as a shortcut.
