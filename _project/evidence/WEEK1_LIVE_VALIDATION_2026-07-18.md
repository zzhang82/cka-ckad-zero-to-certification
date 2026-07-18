# Week 1 Live Validation — 2026-07-18

Status: **repository implementation passed; learner mastery remains unclaimed**.

This report records maintainer validation of the Week 1 lab system on the supported Windows/WSL path. Golden fixtures prove that the public contracts are gradable; they do not count as a learner's independent attempt.

## Environment

| Component | Observed state |
|---|---|
| WSL distribution | Ubuntu 24.04, systemd, cgroup v2 |
| Docker Engine | 29.6.2, native WSL engine, `default` context |
| kubectl | v1.35.6 |
| kind | v0.32.0 |
| kind node | Kubernetes v1.35.5, pinned image digest |
| Project context | `kind-cka-ckad-week0` through the repository kubeconfig |

The ready doctor reported 0 failures and 0 warnings before cluster creation.

## Contract tests

The pure grader suite exercised all three modes with golden, alternate-valid, near-miss, partial, wrong-namespace, post-reset, and cross-mode states. It also verified an alternative Deployment selector, a documented alternative Pod container name, selector/template mismatch rejection, and required named-port enforcement.

```bash
python3 _project/labs/cka/week1/test_grader.py
```

Result: **11 tests passed**.

## Live lifecycle proof

```bash
bash _project/labs/cka/week1/test_live.sh
```

The proof created one disposable cluster and exercised each workflow in this order:

| Workflow | Blank/seed state | Golden state | Post-reset state |
|---|---|---|---|
| `week1-objects` | grader rejected | all 7 checks passed | grader rejected |
| `week1-debug` | grader rejected | all 5 checks passed | grader rejected |
| `week1-sprint` | grader rejected | all 6 checks passed | grader rejected |

The passing live states verified exact namespaces and pinned images, complete two-replica rollouts, object metadata where required, Service selectors and ports, ready EndpointSlices, and HTTP responses through the Kubernetes Service proxy.

Every reset deleted its declared namespace while a separately created project sentinel namespace remained present. Final teardown deleted cluster `cka-ckad-week0`; `kind get clusters` reported no remaining clusters.

## Learner boundary

The public Week 1 pages disclose tasks and acceptance criteria, not golden manifests or grader internals. A learner still needs to complete the guided lab, debugging drill, and timed diagnostic personally, save evidence in the configured private learner workspace, and issue a `PASS`, `CONDITIONAL`, or `REPEAT` verdict.
