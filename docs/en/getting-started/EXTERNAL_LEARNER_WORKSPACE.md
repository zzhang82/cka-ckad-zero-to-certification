# External Learner Workspace

The default study setup keeps personal plans, notes, evidence, and retrospectives under this repository's ignored `learner-state/` directory. That is the simplest option for most learners.

Use an external learner workspace when you want those records tracked in a separate private Git repository while this public repository remains a reusable curriculum and lab tool.

Use a separate repository, not a private fork or Git submodule of this public repository.

## Connect a private workspace

Set `CKA_CKAD_LEARNER_DIR` before running the public `study` command:

```bash
export CKA_CKAD_LEARNER_DIR="$HOME/code/cka-ckad-learning-companion/journal"
bash ./study init --profile operator
bash ./study open week-00
```

An absolute path is used as written. A relative path is resolved from the public repository root, not from the caller's current directory.

The learner directory may be tracked by its own private repository. The public `study` command does not apply this repository's Git-ignore rules to an external path.

## What remains in the public repository

Runtime state always remains under this repository's ignored `.state/` directory, including:

- kubeconfig;
- generated shell runtime files;
- temporary cluster state and runtime configuration;
- temporary environment evidence.

Do not move `.state/` into the private learner repository.

## Safety and privacy

The command refuses an internal learner path that is tracked or not ignored. It also refuses overlap with the public repository root, `.git/`, or `.state/`.

Keep the external repository private permanently. Store distilled learning records rather than unlimited transcripts. Do not store:

- kubeconfig, credentials, tokens, private keys, or API keys;
- copied LFS course pages, transcripts, labs, screenshots, or media;
- recalled or reconstructed certification questions;
- full terminal recordings or large raw logs.

The public repository accepts only generalized, original, and sanitized improvements. Personal records do not become public contribution material automatically.

## Return to the default

Unset the variable to return to ignored local `learner-state/` behavior:

```bash
unset CKA_CKAD_LEARNER_DIR
bash ./study status
```

Unsetting the variable does not move or delete existing learner files.
