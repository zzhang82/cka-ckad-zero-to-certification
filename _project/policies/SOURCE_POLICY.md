# Source and License Policy

Version: 0.1
Last updated: 2026-07-15

## 1. Purpose

This project should reuse strong existing work when lawful and useful. It must not confuse public availability with permission to copy, or community popularity with current exam authority.

## 2. Source authority

| Tier | Source type | Allowed use |
|---|---|---|
| A | Current CNCF, Linux Foundation, PSI, Kubernetes, Helm, Gateway API documentation | Authority for current exam and platform facts |
| B | Official open-source repositories and specifications | Technical implementation evidence, subject to version and license |
| C | Licensed community study repositories | Supplemental examples and adaptation candidates |
| D | Blogs, videos, forums, and personal exam reports | Discovery and learner-experience signals only; never policy authority |
| Reject | Braindumps, leaked questions, reconstructed current exams, paywalled copies, access-control bypasses | Never collect, use, cite, or redistribute |

## 3. Provenance record

Weekly `RESOURCES.md` pages are the canonical learner selection. The machine catalog records source families, policy-critical sources, purchased material, and community adoption candidates; it does not need a duplicate row for every official Kubernetes documentation subpage that a weekly list links.

Before an external asset is copied or adapted, record:

- source title and canonical URL;
- owner or organization;
- upstream license and license URL;
- exact commit, tag, or retrieval date;
- original file or section;
- intended local use;
- whether content is copied, adapted, or only linked;
- modifications made;
- required attribution or notice;
- Kubernetes/tool version claimed upstream;
- local validation performed;
- reviewer and review date.

## 4. Dispositions

- **Vendor/adapt** — license is compatible, attribution is recorded, source is pinned, and local tests pass.
- **Link/reference only** — useful source but no license, unclear license, incompatible terms, high migration cost, or no need to copy.
- **Idea only** — independently design an original scenario from a public curriculum objective; do not copy expression or solution text.
- **Reject** — confidential, leaked, unauthorized, deceptive, or unsafe material.

No repository is vendored merely because it has a `LICENSE` badge. The license text, scope, notices, dependencies, and conflicting file-level statements must be checked.

## 5. Current reuse rules

- CNCF curriculum: CC-BY 4.0+; may be mapped and quoted sparingly with attribution.
- MIT and Apache-2.0 exercise repositories: adaptation candidates after version mapping and tests.
- GPL content: requires a deliberate distribution decision before copying; linking is safer during planning.
- missing or ambiguous license: link only unless permission is obtained.
- proprietary course content: do not copy; record only a link and optional purchase recommendation.
- actual exam reports: may identify broad study gaps, but task wording, unique details, answers, and reconstructions are excluded.

## 6. Data collection boundaries

Allowed:

- manual review of public pages;
- official APIs where available;
- normal Git clone/download of public repositories;
- storing small metadata, licenses, hashes, and our own analysis;
- preserving required attribution notices.

Not allowed:

- bypassing login walls, CAPTCHAs, access controls, or rate limits;
- scraping or republishing paywalled courses;
- storing personal portal or payment data in the repository;
- using learner credentials in automation;
- redistributing a source that lacks permission merely because its HTML or files are accessible.

## 7. Freshness and maintenance

Exam policy and blueprint sources are reverified:

- at least monthly during active development;
- before each full mock cycle;
- before a Kubernetes minor-version migration;
- 1–2 weeks before scheduling an exam;
- during final exam-day review.

Community resources are rechecked when pinned, upgraded, or redistributed. A recently updated repository can still contain an obsolete curriculum map; activity is not proof of relevance.

## 8. Value without risky sources

The project remains viable without any ambiguous community repository. Its core can be built from official open curricula and documentation plus original scenarios and graders. Community work accelerates coverage but is not a critical dependency.

Decision: **continue**, with official-source authority, license-first reuse, pinned provenance, and a hard rejection of confidential exam material.
