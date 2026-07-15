# CKA + CKAD Zero-to-Certification Lab

An English-first, Windows/WSL2-based learning system for reactivating prior Kubernetes knowledge and reaching exam-ready performance for the Certified Kubernetes Administrator (CKA) and Certified Kubernetes Application Developer (CKAD) exams.

Status: **Week 0 environment gate passed; learner placement diagnostic pending**. The repository contains the planning baseline, pinned WSL toolchain, tested single-node and multi-node lab profiles, smoke grader, source policy, and acceptance standard. Week 0 does not pass until the learner completes the diagnostic and remediation map.

## Outcome

The project is successful when the learner:

1. targets first CKA and CKAD attempts within 10–12 weeks and passes both before the voucher eligibility deadlines;
2. can solve unfamiliar Kubernetes tasks and diagnose broken states under time pressure;
3. has a repeatable local lab environment that can be checked, reset, and rebuilt safely; and
4. leaves behind a public-quality Markdown curriculum, scenario library, mock-exam system, and static documentation site that other learners can use.

## Current verified exam baseline

Verified on **2026-07-15** from CNCF and Linux Foundation sources:

| Item | CKA | CKAD |
|---|---|---|
| Format | Online, remotely proctored, performance-based command-line exam | Same |
| Duration | 2 hours | 2 hours |
| Published task range | 15–20 performance tasks | 15–20 performance tasks |
| Passing score | 66% | 66% |
| Current exam Kubernetes version | v1.35 | v1.35 |
| Standard purchase | One attempt plus one retake after a failed attempt | Same |

The exact voucher SKU and eligibility date shown in the learner's Linux Foundation portal override this general baseline. Products marked `SINGLE` or `SINGLE-ATTEMPT` have different benefits.

## Committed route

The learner has already purchased Kubernetes Fundamentals (`LFS258`), Kubernetes for Developers (shown to the learner as `LFS259`), and the CKA + CKAD exam bundle. The project will therefore use this spine:

> Beginner prerequisites → shared foundations → LFS258 → CKA → LFS259 → CKAD → protected retake buffer

CKA comes first because it establishes the broader cluster architecture, networking, storage, scheduling, and troubleshooting model. CKAD then becomes a focused application-development delta on top of the shared Kubernetes skills.

Every learning unit will use the same loop:

> Understand → Observe → Practice with guidance → Solve alone → Debug → Validate → Repeat under time

The first implementation milestone is one complete vertical slice—not a large pile of notes. It must include a beginner explanation, guided lab, independent task, debugging variant, grader, reset path, progress record, generated ZIP, and minimal rendered page.

The reference learner is not starting from zero: they previously built Kubernetes from first principles, currently review Helm charts and understand cluster concepts, but have rusty command-line and troubleshooting muscle memory. The plan therefore uses diagnostics to skip proven material and spends most practice time in the terminal.

## Planning documents

- [Project plan](docs/en/PROJECT_PLAN.md)
- [Learner profile and accelerated route](docs/en/LEARNER_PROFILE.md)
- [Acceptance standard](docs/en/ACCEPTANCE_STANDARD.md)
- [Exam research baseline](docs/en/RESEARCH_BASELINE_2026-07-15.md)
- [Local environment audit](docs/en/ENVIRONMENT_AUDIT_2026-07-15.md)
- [Source and license policy](docs/en/SOURCE_POLICY.md)

## Working decisions

- V1 supports Windows 11 + WSL2 only; macOS is out of scope.
- `Ubuntu-24.04-D` will be the canonical lab shell.
- The existing native Docker Engine inside WSL is the initial runtime.
- `kind` is the leading candidate for foundation, LFS258, and most workload/application labs.
- CKA node and `kubeadm` work will use disposable machines later rather than modifying the primary WSL distro.
- The paid Linux Foundation courses are the instructional spine; this repository supplies prerequisite teaching, reproducible local practice, debugging depth, spaced repetition, mock exams, and grading.
- English Markdown is canonical. Chinese pages will mirror stable English page and lab IDs later.
- Official exam facts carry a `last_verified` date and are rechecked before mocks and real exam scheduling.
- Actual exam dumps, leaked questions, and reconstructed proprietary tasks are prohibited.

## Immediate next checkpoint

1. Record the exact course-access and CKA/CKAD portal expiry dates, SKU names, retake entitlement, and Killer.sh entitlement.
2. Confirm realistic weekly study hours.
3. Inventory the purchased LFS258/LFS259 modules and map them to the current CKA/CKAD blueprints.
4. Personally repeat the Week 0 smoke lab and record evidence.
5. Complete the timed Week 0 placement diagnostic and remediation map.
6. Implement the first Week 1 end-to-end learning slice before expanding the curriculum.

To begin the current checkpoint, open [Week 0 — Start Here](weeks/week-00/START_HERE.md). The workstation setup has been independently exercised; see the [Week 0 environment verification report](docs/en/WEEK0_ENVIRONMENT_VERIFICATION_2026-07-15.md).

Repository structure and environment operations are defined in [Architecture](ARCHITECTURE.md) and [Environment Lifecycle](docs/en/ENVIRONMENT_LIFECYCLE.md).

## Independence and ethics

This is an independent study project and is not endorsed by CNCF, the Linux Foundation, or PSI. It teaches public curriculum objectives with original or properly licensed exercises. It will not collect, reproduce, or solicit confidential exam content.
