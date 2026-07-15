# Week 0 Resources

Read only what helps you execute Week 0. Policy and version pages are live documents; recheck them before each mock and shortly before the real exam.

## Read before starting

1. [Important Instructions: CKA and CKAD](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad) — remote desktop, task hosts, supplied tools, and exam behavior.
2. [ExamUI for performance-based exams](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/examui-performance-based-exams) — interaction and workstation constraints.
3. [Resources allowed in Linux Foundation certification exams](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed) — the boundary your no-hint drills will follow.
4. [CNCF certification curricula](https://github.com/cncf/curriculum) — official blueprint repository; use the current CKA and CKAD PDFs, not community weight tables.

## Keep open during setup

- [Install `kubectl` on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) — checksum and version-skew reference.
- [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/) — disposable cluster lifecycle. The repository pins its own Kubernetes node image rather than using kind's moving default.
- [Kubernetes version-skew policy](https://kubernetes.io/releases/version-skew-policy/) — supported client/server relationships.

## Use only if a check fails

- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/) — only when the WSL Docker server is missing or unhealthy.
- [Microsoft: systemd in WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd) — only when the doctor reports that systemd is not PID 1.

## Paid course mapping

Do not copy LFS258 or LFS/LFD259 text, screenshots, labs, or answers. Week 0 only records entitlement and access dates; course-module mapping begins with the relevant CKA or CKAD week.
