# Week 0 Placement Diagnostic

## Purpose

Measure current shell, YAML, `kubectl`, workload, configuration, networking, scheduling, storage, and evidence-first debugging ability. This is a placement instrument, not a mock exam and not a certification prediction.

## Timebox and rules

- Hard stop: 90 minutes; record the actual time.
- Allowed: the task packet, terminal, man pages, and official Kubernetes documentation.
- Not allowed for the baseline: AI, solution repositories, project notes, paid-course answers, or another person.
- Hints: none during the first attempt. If blocked, stop that task and record it Red rather than searching for a copied solution.
- Work only in namespace `week0-diagnostic` except for the explicitly requested node label.

Before starting, create the Week 0 cluster and seed the broken state:

```bash
source scripts/environment/exam-shell.sh
bash scripts/environment/labctl.sh up week0-single
bash diagnostics/week0-placement/seed.sh
```

Do not inspect `seed.sh`, `manifest.yaml`, or `grade.sh` after the timer starts.

## Provided values

Use this exact image reference wherever a task asks for the provided workload image:

```text
registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85
```

This is a task input, not a hidden solution. The digest makes repeated attempts use identical image content.

## Fixed task set

Each area is worth 10 points. Tasks 1, 2, and 4–9 are machine-checked for 80 points; Tasks 3 and 10 use the rubric in `SCORECARD_TEMPLATE.md` for 20 points.

1. **Shell pipeline** — From `diagnostics/week0-placement/fixtures/objects.txt`, produce a sorted unique list of the object kinds before `/`. Save it as `learner-state/week-00-placement/kinds.txt`.
2. **YAML and API use** — Create a Running Pod `yaml-proof` in `week0-diagnostic`. It must have label `diagnostic=yaml`, use the provided workload image, and run `agnhost pause`.
3. **Discovery and scope** — In the scorecard, record the current context, namespace, server version, node count, and the commands used to verify them before making changes.
4. **Deployment repair and scale** — Make Deployment `web` use the provided workload image and reach three available replicas.
5. **Service repair** — Repair Service `web` so it selects the `web` Pods and `/healthz` succeeds through the Kubernetes Service proxy.
6. **ConfigMap wiring** — Set `app-config` key `MODE` to `diagnostic`. Configure container `web` to read environment variable `MODE` from that exact key and complete a successful rollout.
7. **Secret wiring** — Create Secret `api-credentials` with key `token` and value `ready`. Configure container `web` to read environment variable `API_TOKEN` from that Secret and complete a successful rollout.
8. **Scheduling repair** — Make Pod `scheduled` reach Ready without removing its node selector. Use the required node label and record why the Pod was initially Pending.
9. **Storage** — Create a 64Mi-or-larger PVC `work-data` and a Running Pod `storage-check` that mounts it at `/data` using volume name `data`.
10. **Evidence-first debugging** — For Tasks 4, 5, and 8, record one decisive observation made before editing, the inferred root cause, the change, and a final verification command.

## Grade and record

At the hard stop:

```bash
bash diagnostics/week0-placement/grade.sh | tee learner-state/week-00-placement/grade.txt
```

Complete `learner-state/week-00-placement/SCORECARD.md` using this fixed area rule:

- **Green / 10:** correct final state without hints, within the task target, with a correct explanation and verification.
- **Yellow / 5:** correct after official-doc lookup or over target, or explanation/verification is incomplete.
- **Red / 0:** incomplete, unsafe, solved by random edits, or dependent on a hint/answer source.

Overall placement bands:

- 80–100: accelerated route may be used, but no safety objective is skipped.
- 50–79: standard 12-week route.
- 0–49: full foundation route and extra Week 1–3 remediation.

Any Red safety/scope result forces remediation regardless of total. Every Yellow or Red area must name a repeat task and due week before Week 0 can pass.

## Reset

```bash
bash diagnostics/week0-placement/reset.sh
bash scripts/environment/labctl.sh down week0-single
```

Reset removes only namespace `week0-diagnostic` and label `diagnostic-ready` from project nodes. It preserves ignored learner evidence.
