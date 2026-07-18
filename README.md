# CKA + CKAD: 12-Week Hands-On Program

[![repository-quality](https://github.com/zzhang82/cka-ckad-zero-to-certification/actions/workflows/quality.yml/badge.svg)](https://github.com/zzhang82/cka-ckad-zero-to-certification/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Prepare for **CKA first, then CKAD**, with Linux Foundation course mapping, repeatable WSL labs, broken-state drills, and timed readiness gates.

## Start here

| If this sounds like you | Open this |
|---|---|
| New to Linux, YAML, containers, or basic networking | [Check the prerequisites](docs/en/prerequisites/README.md) |
| You know Kubernetes concepts but your command-line skills are rusty | [Start Week 0](weeks/week-00/README.md) |
| You use Kubernetes regularly and want to test out of familiar material | [Take the Week 0 placement route](docs/en/getting-started/CHOOSE_YOUR_PATH.md#current-kubernetes-operator) |

## Create your private study workspace

Fork or clone the repository, open it in WSL, then run:

```bash
bash ./study init --profile rusty
bash ./study open week-00
```

Use `beginner`, `rusty`, or `operator` as the profile. The command creates an ignored local workspace for your plan, notes, evidence, and retrospective. Both `learner-state/` and `.state/` are Git-ignored by default.

If you keep personal study records in a separate private repository, connect its journal with the documented [external learner workspace](docs/en/getting-started/EXTERNAL_LEARNER_WORKSPACE.md). Runtime state and kubeconfig still remain under this repository's ignored `.state/`.

To open the repository and your private Week 0 workspace together in VS Code:

```bash
bash ./study open week-00 --code
```

Then follow one page: **[Week 0 — prove the environment and place your skills](weeks/week-00/README.md)**.

The current runnable milestones are **Weeks 0 and 1**. Later-week goals and reading lists are published, but their labs and graders are still being built.

## Project status

A week is marked **Runnable** only when its learner guide, original labs, reset path, and grader have been implemented and validated.

| Week | Learner target | Track | Labs and graders | Status |
|---:|---|---|---|---|
| [0](weeks/week-00/README.md) | Prove the environment and establish placement | Shared | Ready | **Runnable** |
| [1](weeks/week-01/README.md) | API objects, YAML, namespaces, and command fluency | CKA | Ready | **Runnable** |
| [2](weeks/week-02/README.md) | Architecture, access, resources, and scheduling | CKA | In development | Preview |
| [3](weeks/week-03/README.md) | Cluster installation, lifecycle, upgrades, and extensions | CKA | In development | Preview |
| [4](weeks/week-04/README.md) | Networking and storage | CKA | In development | Preview |
| [5](weeks/week-05/README.md) | Application, node, and control-plane troubleshooting | CKA | In development | Preview |
| [6](weeks/week-06/README.md) | CKA timed mocks and readiness decision | CKA | In development | Preview |
| [7](weeks/week-07/README.md) | Application design, images, workloads, and volumes | CKAD | In development | Preview |
| [8](weeks/week-08/README.md) | Deployment, configuration, and application security | CKAD | In development | Preview |
| [9](weeks/week-09/README.md) | Observability, networking, and application debugging | CKAD | In development | Preview |
| [10](weeks/week-10/README.md) | CKAD timed mocks and readiness decision | CKAD | In development | Preview |
| [11](weeks/week-11/README.md) | Repair the weakest measured domain | Remediation | In development | Preview |
| [12](weeks/week-12/README.md) | Use the retake buffer or hand off to CKS | Contingency | In development | Preview |

See the detailed [12-week program map](weeks/README.md).

## What you do each week

> Read with a question → retrieve from memory → run a guided lab → repair a broken state → complete a timed check → record evidence → pass or repeat

Every week starts with two canonical learner-facing files:

- `README.md` — the goal, ordered work, lab entry points, and acceptance gate;
- `RESOURCES.md` — a short, version-aware reading list for that week.

Runnable weeks may link bounded task sheets from that execution page; graders and answer fixtures remain on the maintainer surface.

See the [12-week program map](weeks/README.md) or [choose a starting level](docs/en/getting-started/CHOOSE_YOUR_PATH.md).

## Supported and tested setup

- Windows 11 with WSL2;
- an Ubuntu WSL distribution with systemd;
- Docker Engine reachable from that distribution;
- roughly 10–12 focused hours per week.

LFS258 and LFS/LFD259 are the recommended paid course spine. The public direction and original lab work are designed to stay usable without copying proprietary course material.

## Repository boundaries

| Area | Who it is for | What belongs there |
|---|---|---|
| `weeks/`, `resources/`, `docs/en/` | Learners | Weekly directions, curated reading, and setup help |
| `learner-state/` or an external learner directory | You, privately | Plans, notes, evidence, scores, and retrospectives |
| `.state/` | Runtime tooling, locally | Kubeconfig and temporary runtime files; Git-ignored in this repository |
| `_project/` | Maintainers and automation | Scripts, templates, graders, schemas, planning, and verification evidence |

Learners should not need to browse `_project/`; use the stable `bash ./study ...` commands shown in each week.

## Help or contribute

- [Troubleshoot Windows/WSL setup](docs/en/setup/WINDOWS_WSL.md)
- [Browse all weekly resources](resources/README.md)
- [Contribute a lab, correction, or resource](CONTRIBUTING.md)
- [View the public 12-week project](https://github.com/users/zzhang82/projects/1)

## License

This project is licensed under the [MIT License](LICENSE). Third-party materials retain their own licenses and attribution requirements.

This independent project is not endorsed by CNCF, the Linux Foundation, or PSI. Exam dumps, recalled questions, and copied proprietary training content are not accepted.
