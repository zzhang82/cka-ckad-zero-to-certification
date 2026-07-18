#!/usr/bin/env python3
"""Pure Week 1 lab contracts shared by live graders and fixture tests."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


IMAGE = "registry.k8s.io/e2e-test-images/agnhost:2.53@sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85"
MODES = ("objects", "debug", "sprint")
NAMESPACES = {
    "objects": "week1-objects",
    "debug": "week1-debug",
    "sprint": "week1-sprint",
}


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return value if isinstance(value, dict) else {}


def metadata_matches(obj: dict[str, Any], name: str, namespace: str) -> bool:
    metadata = obj.get("metadata") or {}
    return metadata.get("name") == name and metadata.get("namespace") == namespace


def namespace_matches(obj: dict[str, Any], namespace: str) -> bool:
    return obj.get("kind") == "Namespace" and (obj.get("metadata") or {}).get("name") == namespace


def named_container(workload: dict[str, Any], name: str, *, template: bool = False) -> dict[str, Any]:
    spec = workload.get("spec") or {}
    if template:
        spec = ((spec.get("template") or {}).get("spec") or {})
    return next(
        (container for container in (spec.get("containers") or []) if container.get("name") == name),
        {},
    )


def first_container(workload: dict[str, Any]) -> dict[str, Any]:
    containers = ((workload.get("spec") or {}).get("containers") or [])
    return containers[0] if containers else {}


def image_is_exact(container: dict[str, Any]) -> bool:
    return container.get("image") == IMAGE


def command_tokens(container: dict[str, Any]) -> list[str]:
    tokens = [str(token) for token in (container.get("command") or []) + (container.get("args") or [])]
    if tokens and tokens[0] in {"agnhost", "/agnhost"}:
        tokens = tokens[1:]
    return tokens


def runs_netexec(container: dict[str, Any]) -> bool:
    tokens = command_tokens(container)
    return bool(tokens) and tokens[0] == "netexec" and "--http-port=8080" in tokens[1:]


def runs_pause(container: dict[str, Any]) -> bool:
    return command_tokens(container) == ["pause"]


def rollout_complete(deployment: dict[str, Any], name: str, namespace: str) -> bool:
    if not metadata_matches(deployment, name, namespace):
        return False
    metadata = deployment.get("metadata") or {}
    spec = deployment.get("spec") or {}
    status = deployment.get("status") or {}
    generation = metadata.get("generation")
    return (
        spec.get("replicas") == 2
        and generation is not None
        and status.get("observedGeneration") == generation
        and status.get("updatedReplicas") == 2
        and status.get("readyReplicas") == 2
        and status.get("availableReplicas") == 2
        and status.get("unavailableReplicas", 0) == 0
    )


def pod_ready(pod: dict[str, Any]) -> bool:
    return any(
        condition.get("type") == "Ready" and condition.get("status") == "True"
        for condition in ((pod.get("status") or {}).get("conditions") or [])
    )


def service_port_valid(service: dict[str, Any]) -> bool:
    return any(
        port.get("port") == 80 and port.get("targetPort") in {"http", 8080}
        for port in ((service.get("spec") or {}).get("ports") or [])
    )


def ready_endpoint(snapshot: dict[str, Any], service_name: str, namespace: str) -> bool:
    for item in (snapshot.get("endpoint_slices", {}).get("items") or []):
        metadata = item.get("metadata") or {}
        if metadata.get("namespace") != namespace:
            continue
        if (metadata.get("labels") or {}).get("kubernetes.io/service-name") != service_name:
            continue
        if any(
            endpoint.get("conditions", {}).get("ready") is True and bool(endpoint.get("addresses"))
            for endpoint in (item.get("endpoints") or [])
        ):
            return True
    return False


def readiness_probe_valid(container: dict[str, Any]) -> bool:
    http_get = ((container.get("readinessProbe") or {}).get("httpGet") or {})
    return http_get.get("path") == "/healthz" and http_get.get("port") in {"http", 8080}


def named_http_port_valid(container: dict[str, Any]) -> bool:
    return any(
        port.get("name") == "http" and port.get("containerPort") == 8080
        for port in (container.get("ports") or [])
    )


def selector_matches_labels(selector: dict[str, Any], labels: dict[str, Any]) -> bool:
    return bool(selector) and all(labels.get(key) == value for key, value in selector.items())


def evaluate(mode: str, snapshot: dict[str, Any]) -> dict[str, tuple[bool, str]]:
    if mode not in MODES:
        raise ValueError(f"unsupported mode: {mode}")

    namespace = NAMESPACES[mode]
    deployment = snapshot.get("deployment") or {}
    service = snapshot.get("service") or {}
    results: dict[str, tuple[bool, str]] = {
        "namespace": (
            namespace_matches(snapshot.get("namespace") or {}, namespace),
            f"namespace is exactly {namespace}",
        )
    }

    if mode == "objects":
        container = named_container(deployment, "web", template=True)
        deployment_metadata = deployment.get("metadata") or {}
        deployment_labels = deployment_metadata.get("labels") or {}
        template_labels = (((deployment.get("spec") or {}).get("template") or {}).get("metadata") or {}).get("labels") or {}
        selector = (((deployment.get("spec") or {}).get("selector") or {}).get("matchLabels") or {})
        results.update(
            {
                "deployment": (
                    rollout_complete(deployment, "object-web", namespace),
                    "object-web has exactly two fully rolled-out replicas",
                ),
                "image-command": (
                    image_is_exact(container) and runs_netexec(container) and named_http_port_valid(container),
                    "web uses the exact pinned image, netexec command, and named HTTP port",
                ),
                "metadata": (
                    deployment_labels.get("app.kubernetes.io/name") == "object-web"
                    and deployment_labels.get("lab.cka-ckad.dev/week") == "week-01"
                    and (deployment_metadata.get("annotations") or {}).get("lab.cka-ckad.dev/owner") == "learner"
                    and template_labels.get("app.kubernetes.io/name") == "object-web"
                    and template_labels.get("lab.cka-ckad.dev/week") == "week-01"
                    and selector_matches_labels(selector, template_labels),
                    "required labels and annotation are present, and the Deployment selector matches its Pod template",
                ),
                "readiness": (
                    readiness_probe_valid(container),
                    "web has the required /healthz readiness probe",
                ),
                "service": (
                    metadata_matches(service, "object-web", namespace)
                    and (service.get("spec") or {}).get("selector") == {"app.kubernetes.io/name": "object-web"}
                    and service_port_valid(service),
                    "Service selector and port match the task",
                ),
            }
        )
        service_name = "object-web"
    elif mode == "debug":
        container = named_container(deployment, "web", template=True)
        results.update(
            {
                "deployment": (
                    rollout_complete(deployment, "debug-web", namespace),
                    "debug-web has exactly two fully rolled-out replicas",
                ),
                "image-command": (
                    image_is_exact(container) and runs_netexec(container),
                    "web uses the exact pinned image and retains netexec",
                ),
                "service": (
                    metadata_matches(service, "debug-web", namespace)
                    and (service.get("spec") or {}).get("selector") == {"app": "debug-web"}
                    and service_port_valid(service),
                    "Service selector is repaired to app=debug-web",
                ),
            }
        )
        service_name = "debug-web"
    else:
        container = named_container(deployment, "web", template=True)
        pod = snapshot.get("pod") or {}
        pod_container = first_container(pod)
        template_labels = (((deployment.get("spec") or {}).get("template") or {}).get("metadata") or {}).get("labels") or {}
        results.update(
            {
                "pod": (
                    metadata_matches(pod, "sprint-probe", namespace)
                    and (pod.get("metadata") or {}).get("labels", {}).get("task") == "sprint-probe"
                    and image_is_exact(pod_container)
                    and runs_pause(pod_container)
                    and pod_ready(pod),
                    "sprint-probe is Ready with the pinned pause workload",
                ),
                "deployment": (
                    rollout_complete(deployment, "sprint-web", namespace)
                    and template_labels.get("app") == "sprint-web",
                    "sprint-web has two fully rolled-out replicas labeled app=sprint-web",
                ),
                "image-command": (
                    image_is_exact(container) and runs_netexec(container) and named_http_port_valid(container),
                    "web uses the exact pinned image, netexec command, and named HTTP port",
                ),
                "service": (
                    metadata_matches(service, "sprint-web", namespace)
                    and (service.get("spec") or {}).get("selector") == {"app": "sprint-web"}
                    and service_port_valid(service),
                    "Service selector is repaired to app=sprint-web",
                ),
            }
        )
        service_name = "sprint-web"

    results["endpoint-http"] = (
        ready_endpoint(snapshot, service_name, namespace) and snapshot.get("http_ok") is True,
        "Service has a ready EndpointSlice and responds over HTTP",
    )
    return results


def load_snapshot(directory: Path, http_ok: bool) -> dict[str, Any]:
    snapshot = {
        name: load_json(directory / f"{name}.json")
        for name in ("namespace", "deployment", "service", "endpoint_slices", "pod")
    }
    snapshot["http_ok"] = http_ok
    return snapshot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=MODES, required=True)
    parser.add_argument("--snapshot-dir", type=Path, required=True)
    parser.add_argument("--http-ok", action="store_true")
    args = parser.parse_args()

    results = evaluate(args.mode, load_snapshot(args.snapshot_dir, args.http_ok))
    for check, (passed, message) in results.items():
        print(f"{'PASS' if passed else 'FAIL'}  {check:<14} {message}")
    passed = all(result[0] for result in results.values())
    print(f"RESULT={'PASS' if passed else 'FAIL'} mode={args.mode}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
