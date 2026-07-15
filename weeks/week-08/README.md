# Week 8 — Deployment, Configuration, and Security

> Preview: resources and acceptance intent are published; the scenario set is not yet runnable.

**Goal:** deploy, update, configure, and constrain an application with native objects, Helm, and Kustomize.

**Before starting:** pass Week 7. Read [this week's resources](RESOURCES.md) and map the matching LFS/LFD259 modules.

## Planned work

1. Practice rollouts, rollback, and progressive release patterns.
2. Deploy and change an existing package with Helm; inspect the installed objects.
3. Build Kustomize bases, overlays, and patches with `kubectl` integration.
4. Wire ConfigMaps, Secrets, requests/limits, security contexts, and ServiceAccounts.
5. Recognize application-facing CRD, Operator, authentication, authorization, and admission boundaries.

## Planned gate

- Complete a deployment/config/security scenario without leaking a Secret.
- Explain the effective Pod configuration and identity from API state.
- Roll forward or back with verification.

Until the scenarios and graders appear here, this week cannot be marked `PASS`.
