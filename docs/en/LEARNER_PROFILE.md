# Learner Profile and Accelerated Route

Version: 0.1
Last updated: 2026-07-15

## 1. Reference learner

This project is designed around a rusty practitioner rather than a true beginner.

Prior exposure:

- followed an early Kelsey Hightower zero-to-cluster Kubernetes learning series approximately six or seven years ago;
- manually set up a Kubernetes environment at that time;
- understands what a cluster is and retains a rough architecture model;
- currently reviews Helm chart configuration at work;
- can research, test, and inspect provider consoles when a Kubernetes task arises.

Current gap:

- Kubernetes is not used frequently enough to retain command-line speed;
- cluster inspection and debugging are usually performed just in time with search or console help;
- knowledge is fragmented rather than organized against the current CKA/CKAD blueprints;
- older mental models may contain removed APIs, outdated commands, or historical runtime assumptions;
- there is little recent practice solving unfamiliar terminal tasks under a fixed clock.

## 2. Strengths to exploit

- architectural concepts can be reactivated faster than taught from zero;
- Helm familiarity provides a bridge into templates, values, releases, and application packaging;
- prior first-principles setup experience helps with CKA architecture and troubleshooting;
- workplace context makes configuration and operational failure scenarios meaningful;
- independent research habits support efficient official-document navigation.

## 3. Training priorities

Practice time is ordered as follows:

1. terminal and `kubectl` fluency;
2. correct host, context, namespace, and resource targeting;
3. reading events, logs, conditions, manifests, and component/service state;
4. CKA architecture, installation, networking, storage, and troubleshooting;
5. CKAD application design, deployment, security, observability, and fast manifest editing;
6. official-document navigation without general web search;
7. timed mixed scenarios and recovery after mistakes;
8. theory review only where diagnostics show a gap.

## 4. Diagnostic rules

The initial diagnostic should sample every shared foundation and CKA domain without pretending to be a full mock. It should measure:

- command recall and completion time;
- YAML editing accuracy;
- object and controller mental models;
- service/DNS/network reasoning;
- storage and scheduling reasoning;
- cluster component recognition;
- evidence-first debugging behavior;
- ability to verify final state.

Classification:

- **Green** — complete an unseen hands-on task without hints and explain the observed state; compress the corresponding lesson.
- **Yellow** — recognize the concept but need documentation, repeated commands, or debugging guidance; retain drills and a short explanation.
- **Red** — cannot form a correct model or recover the task; complete the full lesson and remediation lab.

Recognition alone is never Green.

## 5. Course integration loop

Each paid-course module is processed through:

> Course module → retrieval note → local guided lab → broken-state drill → timed independent task → blueprint coverage update

This prevents passive course completion from becoming the progress metric. A course module is considered mastered only when its corresponding task and verification gate pass.

## 6. Recommended 10–12 week route

- Week 0: environment and diagnostic.
- Weeks 1–2: compressed refresh and early LFS258.
- Weeks 3–5: CKA depth, troubleshooting, and timed drills.
- Week 6: CKA mocks and first attempt if ready.
- Weeks 7–8: LFS259 CKAD delta.
- Week 9: CKAD scenarios and debugging.
- Week 10: CKAD mocks and first attempt if ready.
- Weeks 11–12: remediation, rescheduling, or early eligible retake.

This route assumes approximately 10–12 focused study hours per week. An 8–9 week route requires closer to 15 focused hours per week and strong diagnostic performance. These are project planning assumptions, not official estimates.

## 7. Longer path

After both paid bundle exams are complete, CKS becomes the logical next track. Current CNCF rules require the candidate to have passed CKA before attempting CKS. The CKA-first route therefore creates the prerequisite, but CKS-specific material is intentionally excluded from the current sprint so it does not dilute the two-exam target.

## 8. Open scheduling input

The plan still needs:

- focused hours available per week;
- preferred weekday/weekend study pattern;
- known work or travel blackout dates;
- exact course-access and exam eligibility dates from My Portal.
