# Week 0 Environment Verification — 2026-07-15

Status: **environment gate passed; learner placement diagnostic still pending**.

This report records live checks performed on the target Windows/WSL workstation. It is evidence for the local environment, not a claim that all Week 0 learning work is complete.

Relocation note: command paths in the tables below are preserved as executed on 2026-07-15. The current public interface is `bash ./study ...`; internal scripts later moved under `_project/`.

## Post-refactor validation

The learner-first interface and hardened placement grader were revalidated live on 2026-07-15:

| Verification | Result |
|---|---|
| Placement grader unit fixtures | 7/7 passed: golden, alternate-valid quantity, near-miss, exact Secret contract, partial, wrong-namespace, and post-reset states |
| Disposable environment lifecycle | Two consecutive `up -> smoke -> reset -> down` cycles passed |
| Blank placement state | Expected `AUTOMATED_SCORE=0/80` |
| Golden placement state | Expected `AUTOMATED_SCORE=80/80` |
| Post-reset placement state | Returned to `AUTOMATED_SCORE=0/80` |
| Private workspace isolation | Hostile `.bashrc`, surplus CLI arguments, and tracked-private-path cases were rejected or contained as designed |
| Residual cluster state | `kind get clusters` reported `No kind clusters found` |

Commands used:

```bash
python3 _project/diagnostics/week0-placement/test_grader.py
bash _project/scripts/quality/test_study_cli.sh
bash _project/diagnostics/week0-placement/test_live.sh
```

The live test writes temporary verification evidence under ignored `.state/`, never under the learner's private `learner-state/` notebook.

## Host and runtime

| Check | Result |
|---|---|
| Windows 11 Pro build 26200 | PASS |
| Firmware virtualization and Windows hypervisor | PASS |
| Hyper-V, Virtual Machine Platform, and WSL features | PASS |
| Ubuntu 24.04 WSL distro | PASS |
| systemd PID 1 and cgroup v2 | PASS |
| WSL resources: 8 CPUs, 15 GiB RAM, more than 800 GiB filesystem headroom | PASS |
| Native WSL Docker server 29.5.2, context `default` | PASS |
| Docker Desktop not an active dependency | PASS |

Windows doctor result: **0 failures, 0 warnings**.

## Installed and pinned tools

| Tool | Verified version |
|---|---|
| kubectl | v1.35.6 |
| built-in Kustomize | v5.7.1 |
| kind | v0.32.0 |
| Helm primary lane | v4.2.3 |
| Helm 3 compatibility lane | v3.21.3 |
| yq | v4.53.3 |

All downloads were checked against publisher-provided SHA256 values before installation. WSL ready-mode doctor result: **0 failures, 0 warnings**.

## Recreate proof

The `week0-single` profile was created, exercised, and destroyed twice with:

- isolated kubeconfig `/home/zzs333/.local/state/cka-ckad-lab/kubeconfig`;
- exact cluster name `cka-ckad-week0`;
- kind node image `kindest/node:v1.35.5@sha256:ce977ae6d65918d0b58a5f8b5e940429c2ce42fa3a5619ec2bbc60b949c0ac95`;
- Kubernetes server v1.35.5 and containerd 2.3.1;
- two-replica smoke Deployment;
- ready Service endpoints;
- successful HTTP request through the Kubernetes Service proxy;
- namespace reset and exact cluster teardown.

Observed end-to-end elapsed time was approximately 61 seconds for the first run and 53 seconds for the cached second run. Both graders returned PASS.

## Topology scale proof

The `shared-multinode` profile created one control-plane node and two worker nodes. All three reached Ready on Kubernetes v1.35.5. The exact project cluster was then destroyed.

The `reset week0-single` action was also exercised after the workload image was digest-pinned. It deleted the exact project cluster, recreated it, and returned a Ready node before final teardown.

Final residual-state check: `kind get clusters` reported **No kind clusters found**.

## Reproducible verification record

These results were observed in live commands during the repository build; they are not a GitHub Actions result.

| Verification | Command owner | Exit/result |
|---|---|---|
| Repository contracts | `python scripts/quality/validate_repo.py` | 20 resources and 1 week contract; exit 0 |
| Local Markdown links | `python scripts/quality/check_links.py` | 23 local links; exit 0 |
| Shell syntax | `bash -n` over environment, quality, smoke, and diagnostic scripts | exit 0 |
| Wrong-context safety | `bash scripts/quality/test_target_guards.sh` | wrong context refused; explicit kubeconfig/context injected; exit 0 |
| Smoke grader after target guards | `seed.sh` → `grade.sh` → `reset.sh` | HTTP and final-state PASS; exit 0 |
| Placement grader empty state | diagnostic seed → grade → reset | expected 0/80; evaluator remained healthy |
| Placement grader solved state | temporary ignored verification state → grade → reset | all eight machine areas PASS, 80/80 |
| Residual cluster state | `kind get clusters` | no clusters found |

The temporary full-score verification input was deleted and was never added to the public diagnostic. The blank personal scorecard generated during testing was also removed.

## Remaining Week 0 learner work

- run the 60–90 minute placement diagnostic without coaching;
- record Green/Yellow/Red results in ignored `learner-state/`;
- schedule remediation for every Yellow or Red area;
- repeat the smoke lab personally rather than treating this infrastructure verification as practice credit.
