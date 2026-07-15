# Labs

Labs own runnable scenarios. Weekly folders link to them instead of copying their content.

Each graded lab should expose the same learner-facing contract:

1. `README.md` — goal, prerequisites, task, hints, and acceptance criteria.
2. `seed.sh` — create only namespaced or explicitly named project resources.
3. `grade.sh` — perform read-only final-state checks and return a nonzero status on failure.
4. `reset.sh` — delete only resources owned by that lab.

The first vertical slice is [Week 0 smoke](shared/week0-smoke/README.md).
