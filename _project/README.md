# Maintainer and Automation Area

Learners do not need to browse this directory. The stable learner interface is `bash ./study ...`; public directions live under `weeks/`.

## Ownership

| Path | Purpose |
|---|---|
| `scripts/` | Environment, learner-workspace, and quality entry points |
| `environments/` | Version lock and disposable topology definitions |
| `labs/`, `diagnostics/` | Seed, grade, reset, fixtures, and hidden implementation details |
| `templates/` | Private workspace and future authoring molds |
| `schemas/`, `data/` | Machine-readable resource and week contracts |
| `planning/`, `policies/`, `quality/`, `evidence/` | Project decisions, governance, standards, and dated proof |

See [Architecture](ARCHITECTURE.md) for boundaries and lifecycle details.

## Current implementation truth

- Week 0 has a tested environment profile, smoke proof, placement diagnostic, grader, and reset.
- Weeks 1–12 expose learner targets and curated resources, but their lab/scenario gates remain previews.
- English is canonical for now; Chinese translation and a static site wait until the weekly contract stabilizes.

## Quality commands

```bash
python3 _project/scripts/quality/validate_repo.py
python3 _project/scripts/quality/check_links.py
bash -n study _project/scripts/environment/*.sh _project/scripts/learner/*.sh _project/scripts/quality/*.sh
bash -n _project/labs/shared/week0-smoke/*.sh _project/diagnostics/week0-placement/*.sh
bash _project/scripts/quality/test_target_guards.sh
python3 _project/diagnostics/week0-placement/test_grader.py
bash _project/scripts/quality/test_study_cli.sh
```

The live Week 0 proof runs the WSL ready doctor, two clean cluster lifecycles, smoke grader, blank/golden/post-reset placement states, and final teardown:

```bash
bash _project/diagnostics/week0-placement/test_live.sh
```

## Content gates

- A resource needs authority, owner, reuse posture, assigned week, verification date, and a replacement trigger. Weekly `RESOURCES.md` pages own exact learner links; the machine catalog records source families, policy-critical sources, purchased material, and community adoption candidates rather than duplicating every Kubernetes documentation subpage.
- A lab needs goal, prerequisite, seed, learner task, grader, reset, safe scope, and evidence contract.
- A readiness claim needs two unseen timed forms and must not derive from course completion alone.
- Historical evidence is dated; it does not override current live validation.
