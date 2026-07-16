# Week 0 Placement Diagnostic

This 90-minute instrument measures placement; it is not a mock exam or certification prediction.

## Rules

- Hard stop at 90 minutes and record the actual time.
- Allowed: this task sheet, terminal/man pages, and official Kubernetes documentation.
- Not allowed on the first attempt: AI, project notes, hints, solution repositories, paid-course answers, or another person.
- Work only in namespace `week0-diagnostic`, except for the requested node label.
- Do not inspect `_project/diagnostics/` after seeding.

Prepare:

```bash
bash ./study shell
```

At the new study-shell prompt, confirm the banner names `.state/kubeconfig`, then run:

```bash
bash ./study env up week0-single
bash ./study diagnostic seed week0-placement
```

Use this image when a task requests the provided workload image:

```text
registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85
```

## Tasks

Each area is worth 10 points. Areas 1, 2, and 4–9 are machine-checked for 80 points; Areas 3 and 10 use the private scorecard for 20 points.

1. From `$CKA_CKAD_LEARNER_DIR/weeks/week-00/placement/objects.txt`, produce a sorted unique list of object kinds before `/`. Save it as `$CKA_CKAD_LEARNER_DIR/weeks/week-00/placement/kinds.txt`.
2. Create a Running Pod `yaml-proof` in `week0-diagnostic`. It must have label `diagnostic=yaml`, use the provided image, and run `agnhost pause`.
3. Record the current context, namespace, server version, node count, and verification commands before making changes.
4. Repair Deployment `web` so it uses the provided image and reaches three available replicas.
5. Repair Service `web` so it selects the `web` Pods and `/healthz` succeeds through the Kubernetes Service proxy.
6. Set ConfigMap `app-config` key `MODE` to `diagnostic`; make container `web` read environment variable `MODE` from that key and complete a rollout.
7. Create Secret `api-credentials` with `token=ready`; make container `web` read `API_TOKEN` from that key and complete a rollout.
8. Make Pod `scheduled` Ready without removing its node selector. Use the required node label and record why the Pod was Pending.
9. Create a PVC `work-data` of at least 64Mi and a Running Pod `storage-check` that mounts it at `/data` using volume name `data`.
10. For Tasks 4, 5, and 8, record one decisive pre-edit observation, the inferred cause, the change, and final verification.

## Grade and clean up

At the hard stop:

```bash
bash ./study diagnostic grade week0-placement | tee "$CKA_CKAD_LEARNER_DIR/weeks/week-00/placement/grade.txt"
bash ./study diagnostic reset week0-placement
bash ./study env down week0-single
```

Complete `placement/SCORECARD.md` under the learner directory printed by `bash ./study status`. Use Green = 10, Yellow = 5, Red = 0. Schedule a repeat for every Yellow or Red result before passing Week 0.
