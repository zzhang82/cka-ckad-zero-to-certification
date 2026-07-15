# Week 3 — Cluster Lifecycle and Maintenance

> Preview: resources and acceptance intent are published; disposable-node labs and graders are not yet runnable.

**Goal:** create and maintain a kubeadm cluster safely, including upgrades, node operations, RBAC, Helm/Kustomize use, and extension awareness.

**Before starting:** pass the Week 2 gate. Read [this week's resources](RESOURCES.md) and map the matching LFS258 cluster-lifecycle modules.

## Planned work

1. Build a disposable kubeadm topology outside the canonical WSL host.
2. Practice join, drain, upgrade ordering, uncordon, and recovery.
3. Inspect certificates, kubeconfigs, static Pods, systemd units, and component logs.
4. Install or configure a component with Helm and Kustomize.
5. Explain HA, CRD, and Operator boundaries without turning them into rote definitions.

## Planned gate

- Complete one safe upgrade and one failed-component recovery.
- Never install kubeadm/kubelet into the primary Week 0 WSL environment.
- Leave a deterministic teardown and evidence record.

Until the disposable topology and grader links appear here, this week cannot be marked `PASS`.
