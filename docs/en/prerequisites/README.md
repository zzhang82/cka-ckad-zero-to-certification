# Prerequisites Before Week 0

You are ready for Week 0 when you can complete the checks below without copying a solution. Use the resources only for areas you cannot yet demonstrate.

## 1. Linux shell and Git

You should be able to:

- navigate and inspect files with `pwd`, `cd`, `ls`, `cat`, and `less`;
- search and transform text with `grep`, `find`, pipes, and redirection;
- edit a text file, change permissions, and inspect a process;
- clone a Git repository and read `git status` and `git diff`.

Resources:

- [GNU Bash manual](https://www.gnu.org/software/bash/manual/bash.html) — authoritative reference; use it to look up redirection, pipelines, and shell behavior.
- [Pro Git: Getting Started](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control) — official Git book; read Chapters 1–2 as needed.
- [Microsoft: Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands) — Windows/WSL-specific command reference.

Check:

```bash
printf 'pod\nservice\npod\n' | sort -u > /tmp/kinds.txt
grep -Fxq service /tmp/kinds.txt
chmod 600 /tmp/kinds.txt
git status --short
```

## 2. YAML

You should be able to find indentation mistakes and distinguish maps, lists, strings, booleans, and numbers.

Resources:

- [YAML 1.2.2 specification](https://yaml.org/spec/1.2.2/) — authority for the format; use the examples and productions as a reference.
- [Kubernetes: Declarative management using configuration files](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/) — shows how YAML becomes Kubernetes API objects.

Check: write a valid YAML document with an `app` map, two labels, a `ports` list, and a multiline note; parse it with `yq` after Week 0 installs the pinned tool.

## 3. Containers and images

You should be able to explain why an image is immutable input while a container is a running process with a writable layer.

Resources:

- [Docker: What is a container?](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/) — concise container/image model.
- [Dockerfile overview](https://docs.docker.com/build/concepts/dockerfile/) — image build inputs and layers.

Check:

```bash
docker run --rm --name prereq-pause -d registry.k8s.io/pause:3.10
docker ps --filter name=prereq-pause
docker image inspect registry.k8s.io/pause:3.10 >/dev/null
docker rm -f prereq-pause
```

Explain why the container is gone after removal while the image remains available locally.

## 4. Networking and HTTP

You should be able to explain an IP address, TCP port, DNS lookup, HTTP request, and the difference between listening only on `127.0.0.1` and on all interfaces.

Resources:

- [MDN: Overview of HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Overview) — request/response model.
- [Kubernetes cluster networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/) — the networking model you will build on later.
- [Kubernetes DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) — preview of names and search domains inside a cluster.

Check: run a local HTTP server, identify its listening port, request it with `curl`, and stop it.

```bash
python3 -m http.server 8000 >/tmp/prereq-http.log 2>&1 &
server_pid=$!
curl -I http://127.0.0.1:8000
kill "$server_pid"
```

## Ready signal

Move to [Week 0](../../../weeks/week-00/README.md) when every check is either complete or has a specific remediation block in your private plan. Do not wait for perfect recall; Week 0 measures the Kubernetes-specific baseline.
