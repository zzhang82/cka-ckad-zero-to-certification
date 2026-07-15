# CKA and CKAD Research Baseline — 2026-07-15

Status: official facts verified on 2026-07-15; community resources are candidates only.

## 1. Official exam facts

| Fact | CKA | CKAD |
|---|---:|---:|
| Delivery | Online, remotely proctored, performance-based Linux command line | Same |
| Duration | 2 hours | 2 hours |
| Task range | 15–20 | 15–20 |
| Passing score | 66% | 66% |
| Current environment | Kubernetes v1.35 | Kubernetes v1.35 |
| Normal result timing | Within 24 hours | Within 24 hours |
| Certification validity | 2 years after passing | 2 years after passing |
| Task languages | English, Simplified Chinese, Japanese | Same |

Primary sources:

- [CNCF CKA certification page](https://www.cncf.io/training/certification/cka/)
- [CNCF CKAD certification page](https://www.cncf.io/training/certification/ckad/)
- [Linux Foundation CKA/CKAD/CKS FAQ](https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks)
- [CKA/CKAD important instructions](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

## 2. Current blueprint weights

### CKA

| Domain | Weight |
|---|---:|
| Cluster Architecture, Installation & Configuration | 25% |
| Workloads & Scheduling | 15% |
| Services & Networking | 20% |
| Storage | 10% |
| Troubleshooting | 30% |

### CKAD

| Domain | Weight |
|---|---:|
| Application Design and Build | 20% |
| Application Deployment | 20% |
| Application Observability and Maintenance | 15% |
| Application Environment, Configuration and Security | 25% |
| Services and Networking | 20% |

Authoritative curriculum files:

- [CNCF curriculum repository](https://github.com/cncf/curriculum), licensed CC-BY 4.0+
- [CKA Curriculum v1.35](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.35.pdf)
- [CKAD Curriculum v1.35](https://github.com/cncf/curriculum/blob/master/CKAD_Curriculum_v1.35.pdf)

## 3. Version-drift finding

The exam currently uses v1.35, while Kubernetes v1.36 was released on 2026-04-22 and v1.36.2 was current by 2026-06-09. Linux Foundation says the exam is generally aligned to a new Kubernetes minor within approximately 4–8 weeks, but the v1.35 exam baseline remained published 12 weeks after the v1.36 release.

Project decision: the update window is a target, not a guaranteed date. Every lesson and scenario records its supported Kubernetes version. Recheck the exam version:

- before each full mock cycle;
- before pinning or refreshing lab images;
- 1–2 weeks before scheduling each real exam;
- immediately before the final readiness review.

Sources:

- [Kubernetes release history](https://kubernetes.io/releases/)
- [Kubernetes v1.36 release announcement](https://kubernetes.io/blog/2026/04/22/kubernetes-v1-36-release/)
- [Linux Foundation important instructions](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

## 4. Exam environment and ergonomics

The current instructions describe a Linux remote desktop inside PSI Secure Browser. Each task identifies a designated host. The candidate connects with `ssh`, may use `sudo`, completes the task, exits back to the base system, and must not use nested SSH.

Task hosts include `kubectl` with `k` alias and Bash completion, `yq`, `curl`, `wget`, `man`, and distribution documentation. The base host intentionally does not provide the task tools. Terminal copy/paste uses `Ctrl+Shift+C` and `Ctrl+Shift+V`. The base node must not be rebooted.

Project implications:

- practice host, context, and namespace selection explicitly;
- grade final state and behavior rather than one command sequence;
- include SSH-like designated-host transitions in advanced scenarios;
- train terminal-only workflows and documentation navigation;
- use broken-state scenarios, not only object-creation drills.

## 5. Allowed resources

Current CKA/CKAD policy permits the browser inside the exam VM to access:

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubernetes Blog](https://kubernetes.io/blog/)
- [Helm Documentation](https://helm.sh/docs/)
- task-specific Quick Reference links
- CKA only: [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)

The Kubernetes documentation's own search may be used, but external search results must not be opened. Host-side notes, other browser windows or applications, phones, AI assistance, and third-party research are not permitted.

Source: [Linux Foundation allowed resources](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed).

## 6. Voucher, scheduling, and retake baseline

- Standard registrations normally provide 12 months to take the exam.
- Standard exam purchases include one retake after a failed attempt.
- `SINGLE` or `SINGLE-ATTEMPT` products do not include that retake.
- A no-show forfeits the registration and retake.
- Rescheduling or cancellation must occur more than 24 hours before the reservation.
- The exact eligibility date and benefits in My Portal are authoritative.
- PSI may display a date after eligibility expiry; selecting it does not extend eligibility.

Sources:

- [Exam Terms of Service](https://docs.linuxfoundation.org/tc-docs/certification/exam-terms-of-service)
- [Coupon registration guide](https://docs.linuxfoundation.org/tc-docs/certification/quick-guide/exam-registration-using-a-coupon-code)
- [Scheduling and rescheduling](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/scheduling-or-rescheduling-an-exam)

Unresolved for this learner:

- exact CKA and CKAD expiry dates;
- exact purchased SKUs;
- retake entitlement;
- Killer.sh entitlement;
- whether a promotional voucher-code redemption deadline differs from the later exam eligibility date.

## 7. Exam-day physical machine baseline

Current PSI/LF material supports physical 64-bit Windows 10/11 and does not support taking the exam inside a VM. One active monitor is allowed. LF recommends at least a 15-inch display and 1080p; PSI lists 8 GB RAM minimum and 16 GB recommended. A movable webcam, microphone, reliable network, and compliant room are required.

WSL and Hyper-V are appropriate for study labs, but the exam launches through PSI Secure Browser on physical Windows. The project will require a live [PSI system check](https://syscheck.bridge.psiexams.com/) and tutorial before exam day.

Source: [PSI Secure Browser system requirements](https://helpdesk.psionline.com/hc/en-gb/articles/4409608794260-PSI-secure-browser-and-Chrome-Extension-System-Requirements).

## 8. Official learning spine

- [Introduction to Kubernetes (LFS158)](https://training.linuxfoundation.org/training/introduction-to-kubernetes/) — free beginner course
- [Kubernetes Fundamentals (LFS258)](https://training.linuxfoundation.org/training/kubernetes-fundamentals/) — CKA-oriented course; user-confirmed purchased
- [Kubernetes for Developers](https://training.linuxfoundation.org/training/kubernetes-for-developers/) — CKAD-oriented course; user-confirmed purchased and shown in the learner's purchase as `LFS259` (the current public product page may label it `LFD259`)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [kubectl Quick Reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
- [Troubleshooting Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshooting Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)

The CKA + CKAD dual exam bundle is also user-confirmed purchased. Exact portal eligibility dates and benefits remain to be recorded. Killer.sh access, if included with the purchase, should be reserved until after at least one complete internal mock because activations are time-limited.

## 9. Community candidate register

These are supplemental candidates, not authorities for current exam facts.

| Candidate | Potential use | Current disposition |
|---|---|---|
| [dgkanatsios/CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) | Large CKAD exercise bank | MIT; adaptation candidate, but legacy domain weights require remapping |
| [bmuschko/cka-study-guide](https://github.com/bmuschko/cka-study-guide) | Organized CKA examples | Apache-2.0; version migration and test required |
| [bmuschko/ckad-study-guide](https://github.com/bmuschko/ckad-study-guide) | Broad CKAD examples | Apache-2.0; older Kubernetes baseline creates higher migration cost |
| [KodeKloud CKA course repository](https://github.com/kodekloudhub/certified-kubernetes-administrator-course) | Notes and lab ideas | No confirmed repository license; link/reference only |
| [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) | Control-plane architecture depth | Not exam-efficient for beginners; license/version review unresolved, link only |

No candidate is vendored until the checks in [the source policy](../policies/SOURCE_POLICY.md) pass.

## 10. Research caveats

- Official pages disagree on whether the visible scheduling window is 60 or 90 days; live My Portal/PSI state wins.
- The allowed-resources page does not clearly authorize dependence on the separate versioned documentation subdomain. Training should work from the documented allowlist.
- Hyper-V is not explicitly prohibited as a Windows feature, but live PSI checks may require WSL, VM, container, or background processes to be closed.
- Community repositories can be recently active while retaining obsolete curriculum mappings.

## 11. Future CKS path

CKS is a future project objective, not part of the current 10–12 week CKA/CKAD delivery scope. As verified on 2026-07-15, a candidate must have passed CKA before attempting CKS; CNCF currently states that the CKA does not have to remain active. This reinforces the CKA-first sequence without allowing CKS content to distract from the paid two-exam bundle.

Source: [CNCF CKS certification page](https://www.cncf.io/training/certification/cks/).
