# Guided Lab — Build and Explain an Object Path

Build a two-replica HTTP workload from a clean namespace, expose it through a Service, and explain the API state you created.

## Start clean

From the repository root in WSL:

```bash
bash ./study lab reset week1-objects
bash ./study lab seed week1-objects
```

The seed creates only namespace `week1-objects`. Put every object in that namespace.

## Contract

Create Deployment `object-web` and Service `object-web` with these exact requirements:

- Deployment replicas: `2`;
- container name: `web`;
- image: `registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85`;
- container arguments: `netexec` and `--http-port=8080`;
- named container port `http` on `8080`;
- Deployment and Pod-template labels: `app.kubernetes.io/name=object-web` and `lab.cka-ckad.dev/week=week-01`;
- Deployment annotation: `lab.cka-ckad.dev/owner=learner`;
- Service selector: `app.kubernetes.io/name=object-web`;
- Service port `80` targeting the named port `http` or numeric port `8080`.

Add a readiness probe for `/healthz` on the HTTP port. You may generate a client-side manifest, write YAML directly, or combine imperative generation with editing.

## Verify and explain

Use the root interface to grade:

```bash
bash ./study lab grade week1-objects
```

Before reset, capture commands or output that explain:

1. `spec` versus `status` on the Deployment;
2. the Deployment selector versus Pod-template labels;
3. the Service selector versus the ready EndpointSlice;
4. why the HTTP check proves more than a Running phase alone.

Then reset only this lab:

```bash
bash ./study lab reset week1-objects
```
