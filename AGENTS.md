# CKAD Project Instructions

This file is a thin project override. Global Cole instructions remain authoritative.

- Canonical learning shell: Ubuntu 24.04 under WSL2 with a native WSL Docker Engine. The maintainer's verified distro is named `Ubuntu-24.04-D`, but public tooling must not require that local name.
- English Markdown is canonical. Do not add Chinese mirrors until IDs and content contracts are stable.
- `weeks/` is the human learner surface; keep one executable guide and one bounded resource list per week.
- `_project/` owns scripts, graders, templates, schemas, machine data, planning, and evidence. Public instructions call the root `study` interface rather than internal paths.
- Paid LFS258/LFS259 content is link/map only. Do not copy proprietary text, media, or labs.
- Reject exam dumps, reconstructed live questions, and confidential exam content.
- Every external asset needs source, version/commit, license, adoption status, and local validation evidence.
- Generated files belong in `dist/`; learner scores, notes, and unseen forms belong in ignored `learner-state/`; runtime state belongs in ignored `.state/`.
- Destructive environment scripts must scope operations to project-owned names and kubeconfigs.

Validation commands:

```bash
python3 _project/scripts/quality/validate_repo.py
python3 _project/scripts/quality/check_links.py
bash ./study doctor wsl --preflight
```
