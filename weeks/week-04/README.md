# Week 4 — Networking and Storage

> Preview: resources and acceptance intent are published; the network/storage scenario set is not yet runnable.

**Goal:** trace traffic and volume binding end to end, then repair failures without random edits.

**Before starting:** pass the Week 3 gate. Read [this week's resources](RESOURCES.md) and map the matching LFS258 networking/storage modules.

## Planned work

1. Trace Pod → Service → EndpointSlice → Pod traffic and DNS resolution.
2. Apply and debug NetworkPolicy with a CNI that enforces it.
3. Configure and compare Ingress and Gateway API at CKA scope.
4. Create and repair PV, PVC, StorageClass, and dynamic-provisioning flows.
5. Complete timed network and storage fault sets.

## Planned gate

- Localize selector, port, DNS, policy, and controller failures from evidence.
- Explain why a PVC is Pending before changing it.
- Complete the timed domain set and reset every resource safely.

Until the scenarios and graders appear here, this week cannot be marked `PASS`.
