# Choose Your Starting Path

All learners use the same weekly curriculum and the same hands-on gates. Your profile only decides how much prerequisite work to do and which already-proven topics may be compressed.

## Quick decision

| Profile | Use it when | First action |
|---|---|---|
| `beginner` | Linux shell, YAML, containers, or networking are unfamiliar | Complete the [prerequisite checklist](../prerequisites/README.md), then take all of Week 0 |
| `rusty` | You understand clusters and workloads but rely on search for most commands | Take all of Week 0; compress only skills you prove Green |
| `operator` | You currently administer or develop on Kubernetes from the terminal | Prove environment isolation, then take the Week 0 diagnostic without hints |

Initialize once from WSL:

```bash
bash ./study init --profile rusty
bash ./study open week-00
```

## True beginner

Choose `beginner` if two or more of these are unfamiliar:

- navigating, searching, piping, redirecting, editing, and changing permissions in a Linux shell;
- reading YAML indentation, lists, maps, strings, and multi-document files;
- explaining the difference between an image, container, process, port, and volume;
- explaining IP addresses, ports, DNS, and an HTTP request;
- using Git to clone a repository and inspect changes.

Complete the prerequisite exercises before treating the 12-week clock as started. You do not need to master Kubernetes installation first.

## Rusty practitioner

This is the default route for someone who has prior Kubernetes exposure or reviews Helm charts but has not recently worked from `kubectl` every day.

1. Complete the full Week 0 environment lifecycle twice.
2. Take the 90-minute placement diagnostic without AI, hints, or solution repositories.
3. Mark each area Green, Yellow, or Red from evidence—not recognition.
4. Compress explanation time for Green areas.
5. Keep drills for Yellow areas and full lessons plus remediation for Red areas.

## Current Kubernetes operator

Do not skip Week 0 entirely. Use it as a test:

1. prove the repository uses an isolated kubeconfig and scoped teardown;
2. take the same diagnostic without hints;
3. start at the earliest week containing an unresolved Yellow or Red objective;
4. never skip the CKA or CKAD timed mock gates.

A topic is Green only when you can complete an unseen task safely, verify the result, and explain the failure boundary. Familiar terminology is not enough.

## Route after Week 0

- **80–100, no Red safety result:** accelerated route is allowed.
- **50–79:** use the standard 12-week route.
- **0–49:** add foundation practice to Weeks 1–3.

The diagnostic places your work; it does not predict a certification result.
