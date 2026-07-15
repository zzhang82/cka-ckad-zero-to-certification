# Acceptance Standard

Version: 0.1
Last updated: 2026-07-15

This document defines when project artifacts, labs, scenarios, mock exams, and learner readiness may be called complete. It deliberately separates official exam facts from internal project standards.

## 1. Evidence labels

Every material claim uses one of these statuses:

- **Measured** — backed by command output, a test, a file, an artifact hash, or a verified source.
- **Inferred** — a reasoned conclusion from measured evidence.
- **Proposed** — a project decision awaiting approval or calibration.
- **Unresolved** — evidence is missing or conflicting; the claim cannot be used as a release dependency.

Exam policy, version, domain, score, and voucher claims must include a source and `last_verified` date.

## 2. Project artifact quality gate

Each release-bound artifact is scored out of 100:

| Dimension | Points |
|---|---:|
| Official blueprint and policy alignment | 20 |
| Reproducibility and reset reliability | 20 |
| Assessment and grader validity | 15 |
| Beginner clarity and prerequisite control | 15 |
| Exam-relevant realism | 15 |
| Maintainability, versioning, and provenance | 10 |
| Localization readiness | 5 |

Release threshold: **85/100 or higher, with no critical failure**.

Critical failures:

- an obsolete or unverified official exam claim is presented as current;
- a destructive command lacks isolation, scope checks, or a clear warning;
- a lab cannot be reset reliably;
- a grader accepts an invalid state or rejects a documented valid state;
- the environment modifies an unrelated kubeconfig, cluster, or user resource;
- redistributed third-party material has an unknown or incompatible license;
- content depends on leaked, reconstructed, or confidential exam material;
- a published ZIP cannot reproduce its documented initial state;
- a command or manifest was not tested on its declared version.

## 3. Lesson contract

A lesson is complete only when it contains:

- stable lesson ID and version;
- audience and prerequisite list;
- official objective mapping where applicable;
- one plain-language mental model;
- concrete examples with expected output;
- common failure modes;
- a short retrieval check;
- links to the exact official documentation used;
- a next practice step;
- `last_verified` metadata for version-sensitive content.

A beginner lesson fails review if it uses an unexplained command, acronym, object, field, or prerequisite.

For the reference learner, a module may be compressed or skipped only after a retrieval check and hands-on task demonstrate the objective without hints. Prior exposure, workplace familiarity, course completion, or recognition of terminology alone is not skip evidence.

## 4. Lab and scenario contract

Every lab or scenario must provide:

- stable scenario ID, version, target track, domain, objective, difficulty, and expected time;
- supported Kubernetes and tool versions;
- resource budget and prerequisites;
- initial-state setup;
- learner task and explicit constraints;
- machine-checkable grader where observable state exists;
- manual rubric for diagnosis and verification quality;
- idempotent or safely repeatable reset;
- separate hints and solution;
- provenance and license record;
- clean teardown instructions.

### Required validation fixtures

The grader must be tested against at least:

1. the documented golden solution;
2. one materially different but valid solution when the task permits alternatives;
3. an incorrect near-miss;
4. a partially complete state;
5. a wrong-context or wrong-namespace state where relevant;
6. the state after reset.

### Reproducibility gate

A scenario is releasable only after:

- setup succeeds from the documented baseline twice;
- grade passes the golden and equivalent-valid fixtures;
- grade fails or partially scores invalid fixtures correctly;
- reset returns the expected clean state twice;
- teardown removes only project-owned resources;
- a generated ZIP produces the same behavior as the source directory;
- the ZIP checksum and version are recorded.

## 5. Scoring model for tasks

Automated correctness uses:

| Component | Weight |
|---|---:|
| Required final state | 60% |
| Functional behavior | 20% |
| Explicit constraints | 10% |
| Non-regression and safety | 10% |

Manual diagnosis records whether the learner:

- identified the correct failure layer;
- gathered evidence before editing;
- formed and tested a plausible hypothesis;
- verified the fix from the required behavior;
- could recover or reset after a failed attempt.

Speed is reported separately:

- within target time;
- within 1.25× target;
- within 1.5× target;
- remediation required.

## 6. Mock-exam contract

Each full mock must:

- reflect the currently verified domain weights;
- contain original tasks that do not reproduce confidential exam content;
- use several clusters, contexts, namespaces, or designated hosts where appropriate;
- include creation, modification, validation, and debugging work;
- avoid dependence on one memorized command form;
- have a fixed time limit and scoring manifest;
- keep tasks, hints, and solutions separated;
- be fresh to the learner on the scored attempt;
- pass independent grader validation before use.

One mock result is never enough to declare readiness.

## 7. Learner exam-readiness gate

Official passing score as verified on 2026-07-15: **66% for both CKA and CKAD**. The following is a stricter internal project proposal and is not an official rule.

Proposed readiness standard:

- two different unseen full mocks;
- each completed within 120 minutes;
- at least 80% overall on each mock;
- at least 75% in every blueprint domain across the two-mock set;
- no hints, project notes, AI, or resources outside the current exam allowlist;
- no repeated wrong-host, wrong-context, or wrong-namespace pattern;
- the learner independently validates completed work;
- a remediation review closes all recurring critical errors.

The 80%/75% thresholds must be calibrated after the first mock bank is validated. A high score from an easy or leaked mock is not evidence of readiness.

## 8. Environment acceptance

The local lab baseline passes only when:

- `doctor` reports Windows/WSL/runtime/tool versions and actionable failures;
- project kubeconfig and runtime state are isolated;
- bootstrap is version-pinned and repeatable;
- one cluster can be created, tested, deleted, and recreated;
- documented CPU, memory, and disk budgets are respected;
- a failed partial setup can be recovered without manual guesswork;
- the primary WSL distro is not converted into a fragile CKA target node;
- CKA node-level work occurs in disposable environments.

## 9. Exam-day readiness

This is independent from lab readiness. Before scheduling or sitting an exam:

- portal eligibility, SKU, and retake terms are rechecked;
- current exam version, allowed resources, and PSI requirements are rechecked;
- the PSI system check and tutorial pass on physical Windows;
- one supported monitor is active and other displays are disconnected;
- webcam, microphone, network, ID, and room meet the current rules;
- WSL, containers, VMs, VPNs, sync tools, and other prohibited or disruptive applications are closed as required;
- the first attempt leaves meaningful time before eligibility expiry for remediation and an eligible retake.

## 10. Falsification questions used at every release gate

1. Which factual claim would fail first if CNCF or Linux Foundation changed the exam today?
2. Can a fresh learner reproduce the artifact from only the committed instructions?
3. Does the grader recognize valid alternatives and reject realistic near-misses?
4. What unrelated local resource could this setup, reset, or teardown damage?
5. Is every reused asset legally redistributable and traceable to a pinned source?

Any unresolved answer blocks the affected release claim; it does not automatically block unrelated work.
