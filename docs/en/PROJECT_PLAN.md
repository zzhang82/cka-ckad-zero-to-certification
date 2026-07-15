# Project Plan

Version: 0.1
Last updated: 2026-07-15
Target execution window: 10–12 weeks for first CKA and CKAD attempts, inside a one-year bundle window whose exact dates remain pending portal verification

## 1. Project objective

Create a complete beginner-to-certification system that enables one learner to pass CKA and CKAD within the purchased bundle window and that can later be published as a useful, maintainable GitHub project.

### Purchased learning and exam assets

User-confirmed on 2026-07-15:

- Kubernetes Fundamentals (`LFS258`) is purchased;
- Kubernetes for Developers is purchased and shown to the learner as `LFS259`;
- the CKA + CKAD dual exam bundle is purchased.

These assets are the main learning spine, not optional references. The project fills the gaps that a linear course does not reliably cover: true-beginner prerequisites, local reproducibility, repeated command practice, deliberately broken scenarios, grader-backed validation, timed mocks, remediation, and long-term progress tracking. Exact portal expiry dates and included retake/Killer.sh benefits still require portal verification.

### Learner baseline

The reference learner is a rusty practitioner, not a true beginner:

- followed an early Kelsey Hightower zero-to-cluster learning path approximately six or seven years ago and built a cluster manually;
- retains cluster, Kubernetes object, and architecture concepts;
- currently reviews Helm chart setup at work;
- uses documentation, search, tests, and provider consoles when Kubernetes work appears;
- rarely performs sustained `kubectl` investigation or cluster debugging from the terminal;
- wants one systematic pass through both theory and hands-on operations;
- ultimately wants CKS after CKA and CKAD.

The training consequence is diagnostic-driven compression. Familiar concepts receive short retrieval checks, while command fluency, evidence-driven diagnosis, cluster internals, and timed execution receive repeated hands-on work. See [LEARNER_PROFILE.md](LEARNER_PROFILE.md).

This is not only a reading curriculum. The deliverable combines:

- concept teaching for a true beginner;
- Linux, shell, YAML, container, and Kubernetes foundations;
- reproducible Windows/WSL2 lab infrastructure;
- guided exercises and independent scenarios;
- deliberately broken debugging scenarios;
- automated and manual scoring;
- timed mock exams and remediation;
- generated scenario ZIPs;
- English Markdown as the canonical source;
- a later Chinese mirror and static website.

## 2. Verifiable success condition

The learner passes both official exams before their eligibility deadlines. Before either attempt, the repository must also show evidence that the learner:

- passed two different unseen internal mocks under the readiness rules in [ACCEPTANCE_STANDARD.md](ACCEPTANCE_STANDARD.md);
- has no materially weak official blueprint domain;
- can work without project notes or AI help, using only resources permitted by the current exam policy;
- can select the correct host, context, and namespace before modifying state;
- can diagnose and verify rather than relying on random edits;
- has completed an exam-day PSI system check on the physical Windows machine.

## 3. Scope

### In scope for V1

- Windows 11 and WSL2 as the learner platform
- one canonical WSL lab toolchain
- shared prerequisite curriculum
- complete CKAD and CKA blueprint coverage
- local clusters and disposable machines appropriate to each task
- repeatable labs, debugging drills, and mock exams
- scenario metadata, setup, grading, reset, hints, and solutions
- local progress tracking
- Markdown documentation and generated static site
- English source content and later Chinese parity
- licensed open-source reuse with provenance

### Explicit non-goals for V1

- macOS support
- support for several interchangeable local cluster engines
- a custom hosted cloud lab service
- mobile applications, learner accounts, or cloud progress synchronization
- exact cloning of the proprietary PSI interface
- collecting or reconstructing real exam questions
- full Chinese translation before English content is stable
- building a general-purpose LMS
- teaching every Kubernetes feature outside the current CKA/CKAD scope

## 4. Design cut

The LJG-style routing review pointed to a first-principles cut followed by plain-language teaching. The public `ljg-rank` and `ljg-plain` molds are not installed here, so the project does not depend on them; their useful design pattern is implemented directly:

1. reduce the learning problem to a small set of generators;
2. explain each generator in beginner language;
3. prove understanding with observable work;
4. add visuals only where they clarify a relationship or failure flow.

The initial generators are:

- terminal and editor fluency;
- YAML and Kubernetes API object fluency;
- desired state versus observed state;
- scope control: host, cluster, context, namespace, and resource;
- the diagnosis loop: observe → hypothesize → test → repair → verify;
- command speed without sacrificing correctness;
- controlled recovery and reset.

## 5. Product architecture

### Curriculum layer

The curriculum and paid-course sequence is:

1. beginner prerequisites;
2. shared Kubernetes foundations;
3. LFS258-aligned CKA administration track;
4. CKA readiness, first attempt, and remediation;
5. LFS259-aligned CKAD application delta;
6. CKAD readiness, first attempt, and remediation;
7. protected retake and schedule buffer.

Each module maps to explicit official curriculum IDs and a Kubernetes minor-version range.

### Lab layer

The lab system must expose stable commands or scripts for:

- bootstrap;
- doctor/status;
- scenario seed;
- grading;
- reset;
- teardown;
- version report.

The lab must not rely on undocumented global shell state or overwrite unrelated kubeconfigs.

### Scenario layer

Each scenario has a stable ID and contains:

- metadata and prerequisites;
- expected time and difficulty;
- target exam/domain/objective;
- supported Kubernetes version;
- initial-state creator;
- learner task and constraints;
- automated grader;
- reset logic;
- separated hints;
- separated explanation/solution;
- source, license, and modification history.

Source folders are canonical. ZIP files are generated release artifacts with a version and checksum.

### Assessment layer

Assessment records correctness and speed separately. Automated grading checks observable final state and functional behavior, not one exact command sequence. Manual review checks the quality of diagnosis, validation, and recovery.

### Publishing layer

Markdown remains the source of truth. A later static-site framework will render the same files rather than create a second content store. Stable page IDs, lab IDs, code fences, and glossary terms are established before translation.

## 6. Roadmap and gates

### Stage 0 — Evidence and host audit

Deliverables:

- dated official-source register;
- current exam blueprint and policy snapshot;
- read-only Windows/WSL/runtime audit;
- initial source and license policy;
- open-decision list.

Exit gate:

- current external facts are cited and dated;
- host capabilities and missing tools are known;
- no state-changing setup has been performed;
- purchased courses and exam bundle are recorded, while exact portal dates and benefits are either recorded or explicitly unresolved.

Current status: purchases are confirmed; course-access dates, exam eligibility dates, retake entitlement, and Killer.sh entitlement remain open.

### Stage 1 — Product contract and repository skeleton

Deliverables:

- charter, roadmap, acceptance rules, and decisions;
- curriculum map;
- lab and scenario schemas;
- scoring and progress schemas;
- initial repository structure.

Exit gate: every first-slice artifact has a purpose, owner, source of truth, and testable acceptance rule.

### Stage 2 — Environment baseline

Deliverables:

- one documented WSL installation path;
- pinned version matrix;
- bootstrap, doctor, reset, teardown, and version-report tooling;
- isolated local cluster profile;
- recovery guide.

Exit gate:

- clean setup succeeds twice;
- doctor reports actionable failures;
- reset returns a known state;
- teardown removes only project-owned resources;
- no unrelated kubeconfig or cluster is changed;
- the cluster version is compatible with the current exam baseline.

### Stage 3 — First end-to-end vertical slice

Deliverables:

- one beginner lesson;
- one guided lab;
- one independent scenario;
- one debugging variant;
- automated grader and manual rubric;
- progress record;
- generated ZIP and checksum;
- minimal rendered documentation page.

Exit gate:

- a beginner can complete the loop from repository instructions alone;
- seed, grade, reset, and repeat all work;
- the grader distinguishes complete, partial, near-miss, and invalid states;
- the ZIP behaves like its source folder;
- learner feedback confirms the teaching level.

This stage is the **product V0.1** boundary. The current documents are the earlier **planning package v0.1**.

### Stage 4 — Shared foundations alpha

Deliverables:

- prerequisite modules;
- shared lab helpers;
- first diagnostic;
- debugging drill library;
- glossary and exam-document navigation practice.

Exit gate: no later module requires an unexplained command or concept, and all foundation scenarios pass on the pinned environment.

### Stage 5 — LFS258, CKA track, and readiness

Deliverables:

- module-level LFS258-to-CKA blueprint map;
- complete current CKA blueprint mapping;
- domain drills and mixed debugging sets;
- at least two independent mock forms;
- domain-based remediation.

Exit gate: the CKA readiness standard is met and the current official facts are reverified.

### Stage 6 — LFS259, CKAD delta, and readiness

Deliverables and gates mirror Stage 5, with LFS259 mapped to the current CKAD blueprint and a delta plan that avoids reteaching CKA/shared material unless remediation requires it.

### Stage 7 — Publication and localization

Deliverables:

- public static site;
- English release;
- Chinese mirror;
- contributor and maintenance guides;
- attribution inventory;
- versioned scenario releases and checksums.

Exit gate:

- raw Markdown and rendered pages are equivalent;
- English/Chinese page and lab IDs match;
- commands and code were not translated;
- no unlicensed material is redistributed;
- link, metadata, scenario, and translation-parity checks pass.

## 7. Accelerated study calendar

The primary target is two first attempts within 10–12 weeks. Exact dates will be calculated from portal eligibility and weekly capacity. The provisional 12-week lane assumes roughly 10–12 focused hours per week; an 8–9 week lane would require approximately 15 focused hours per week and faster diagnostic passes.

| Week | Target |
|---|---|
| Week 0 | Environment setup, command-speed baseline, and blueprint diagnostic |
| Weeks 1–2 | Compressed Linux/YAML/container/Kubernetes refresh plus early LFS258 modules |
| Weeks 3–5 | LFS258, CKA blueprint gaps, cluster/node troubleshooting, and timed domain drills |
| Week 6 | Two CKA mocks, readiness gate, and first CKA attempt if the gate passes |
| Weeks 7–8 | LFS259 and CKAD-specific design, deployment, configuration, security, and observability |
| Week 9 | CKAD independent scenarios, debugging sets, and timed domain drills |
| Week 10 | Two CKAD mocks, readiness gate, and first CKAD attempt if the gate passes |
| Weeks 11–12 | Immediate remediation, scheduling contingency, or an eligible early retake |
| Remaining bundle window | Protected long-stop buffer for retakes, unexpected interruptions, and optional CKS preparation |

The committed order is CKA first, then CKAD. Passing CKA also unlocks the future CKS path under the current CNCF prerequisite. Neither first attempt is scheduled merely because its target week arrived; the readiness gate remains mandatory.

## 8. Environment strategy

Current leading design:

- canonical shell: `Ubuntu-24.04-D` under WSL2;
- container runtime: existing native WSL Docker Engine;
- first local cluster engine: `kind`, pending a pinned-version smoke test;
- first tools to add: `kubectl`, `kind`, `helm`, and `yq` in WSL;
- advanced CKA node and `kubeadm` labs: disposable Linux machines, not the primary distro;
- Docker Desktop remains stopped unless a deliberate runtime migration is approved.

The real exam is taken through PSI Secure Browser on physical Windows, not inside WSL or a VM. Exam-day system readiness is therefore a separate gate from lab readiness.

## 9. Planned repository shape

```text
docs/
  en/
  zh/                 # added after English contracts stabilize
curriculum/
labs/
  shared/
scenarios/
  ckad/
  cka/
mocks/
tools/
schemas/
progress/
attribution/
site/
dist/                 # generated; not canonical source
```

The exact static-site framework is intentionally deferred until one vertical slice proves the content and lab contracts.

## 10. Main risks and controls

| Risk | Control |
|---|---|
| Exam blueprint or version changes | Dated source ledger; refresh before mock cycles and 1–2 weeks before scheduling |
| Setup work overtakes learning | One supported runtime path; smallest tool set; vertical slice first |
| Local multi-node instability | Resource budgets, doctor checks, pinned images, disposable advanced environments |
| Grader tests one implementation | Grade observable state and behavior; use positive, equivalent, negative, and partial fixtures |
| Source or license problems | Provenance ledger; vendor only approved licenses; link-only for missing/ambiguous licenses |
| Braindump contamination | Reject leaked/reconstructed tasks; use official objectives and original scenarios |
| Translation drift | English canonical; stable IDs; parity checks; Chinese after stabilization |
| Site work distracts from exam preparation | Minimal renderer only until the learning loop is proven |

## 11. Decisions required from the learner

Before the study calendar and environment setup are locked:

1. exact CKA and CKAD portal expiry dates;
2. exact course-access dates, exam SKU names, and whether retake/Killer.sh benefits are included;
3. realistic weekly study hours and preferred study days;
4. public-from-start versus private-until-alpha repository;
5. whether optional cloud spending is allowed later;
6. preferred Chinese style: literal technical mirror or explanatory localization.

## 12. First checkpoint

Finish Stage 0 and Stage 1, then implement one end-to-end vertical slice. Expansion to full curriculum begins only after the environment, teaching mold, grader, reset path, packaging, and basic rendering pass the vertical-slice gate.
