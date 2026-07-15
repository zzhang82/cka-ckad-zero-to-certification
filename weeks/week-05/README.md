# Week 5 — Troubleshooting Across Layers

> Preview: resources and acceptance intent are published; the mixed broken-state bank is not yet runnable.

**Goal:** use an evidence-first decision tree across applications, networking, nodes, runtimes, and the control plane.

**Before starting:** pass Week 4. Read [this week's resources](RESOURCES.md), then finish the troubleshooting portion of LFS258.

## Planned work

1. Classify a symptom before editing: API, scheduling, kubelet/runtime, network, storage, or application.
2. Repair Pending, CrashLoop, image, selector, DNS, and probe failures.
3. Use systemd journals, component logs, and `crictl` when the API path is insufficient.
4. Complete mixed scenarios without knowing the fault category in advance.
5. Produce a current CKA objective-coverage report.

## Planned gate

- Every repair begins with a decisive observation and ends with verification.
- No random restarts or deletion without a stated hypothesis.
- Timed mixed drills expose no unresolved safety weakness.

Until the unseen scenarios and graders appear here, this week cannot be marked `PASS`.
