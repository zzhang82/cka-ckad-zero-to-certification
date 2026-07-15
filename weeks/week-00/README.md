# Week 0 — Environment and Placement

**Goal:** prove a clean, isolated Kubernetes lab lifecycle twice, then measure what you can do without hints.

**Time:** 8–10 focused hours.

**Result:** an evidence-based Green/Yellow/Red map that decides how much of Weeks 1–3 you may compress.

## Before you begin

You should be able to use a Linux shell, read basic YAML, and explain containers, ports, DNS, and HTTP. If not, complete the [prerequisite checks](../../docs/en/prerequisites/README.md) first.

Read the short [Week 0 resource list](RESOURCES.md). Do not start by reading the internal scripts or placement grader.

## 1. Initialize your private workspace

From this repository in WSL:

```bash
bash ./study init --profile rusty
bash ./study open week-00
```

Use `beginner` or `operator` if [another starting path](../../docs/en/getting-started/CHOOSE_YOUR_PATH.md) fits better. Record voucher/course access dates and study blocks in `learner-state/profile.yaml`; never commit them.

## 2. Check Windows and WSL

Run from WSL:

```bash
bash ./study doctor windows
bash ./study doctor wsl --preflight
```

The doctors inspect the host; they do not install or reconfigure it. Resolve every failure before continuing. A preflight warning for a missing pinned study tool is expected before bootstrap.

## 3. Install only the pinned study tools

Review the [setup and lifecycle guide](../../docs/en/setup/WINDOWS_WSL.md), then run:

```bash
bash ./study tools bootstrap
bash ./study doctor wsl --ready
```

This installs the repository's pinned `kubectl`, `kind`, Helm 4, compatibility `helm3`, and `yq`. It does not install `kubeadm`, `kubelet`, or a second local cluster platform; those are not Week 0 goals.

## 4. Prove the lab lifecycle twice

Before any learner `kubectl` command, enter the isolated shell and keep that prompt open:

```bash
bash ./study shell
```

The shell loads your normal Bash preferences first, then overrides `KUBECONFIG` with this repository's `.state/kubeconfig`. Open the [environment smoke proof](LAB.md) and complete the full sequence twice from that prompt:

```bash
bash ./study env up week0-single
bash ./study lab seed week0-smoke
bash ./study lab grade week0-smoke
bash ./study env evidence week0-single
bash ./study lab reset week0-smoke
bash ./study env down week0-single
```

The second run must start from an absent cluster. Record timing, failures, recovery, Docker context, and final output in `learner-state/weeks/week-00/EVIDENCE.md`.

## 5. Take the placement diagnostic

Stay in the study shell, create a fresh cluster, then follow the [90-minute placement diagnostic](DIAGNOSTIC.md):

```bash
bash ./study env up week0-single
bash ./study diagnostic seed week0-placement
```

Do not inspect `_project/diagnostics/` after the timer begins. The public task sheet and official documentation are sufficient.

## 6. Turn results into a route

For each sampled skill, record:

- **Green:** correct without hints, safe, verified, and explained;
- **Yellow:** correct but slow, documentation-dependent, or incompletely explained;
- **Red:** incomplete, unsafe, guessed, or solved with hidden help.

Schedule one repeat task for every Yellow or Red area. A high total never cancels a Red context, namespace, or destructive-scope result.

## Acceptance gate

- [ ] Windows and WSL doctors report no failure.
- [ ] The ready doctor confirms every pinned tool.
- [ ] `learner-state/` and `.state/` are Git-ignored.
- [ ] The cluster and smoke proof succeed twice from a clean start.
- [ ] No unrelated kubeconfig, context, cluster, or namespace changes.
- [ ] The timed diagnostic and manual scorecard are complete.
- [ ] Every Yellow or Red result has a repeat task and due week.

Verdict: `PASS` / `CONDITIONAL` / `REPEAT`

Next: [Week 1 preview](../week-01/README.md). Week 1 labs and grader must be published before its gate can be claimed.
