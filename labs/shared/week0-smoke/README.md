# Week 0 Smoke Lab

## Goal

Prove that the local cluster can schedule a workload, expose it through a Service, and return functional HTTP traffic. The grader checks final state; it does not care how the learner reached that state.

## Prerequisite

From WSL, at the repository root:

```bash
source scripts/environment/exam-shell.sh
bash scripts/environment/labctl.sh up week0-single
```

## Run

```bash
bash labs/shared/week0-smoke/seed.sh
kubectl -n week0-smoke get all
kubectl -n week0-smoke get events --sort-by=.metadata.creationTimestamp
bash labs/shared/week0-smoke/grade.sh
```

The learner should also use `describe`, `logs`, and `get -o yaml` to explain why the grader passes.

## Acceptance criteria

- namespace `week0-smoke` exists;
- Deployment `web` has two available replicas;
- Service `web` selects those Pods and has at least one ready endpoint;
- an HTTP request routed through the Kubernetes API Service proxy succeeds;
- no resource outside namespace `week0-smoke` is created or deleted by the lab scripts.

## Reset

```bash
bash labs/shared/week0-smoke/reset.sh
```

Reset is idempotent: running it twice is safe.
