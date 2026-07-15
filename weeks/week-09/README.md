# Week 9 — Observability, Networking, and Debugging

> Preview: resources and acceptance intent are published; the CKAD broken-state bank is not yet runnable.

**Goal:** diagnose application health and connectivity quickly using probes, logs, events, exec, Services, NetworkPolicy, and Ingress.

**Before starting:** pass Week 8. Read [this week's resources](RESOURCES.md) and finish the application-debugging part of LFS/LFD259.

## Planned work

1. Distinguish liveness, readiness, and startup failures.
2. Retrieve current and previous container logs and inspect multi-container Pods.
3. Trace Service selectors, ports, EndpointSlices, and DNS.
4. Repair NetworkPolicy and Ingress scenarios at CKAD scope.
5. Complete timed mixed application debugging.

## Planned gate

- Every edit follows an observation and hypothesis.
- Health, traffic, and rollout verification all pass.
- The timed set has no unresolved repeated failure class.

Until the scenarios and graders appear here, this week cannot be marked `PASS`.
