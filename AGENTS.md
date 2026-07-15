# CKAD Project Instructions

This file is a thin project override. Global Cole instructions remain authoritative.

- Canonical learning shell: `Ubuntu-24.04-D` under WSL2 with the native WSL Docker Engine.
- English Markdown is canonical. Do not add Chinese mirrors until IDs and content contracts are stable.
- `weeks/` orchestrates existing content; it must not duplicate canonical lessons, labs, scenarios, or solutions.
- Paid LFS258/LFS259 content is link/map only. Do not copy proprietary text, media, or labs.
- Reject exam dumps, reconstructed live questions, and confidential exam content.
- Every external asset needs source, version/commit, license, adoption status, and local validation evidence.
- Generated files belong in `dist/`; learner scores and unseen forms belong in ignored `learner-state/`.
- Destructive environment scripts must scope operations to project-owned names and kubeconfigs.

Validation commands:

```bash
python3 scripts/quality/validate_repo.py
bash scripts/environment/doctor-wsl.sh --preflight
```
