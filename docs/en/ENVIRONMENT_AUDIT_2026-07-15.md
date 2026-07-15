# Local Environment Audit — 2026-07-15

Status: measured, read-only audit. No packages were installed and no configuration was changed.

## 1. Host capacity

| Area | Measured state |
|---|---|
| Windows | Windows 11 Pro, 64-bit, build 26200 |
| CPU | AMD Ryzen 5 5600X, 6 cores / 12 logical processors |
| RAM | 31.9 GiB physical |
| Firmware virtualization | Enabled |
| Hypervisor | Present |
| C: free space | 97.7 GiB |
| D: free space | 138.5 GiB |
| WSL storage location | Main Ubuntu distro under `D:\WSL\Ubuntu-24.04` |

Conclusion: the host has sufficient CPU, RAM, virtualization, and disk capacity for the initial learning environment. Multi-node images must still be budgeted against actual D: free space rather than the larger virtual filesystem number reported inside WSL.

## 2. Virtualization and WSL

| Component | State |
|---|---|
| Microsoft Hyper-V | Enabled |
| Virtual Machine Platform | Enabled |
| Windows Subsystem for Linux | Enabled |
| Hyper-V VM management service | Running |
| Hyper-V compute service | Running |
| WSL | 2.7.10.0; default version 2 |
| Default distro | `Ubuntu-24.04-D`, running under WSL2 |
| Ubuntu | 24.04.4 LTS |
| Kernel | 6.18.33.2-microsoft-standard-WSL2 |
| systemd | Running |
| cgroup | v2 |
| WSL allocation | 8 CPUs, 16 GB RAM, 8 GB swap |

Hyper-V is already open and operational. No enablement work is required.

## 3. Container runtime

Two different Docker lanes exist:

1. Docker Desktop 4.60.1 is installed on Windows, but its service and `docker-desktop` WSL distro are stopped. The Windows Docker CLI selects `desktop-linux`, so Windows `docker info` currently fails.
2. Ubuntu WSL has an independent native Docker Engine 29.5.2. Docker and containerd are active and healthy, using overlayfs, cgroup v2, and the systemd cgroup driver.

Decision proposal: use the healthy native WSL Docker Engine as the canonical first runtime and leave Docker Desktop stopped. Switching runtimes later must be a deliberate migration, not an incidental side effect.

## 4. Tool inventory

| Tool | Windows | Ubuntu WSL |
|---|---|---|
| kubectl | v1.34.1, bundled with Docker Desktop | Missing |
| kind | Missing | Missing |
| minikube | Missing | Missing |
| k3d | Missing | Missing |
| Docker | CLI 29.2.0; selected daemon stopped | Client/server 29.5.2, healthy |
| Podman | Missing | Missing |
| Helm | Missing | Missing |
| Kustomize | Embedded v5.7.1 in Windows kubectl | Missing standalone tool |
| jq | Missing | 1.7 |
| yq | Missing | Missing |
| Git | 2.55.0.windows.2 | 2.43.0 |
| Python | 3.14.3 | 3.12.3 |
| Node | 25.7.0 | Missing |
| VS Code CLI | Missing | Missing |
| kubeadm/kubelet/crictl | Missing | Missing |

There is no kubeconfig, Kubernetes context, or current cluster in Windows or WSL.

## 5. Smallest safe setup

The next environment phase should:

1. use `Ubuntu-24.04-D` as the canonical shell;
2. keep the native WSL Docker Engine;
3. install only pinned `kubectl`, `kind`, current Helm plus a Helm 3 compatibility binary, and `yq` first;
4. optionally add standalone `kustomize` only when a lab needs it;
5. create an isolated project kubeconfig and one smoke-test `kind` cluster;
6. prove cluster create, basic workload, service test, delete, and rebuild;
7. add `doctor`, version-report, reset, and teardown commands before adding curriculum labs.

Do not install minikube, k3d, Podman, kubeadm, or kubelet in Phase 1 without a specific scenario requirement.

## 6. CKA environment boundary

`kind` is appropriate for foundations, workloads, services, networking concepts, and most CKAD tasks. It cannot by itself provide every realistic CKA node, service, boot, and `kubeadm` failure.

The primary WSL distro should not be turned into a mutable CKA node. Later CKA node-level labs should run in disposable Linux machines. Hyper-V and nested KVM capability are available; the exact disposable-VM lane will be selected after a bounded prototype.

## 7. Known risks

- Starting Docker Desktop can make the Windows and WSL Docker lanes confusing.
- The canonical Linux shell currently lacks the essential Kubernetes tools.
- WSL swap is harmless for `kind`, but a future direct kubelet setup would need deliberate handling.
- The native Docker and WSL kernel versions are recent; compatibility must be proven with the pinned `kind` image.
- The user is not in the WSL `kvm` group, which matters only if a KVM lane is later selected.
- Windows Node 25 should not be assumed as the long-term static-site build baseline; site tooling should use a pinned LTS runtime or a container.

## 8. Validation evidence used

The audit used read-only Windows CIM, service, volume, WSL, Docker, and version probes. Major checks included:

```powershell
Get-CimInstance Win32_OperatingSystem
Get-CimInstance Win32_ComputerSystem
Get-CimInstance Win32_Processor
Get-CimInstance Win32_OptionalFeature
Get-Service vmms,vmcompute
wsl.exe --version
wsl.exe --status
wsl.exe --list --verbose
docker.exe info
kubectl config get-contexts
```

Inside WSL, the audit checked `/etc/os-release`, kernel, systemd, cgroup, memory, storage, Docker, containerd, networking prerequisites, swap, KVM visibility, tool paths, and tool versions. Kubeconfig content and credentials were not read.

## 9. Environment acceptance before curriculum expansion

- pinned versions documented;
- bootstrap and doctor pass;
- one cluster build/delete/rebuild cycle passes twice;
- project kubeconfig is isolated;
- no Docker Desktop dependency is introduced accidentally;
- resource usage is recorded;
- teardown removes only project-owned resources;
- recovery from a partial setup is documented and tested.
