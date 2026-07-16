# Contributing

Learners should start from [the root guide](README.md). This page is for people improving the program.

## Useful contribution types

- correct a stale or unclear weekly direction;
- propose a current official resource with a version and replacement trigger;
- add an original guided lab or broken-state scenario;
- improve a deterministic grader, scoped reset, or safety guard;
- report an instruction that fails on the supported Windows/WSL path.

## Before opening a change

1. Read the [maintainer map](_project/README.md) and [architecture](_project/ARCHITECTURE.md).
2. Follow the [source and license policy](_project/policies/SOURCE_POLICY.md).
3. Use the [acceptance standard](_project/quality/ACCEPTANCE_STANDARD.md).
4. Keep learner notes, scores, portal details, kubeconfigs, and mock state out of Git.
5. Do not submit exam dumps, recalled tasks, copied course material, or third-party exercises without a compatible license and attribution.

## Validate

From WSL:

```bash
python3 _project/scripts/quality/validate_repo.py
python3 _project/scripts/quality/check_links.py
bash -n study _project/scripts/environment/*.sh _project/scripts/learner/*.sh
bash _project/scripts/quality/test_target_guards.sh
python3 _project/diagnostics/week0-placement/test_grader.py
bash _project/scripts/quality/test_study_cli.sh
```

Run every changed lab or diagnostic through seed, grade, reset, and teardown on the supported environment. A new week is not runnable merely because its Markdown exists.

Contributions are accepted under the repository's [MIT License](LICENSE). Third-party materials still require compatible licensing and attribution under the [source and license policy](_project/policies/SOURCE_POLICY.md).
