# Week 1 — API Objects and Command Fluency

**Goal:** turn Kubernetes recognition into fast, verified work with Pods, Deployments, Services, namespaces, labels, annotations, and YAML.

**Time:** 10–12 focused hours.

**Result:** three graded object workflows, including one independent timed check, and evidence that shows what to repeat.

## Before you begin

Pass Week 0 or carry an explicit remediation plan. Read the bounded [Week 1 resources](RESOURCES.md), and map the matching early LFS258 modules in private notes without copying course material.

Open the Week 1 guide and private journal, then start the isolated cluster from the repository root in WSL:

```bash
bash ./study open week-01
bash ./study env up week0-single
bash ./study shell
```

Keep the isolated study shell open for learner `kubectl` work. Every repository command below goes through the root `study` interface. Do not browse `_project/` for solutions.

## 1. Retrieve before touching the cluster

Write short answers from memory, then check them against the resource list:

1. Which fields express desired state, and which report observed state?
2. Why does a Deployment own Pods indirectly through a ReplicaSet?
3. How do a Service selector, Pod labels, and an EndpointSlice connect?
4. What evidence distinguishes an image failure from a selector failure?
5. When should `kubectl get`, `describe`, `logs`, `events`, and `explain` be used?

Record corrections in `$CKA_CKAD_LEARNER_DIR/weeks/week-01/EVIDENCE.md`.

## 2. Complete the guided object lab

Follow [GUIDED_LAB.md](GUIDED_LAB.md):

```bash
bash ./study lab seed week1-objects
bash ./study lab grade week1-objects
bash ./study lab reset week1-objects
```

## 3. Repair the broken workload and Service

Follow [DEBUG_DRILL.md](DEBUG_DRILL.md). Diagnose from status and events before editing:

```bash
bash ./study lab seed week1-debug
bash ./study lab grade week1-debug
bash ./study lab reset week1-debug
```

## 4. Run the timed independent check

Follow [TIMED_CHECK.md](TIMED_CHECK.md). Use a 25-minute timer and no private fixture or internal grader:

```bash
bash ./study diagnostic seed week1-sprint
bash ./study diagnostic grade week1-sprint
bash ./study diagnostic reset week1-sprint
```

## 5. Record evidence and decide the gate

In `$CKA_CKAD_LEARNER_DIR/weeks/week-01/EVIDENCE.md`, record each attempt's duration, commands, decisive evidence, grader output, assistance level, and one explanation of the resulting API objects.

- [ ] All three graders pass after a fresh seed.
- [ ] All three resets remove only their declared namespace.
- [ ] The guided objects use the exact labels, annotation, image, replicas, Service selector, and ports in the task.
- [ ] The debug repair is justified with status/events evidence, not guesses.
- [ ] The timed check passes in 30 minutes or less without solution access.
- [ ] Every slow, assisted, or failed step has a dated repeat task.

Verdict: `PASS` / `CONDITIONAL` / `REPEAT`

After recording the verdict, tear down the project cluster:

```bash
bash ./study env down week0-single
```

Next: [Week 2 preview](../week-02/README.md).
