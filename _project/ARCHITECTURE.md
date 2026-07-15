# Repository Architecture

The repository has three explicit surfaces. A file should have one owner and one audience.

## 1. Public learner surface

```text
README.md
weeks/
resources/
docs/en/
study
```

- `README.md` routes a learner in the first screen.
- `weeks/week-XX/README.md` is the one execution page for that week.
- `weeks/week-XX/RESOURCES.md` is the bounded reading list.
- `resources/` provides cross-week discovery without duplicating the lists.
- `docs/en/` holds prerequisite and setup help.
- `study` is the stable command interface; public pages do not call internal paths.

## 2. Maintainer and machine surface

```text
_project/
├── scripts/
├── environments/
├── labs/
├── diagnostics/
├── templates/
├── schemas/
├── data/
├── planning/
├── policies/
├── quality/
└── evidence/
```

Internal paths may change while `bash ./study ...` remains stable. Graders and seed manifests stay here so a learner is not invited to read implementation details during a no-hint attempt.

Conventional root files such as `.github/`, `.gitignore`, `AGENTS.md`, and `CONTRIBUTING.md` remain at the root because external tools discover them there.

## 3. Local-private surface

```text
learner-state/
├── profile.yaml
├── current-week
└── weeks/week-XX/
    ├── PLAN.md
    ├── NOTES.md
    ├── EVIDENCE.md
    └── RETROSPECTIVE.md

.state/
├── kubeconfig
└── runtime files
```

Both paths are Git-ignored. `learner-state/` belongs to the human; `.state/` belongs to runtime tooling. Initialization refuses to proceed if either path is trackable.

## Weekly lifecycle

```text
choose route
  → read with a question
  → retrieve from memory
  → guided lab
  → broken-state drill
  → timed independent check
  → grade and verify
  → record evidence
  → PASS / CONDITIONAL / REPEAT
```

Calendar completion, course completion, and grader success alone are not mastery. The learner must explain observed state and safely target context, namespace, and resource scope.

## Environment lifecycle

```text
doctor → up(profile) → seed → practice → grade → reset → down(profile) → audit
```

The repository kubeconfig is `.state/kubeconfig`. Cluster names begin with `cka-ckad-`. Teardown names an exact project profile, and scenario reset removes only its own namespace or labeled resources.

## Canonical ownership

| Question | Owner |
|---|---|
| What do I do this week? | `weeks/week-XX/README.md` |
| What should I read? | `weeks/week-XX/RESOURCES.md` |
| How do I invoke the system? | root `study` command |
| How is the action implemented? | `_project/scripts/`, `_project/labs/`, `_project/diagnostics/` |
| Which external source may be adopted? | `_project/data/resources/catalog.json` plus source policy |
| What proves my work? | ignored `learner-state/` |
| What proves repository behavior? | dated `_project/evidence/` plus live validation |

## Deliberate deferrals

- static-site framework until multiple weeks prove the contract;
- Chinese translation until English IDs and structure stabilize;
- full mock bank until objective and grader contracts are tested;
- CKS curriculum until CKA and CKAD completion work is protected;
- alternate desktop platforms outside Windows/WSL V1.
