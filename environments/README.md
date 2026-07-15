# Environments

Environment definitions are version-pinned and disposable. They do not hold lessons or learner evidence.

Supported now:

- `kind/week0-single.yaml` — one control-plane node for Week 0 and basic object practice.
- `kind/shared-multinode.yaml` — one control-plane plus two workers for scheduling, networking, and node-placement practice.

Deferred until a mapped CKA objective needs them:

- disposable kubeadm nodes;
- multi-control-plane/HA topology;
- alternative cluster engines.

The version source of truth is `versions.env`.
