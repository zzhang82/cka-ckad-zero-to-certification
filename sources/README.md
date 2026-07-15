# Source Intake and Feasibility

## Required data

- current CKA/CKAD blueprint, version, policy, environment, and allowed resources;
- purchased-course module mapping without copying proprietary content;
- official technical documentation for every objective;
- community exercise candidates, license, pinned revision, and local test result;
- version and checksum sources for installed tools.

## Allowed sources

- CNCF, Linux Foundation, PSI, Kubernetes, Helm, Gateway API, kind, Microsoft, and official project repositories;
- user-entitled LFS258/LFS259 portal content for personal study and module mapping;
- public community repositories with compatible licenses;
- manual review of public pages and normal public Git/GitHub access.

## Prohibited or ambiguous sources

- braindumps, leaked tasks, reconstructed current exams, or confidential answers;
- copying proprietary LFS/Killer.sh content into the public repository;
- vendoring repositories with no license or conflicting terms;
- bypassing login walls, CAPTCHA, rate limits, or access controls;
- assuming recent repository activity proves current blueprint relevance.

## Storage and display constraints

- Store public URLs, metadata, licenses, hashes, and original analysis.
- Store paid-course module IDs and completion state only in ignored learner data when necessary.
- Do not store portal credentials, personal order data, screenshots, course text, or kubeconfigs.
- Adapted licensed content must retain attribution and a modification record.

## Cost and maintenance

- Official sources are free to review but version-sensitive.
- LFS258/LFS259 are already purchased; their access dates remain to be recorded.
- Killer.sh is used only if included and reserved until readiness practice.
- External facts are rechecked weekly during the sprint, before mocks, before scheduling, and 72 hours before an exam.

## Value without risky sources

The project remains complete using paid courses, official open curricula/documentation, and original scenarios. Community repositories are accelerators, never critical dependencies.

Decision: **continue** with official-first authority, link/map-only proprietary sources, license-gated community adoption, and no confidential exam material.

The machine-readable ledger is `catalog.json`; the human weekly view is `WEEKLY_RESOURCE_MAP.md`.
