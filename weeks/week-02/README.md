# Week 2 — Architecture, Access, Resources, and Scheduling

> Preview: resources and acceptance intent are published; the original labs and grader are not yet runnable.

**Goal:** explain where a failure lives, control who may do what, and predict why a Pod schedules—or does not.

**Before starting:** complete the Week 1 hands-on gate. Read [this week's resources](RESOURCES.md) and the matching LFS258 modules.

## Planned work

1. Retrieve control-plane and node responsibilities without notes.
2. Build and test namespaced RBAC with `kubectl auth can-i`.
3. Use requests, limits, selectors, affinity, taints, and tolerations in scheduling scenarios.
4. Wire ConfigMaps, Secrets, probes, and a PVC; diagnose broken references.
5. Complete a timed mixed access-and-scheduling check.

## Planned gate

- Explain the first evidence source for API, scheduler, kubelet, and workload failures.
- Prove least-privilege access from the intended identity.
- Repair an unschedulable Pod without removing the requirement.
- Record attempts in `learner-state/weeks/week-02/EVIDENCE.md`.

Until the lab and grader links appear here, this week cannot be marked `PASS`.
