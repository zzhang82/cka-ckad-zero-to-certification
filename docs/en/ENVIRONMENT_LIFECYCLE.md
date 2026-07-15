# Environment and Scenario Lifecycle

Version: 0.1
Last updated: 2026-07-15

## 1. One lifecycle

All labs and scenarios follow:

```text
doctor
  → up(profile)
  → verify-ready
  → seed(scenario)
  → practice
  → grade
  → reset
  → down(profile)
  → audit
```

Week 0 implements `doctor`, `up`, `status`, `reset`, `down`, and `evidence`. Its smoke lab also proves the per-lab `seed`, `grade`, and `reset` contract. Later scenarios own their own seed and grade commands rather than relying on a generic placeholder.

## 2. Three different meanings of scale

### Recreate a lab

Destroy and rebuild the same project-owned profile to return to a known baseline.

```bash
bash scripts/environment/labctl.sh reset week0-single
```

Use this for reproducibility, contamination recovery, and repeated practice.

### Increase or decrease lab topology

Select a different disposable profile:

```bash
bash scripts/environment/labctl.sh up week0-single
bash scripts/environment/labctl.sh down week0-single
bash scripts/environment/labctl.sh up shared-multinode
```

The profiles have different project-owned names, so one is never silently converted into another. Bring down unused profiles to conserve memory and disk.

Current topology ladder:

| Level | Profile | Purpose |
|---|---|---|
| L0 | No cluster | YAML, shell, Helm rendering, and documentation navigation |
| L1 | `week0-single` | API objects, controllers, Services, configuration, CKAD basics |
| L2 | `shared-multinode` | scheduling, taints, affinity, topology, node/network/storage drills |
| L3 | Disposable kubeadm nodes, deferred | installation, upgrades, systemd, runtime, CNI, node/control-plane failure |
| L4 | HA/multi-cluster, optional | only an explicit current blueprint or remediation need justifies it |

### Scale a workload

Changing Deployment replicas, HPA behavior, resource requests, placement, or disruption is a Kubernetes workload operation. It does not require rebuilding the lab and will be practiced through scenarios.

Examples include:

- `kubectl scale` and declarative replica changes;
- HorizontalPodAutoscaler behavior;
- resource requests/limits and pending Pods;
- PodDisruptionBudget effects;
- cordon, drain, uncordon, and rescheduling;
- rollout and rollback.

## 3. Production-adjacent discipline

Disposable labs teach a safe operating loop that transfers to production, but deleting and recreating a kind cluster is not a production scaling procedure.

Before any production-like scale or maintenance action, practice asking:

1. What is the desired capacity or state?
2. What evidence shows the present constraint?
3. Which scope is affected: workload, namespace, node pool, cluster, or control plane?
4. What availability, PDB, storage, and network constraints apply?
5. What health signals must remain green during the change?
6. What is the rollback or recovery path?
7. How will final behavior and capacity be verified?

## 4. Safety contract

- Project kubeconfig: `${HOME}/.local/state/cka-ckad-lab/kubeconfig`.
- Cluster names start with `cka-ckad-`.
- `labctl` refuses unknown profiles.
- `down` and `reset` pass an exact cluster name to kind.
- Scripts do not read or merge `~/.kube/config`.
- A full reset recreates only the named project profile.
- Scenario reset scripts must delete only their own namespace or labeled resources.
- Learner evidence is local-only and must not contain kubeconfig credentials.

## 5. Evidence contract

Every environment run records:

- profile and cluster name;
- pinned versions and node-image digest;
- Docker server/context;
- cluster nodes and Kubernetes version;
- creation, reset, and teardown duration;
- failures and recovery steps;
- final audit showing whether project resources remain.
