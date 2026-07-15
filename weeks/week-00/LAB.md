# Week 0 Environment Smoke Proof

This is an environment proof, not a Kubernetes skill assessment. It verifies that the isolated cluster can schedule a workload, expose it through a Service, and return HTTP traffic.

## Run

Start a dedicated terminal at the repository root:

```bash
bash ./study shell
```

Do not run learner `kubectl` commands from your normal shell. At the new study-shell prompt, confirm the banner names `.state/kubeconfig`, then run:

```bash
bash ./study env up week0-single
bash ./study env status week0-single
bash ./study lab seed week0-smoke
kubectl -n week0-smoke get all
kubectl -n week0-smoke get events --sort-by=.metadata.creationTimestamp
bash ./study lab grade week0-smoke
bash ./study env evidence week0-single
```

Explain why the Deployment, Pods, Service, EndpointSlice, and HTTP check pass. Use `get -o yaml`, `describe`, and logs rather than treating the grader as the explanation.

## Reset

```bash
bash ./study lab reset week0-smoke
bash ./study env down week0-single
```

Both commands are scoped to project-owned resources and are safe to repeat. Complete the entire run twice from an absent cluster.
