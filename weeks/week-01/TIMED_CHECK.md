# Timed Check — Object Sprint

Set a **25-minute timer**. Work without private fixtures, internal grader code, or AI assistance. Official Kubernetes documentation and `kubectl` help are allowed.

## Seed

```bash
bash ./study diagnostic reset week1-sprint
bash ./study diagnostic seed week1-sprint
```

The seed creates namespace `week1-sprint` and a Service with a wrong selector. Complete all work in that namespace.

## Contract

1. Create Pod `sprint-probe` with label `task=sprint-probe`. Use the pinned image below and run `pause`; the Pod must become Ready.
2. Create Deployment `sprint-web` with exactly `2` replicas. Its `web` container must use the pinned image, run `netexec --http-port=8080`, and expose named port `http` on `8080`. Its Pod template must carry label `app=sprint-web`.
3. Repair Service `sprint-web` so its selector is `app=sprint-web`; port `80` must target `http` or `8080`.
4. Verify the rollout, ready EndpointSlice, and HTTP path before grading.

Pinned image:

```text
registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85
```

## Stop, grade, reset

Stop the timer when your own verification succeeds, then run:

```bash
bash ./study diagnostic grade week1-sprint
bash ./study diagnostic reset week1-sprint
```

Record the elapsed time, grader result, commands you had to look up, and whether the attempt was independent. Passing after 30 minutes or with hidden help is evidence for a repeat, not an independent timed pass.
