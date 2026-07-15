# Repository Architecture

Version: 0.1
Last updated: 2026-07-15

## Architecture map

### Entrance

- `README.md` — public project entry, current route, and links.
- `docs/en/` — project decisions, research baseline, environment audit, and long-form English documentation.
- `curriculum/12_WEEK_MAP.md` — program-level sequence.
- `weeks/week-XX/README.md` — thin weekly execution order and acceptance gate.

### Core domain

- `curriculum/` — blueprint maps and canonical learning sequence.
- `labs/` — guided clean-path exercises.
- `diagnostics/` — fixed placement/readiness instruments with explicit denominators and scoring.
- `scenarios/` — planned home for independent and deliberately broken tasks with graders and reset contracts.
- `mocks/` — planned home for timed exam manifests and public sample forms; private unseen forms stay outside Git.
- `templates/` — current week/evidence molds and the planned home for lesson, lab, scenario, and retrospective molds.

### Infrastructure

- `environments/` — version locks and environment definitions, not learner content.
- `scripts/environment/` — doctor, bootstrap, create, reset, and teardown actions.
- `scripts/quality/` — deterministic repository validation.
- `schemas/` — machine-readable metadata contracts.
- `sources/` — official and community resource ledger, attribution, and adoption evaluations.

### Generated or local-only areas

- `learner-state/` — ignored personal evidence, scores, portal dates, and unseen mock state.
- `dist/` — generated ZIPs, checksums, and later static-site output; never canonical.
- `site/` — deferred until one vertical slice proves the content and scenario contracts.

## Ownership rule

| Question | Canonical owner |
|---|---|
| What should be mastered and when? | `curriculum/` and thin `weeks/` orchestration |
| How is a concept explained? | `docs/en/` or later `curriculum/<track>/` lesson files |
| How is a clean task practiced? | `labs/` |
| How is independent/debugging skill tested? | `scenarios/` |
| How is placement measured? | `diagnostics/` |
| How is readiness tested under time? | `mocks/` |
| How is an environment created or checked? | `environments/` plus `scripts/environment/` |
| What external source may be used? | `sources/catalog.json` |
| What proves a learner completed work? | ignored `learner-state/` using committed evidence schemas |

`weeks/` is the syllabus, not the content store. A week links stable IDs from other layers instead of copying them.

## Common weekly lifecycle

Every week uses the same state machine:

```text
Kickoff
  → resource intake
  → learn and retrieve
  → guided lab
  → broken-state drill
  → timed independent check
  → evidence and scoring
  → retrospective/remediation
  → acceptance gate
```

Possible gate results:

- `PASS` — all required evidence and thresholds satisfied.
- `CONDITIONAL` — the week may advance only with explicitly scheduled remediation.
- `REPEAT` — a critical objective or safety condition is unresolved.

Calendar completion is not mastery.

## Workflow versus skill decision

The weekly lifecycle is currently a repository-local workflow implemented with templates, JSON metadata, scripts, and acceptance rules. A global Codex skill would be premature because the procedure has not yet survived real weekly use.

Reconsider skill creation only after at least three completed weeks show:

- stable triggers and inputs;
- the same output mold;
- repeatable validation;
- value outside this repository;
- no project-specific assumptions that would make the skill misleading.

## Initial implementation boundary

Implement now:

- complete Week 0 contract;
- 12-week target map;
- version-pinned WSL doctor/bootstrap workflow;
- resource catalog and schemas;
- focused metadata and local-link validators.

Defer:

- multiple local cluster engines;
- disposable VM infrastructure until a CKA objective needs it;
- full mock bank;
- static-site framework and visual theme;
- Chinese translation;
- CKS curriculum;
- accounts, database, cloud synchronization, or LMS features.

## Evidence trail

- Current repository entrance and planning files were measured from the shallow file tree on 2026-07-15.
- Windows/WSL/Docker facts are recorded in `docs/en/ENVIRONMENT_AUDIT_2026-07-15.md`.
- The layered structure is a proposed architecture; Week 0 and one Week 1 vertical slice are its first validation.
- Blind spot: exact LFS258/LFS259 module titles remain unavailable until the learner portal/course table of contents is inventoried.
