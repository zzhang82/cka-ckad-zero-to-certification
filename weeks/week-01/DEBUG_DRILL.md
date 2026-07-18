# Debug Drill — Repair Two Independent Failures

The seeded Deployment has a broken image and the Service has a selector that matches no Pods. Diagnose both failures from observed state before editing.

## Seed and inspect

```bash
bash ./study lab reset week1-debug
bash ./study lab seed week1-debug
```

Work only in namespace `week1-debug`. Inspect workload status, Pods, recent events, the Service selector, and EndpointSlices. Record the evidence that identifies each fault.

## Required end state

- Deployment `debug-web` has exactly `2` fully rolled-out replicas.
- Its `web` container uses exactly `registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85`.
- The container still runs `netexec --http-port=8080`.
- Service `debug-web` selects `app=debug-web`.
- The Service has a ready EndpointSlice and serves HTTP through port `80`.

Do not replace the Deployment or Service with differently named objects.

## Grade and reset

```bash
bash ./study lab grade week1-debug
bash ./study lab reset week1-debug
```

In your evidence, distinguish the event/status clue for the image failure from the selector/EndpointSlice clue for the traffic failure.
