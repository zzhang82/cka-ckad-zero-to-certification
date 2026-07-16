#!/usr/bin/env python3
"""Pure Week 0 placement contracts used by the live grader and fixture suite."""

from __future__ import annotations

import argparse
import base64
import binascii
import json
import re
from decimal import Decimal
from pathlib import Path
from typing import Any


NAMESPACE = "week0-diagnostic"
IMAGE_DIGEST = "sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85"
AREA_IDS = ("area-01", "area-02", "area-04", "area-05", "area-06", "area-07", "area-08", "area-09")


def metadata_matches(obj: dict[str, Any], name: str) -> bool:
    metadata = obj.get("metadata", {})
    return metadata.get("name") == name and metadata.get("namespace") == NAMESPACE


def pod_ready(pod: dict[str, Any]) -> bool:
    return any(
        condition.get("type") == "Ready" and condition.get("status") == "True"
        for condition in (pod.get("status", {}).get("conditions") or [])
    )


def first_container(workload: dict[str, Any], template: bool = False) -> dict[str, Any]:
    spec = workload.get("spec", {})
    if template:
        spec = spec.get("template", {}).get("spec", {})
    containers = spec.get("containers") or []
    return containers[0] if containers else {}


def image_is_pinned(container: dict[str, Any]) -> bool:
    return str(container.get("image", "")).endswith(f"@{IMAGE_DIGEST}")


def runs_agnhost_pause(container: dict[str, Any]) -> bool:
    command = container.get("command") or []
    args = container.get("args") or []
    tokens = [str(token) for token in command + args]
    return tokens in (["pause"], ["agnhost", "pause"], ["/agnhost", "pause"])


def deployment_rollout_complete(deployment: dict[str, Any]) -> bool:
    if not metadata_matches(deployment, "web"):
        return False
    desired = deployment.get("spec", {}).get("replicas")
    status = deployment.get("status", {})
    generation = deployment.get("metadata", {}).get("generation")
    return (
        desired == 3
        and generation is not None
        and status.get("observedGeneration") == generation
        and status.get("updatedReplicas") == desired
        and status.get("readyReplicas") == desired
        and status.get("availableReplicas") == desired
        and status.get("unavailableReplicas", 0) == 0
    )


def env_ref(
    deployment: dict[str, Any],
    env_name: str,
    ref_kind: str,
    ref_name: str,
    ref_key: str,
) -> bool:
    for entry in (first_container(deployment, template=True).get("env") or []):
        if entry.get("name") != env_name:
            continue
        reference = entry.get("valueFrom", {}).get(ref_kind, {})
        return reference.get("name") == ref_name and reference.get("key") == ref_key
    return False


def quantity_bytes(value: str) -> Decimal | None:
    match = re.fullmatch(r"([0-9]+(?:\.[0-9]+)?)(Ki|Mi|Gi|Ti|K|M|G|T)?", value)
    if not match:
        return None
    number = Decimal(match.group(1))
    suffix = match.group(2) or ""
    factors = {
        "": 1,
        "K": 1000,
        "M": 1000**2,
        "G": 1000**3,
        "T": 1000**4,
        "Ki": 1024,
        "Mi": 1024**2,
        "Gi": 1024**3,
        "Ti": 1024**4,
    }
    return number * factors[suffix]


def evaluate(snapshot: dict[str, Any]) -> dict[str, tuple[bool, str]]:
    results: dict[str, tuple[bool, str]] = {}

    results["area-01"] = (
        bool(snapshot.get("kinds_ok")),
        "shell pipeline output is exact",
    )

    yaml_pod = snapshot.get("yaml_pod", {})
    yaml_container = first_container(yaml_pod)
    yaml_ok = (
        metadata_matches(yaml_pod, "yaml-proof")
        and pod_ready(yaml_pod)
        and yaml_pod.get("metadata", {}).get("labels", {}).get("diagnostic") == "yaml"
        and image_is_pinned(yaml_container)
        and runs_agnhost_pause(yaml_container)
    )
    results["area-02"] = (yaml_ok, "yaml-proof is Ready and runs the required pinned workload")

    deployment = snapshot.get("deployment", {})
    deployment_ok = deployment_rollout_complete(deployment) and image_is_pinned(
        first_container(deployment, template=True)
    )
    results["area-04"] = (deployment_ok, "web has exactly three fully rolled-out pinned replicas")

    service = snapshot.get("service", {})
    endpoint_slices = snapshot.get("endpoint_slices", {})
    ready_endpoint = any(
        endpoint.get("conditions", {}).get("ready") is True and bool(endpoint.get("addresses"))
        for item in (endpoint_slices.get("items") or [])
        if item.get("metadata", {}).get("namespace") == NAMESPACE
        and item.get("metadata", {}).get("labels", {}).get("kubernetes.io/service-name") == "web"
        for endpoint in (item.get("endpoints") or [])
    )
    service_ok = (
        metadata_matches(service, "web")
        and service.get("spec", {}).get("selector", {}).get("app") == "diagnostic-web"
        and ready_endpoint
        and snapshot.get("http_ok") is True
    )
    results["area-05"] = (service_ok, "Service selector, ready endpoints, and HTTP are healthy")

    configmap = snapshot.get("configmap", {})
    config_ok = (
        metadata_matches(configmap, "app-config")
        and configmap.get("data", {}).get("MODE") == "diagnostic"
        and env_ref(deployment, "MODE", "configMapKeyRef", "app-config", "MODE")
        and deployment_rollout_complete(deployment)
    )
    results["area-06"] = (config_ok, "ConfigMap reference is correct and the rollout is complete")

    secret = snapshot.get("secret", {})
    encoded_token = secret.get("data", {}).get("token", "")
    try:
        token = base64.b64decode(encoded_token, validate=True).decode("utf-8")
    except (binascii.Error, ValueError, UnicodeDecodeError):
        token = ""
    secret_ok = (
        metadata_matches(secret, "api-credentials")
        and token == "ready"
        and env_ref(deployment, "API_TOKEN", "secretKeyRef", "api-credentials", "token")
        and deployment_rollout_complete(deployment)
    )
    results["area-07"] = (secret_ok, "Secret reference is correct and the rollout is complete")

    scheduled = snapshot.get("scheduled_pod", {})
    node_name = scheduled.get("spec", {}).get("nodeName")
    selected_node_ok = any(
        node.get("metadata", {}).get("name") == node_name
        and node.get("metadata", {}).get("labels", {}).get("diagnostic-ready") == "true"
        for node in (snapshot.get("nodes", {}).get("items") or [])
    )
    scheduling_ok = (
        metadata_matches(scheduled, "scheduled")
        and pod_ready(scheduled)
        and scheduled.get("spec", {}).get("nodeSelector", {}).get("diagnostic-ready") == "true"
        and bool(node_name)
        and selected_node_ok
    )
    results["area-08"] = (scheduling_ok, "scheduled retains its selector and runs on the labeled node")

    pvc = snapshot.get("pvc", {})
    storage_pod = snapshot.get("storage_pod", {})
    requested = quantity_bytes(str(pvc.get("spec", {}).get("resources", {}).get("requests", {}).get("storage", "")))
    volumes = {
        volume.get("name"): volume.get("persistentVolumeClaim", {}).get("claimName")
        for volume in (storage_pod.get("spec", {}).get("volumes") or [])
    }
    mounts = {
        mount.get("name"): mount.get("mountPath")
        for mount in (first_container(storage_pod).get("volumeMounts") or [])
    }
    storage_ok = (
        metadata_matches(pvc, "work-data")
        and pvc.get("status", {}).get("phase") == "Bound"
        and requested is not None
        and requested >= 64 * 1024**2
        and metadata_matches(storage_pod, "storage-check")
        and pod_ready(storage_pod)
        and volumes.get("data") == "work-data"
        and mounts.get("data") == "/data"
    )
    results["area-09"] = (storage_ok, "PVC is at least 64Mi and storage-check mounts it at /data")

    return results


def load_json(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


def load_snapshot(directory: Path, kinds_ok: bool, http_ok: bool) -> dict[str, Any]:
    names = (
        "yaml_pod",
        "deployment",
        "service",
        "endpoint_slices",
        "configmap",
        "secret",
        "scheduled_pod",
        "nodes",
        "pvc",
        "storage_pod",
    )
    snapshot = {name: load_json(directory / f"{name}.json") for name in names}
    snapshot["kinds_ok"] = kinds_ok
    snapshot["http_ok"] = http_ok
    return snapshot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot-dir", type=Path, required=True)
    parser.add_argument("--kinds-ok", action="store_true")
    parser.add_argument("--http-ok", action="store_true")
    args = parser.parse_args()

    results = evaluate(load_snapshot(args.snapshot_dir, args.kinds_ok, args.http_ok))
    score = 0
    for area_id in AREA_IDS:
        passed, message = results[area_id]
        if passed:
            score += 10
        print(f"{'PASS' if passed else 'FAIL'}  {area_id:<12} {message}")
    print(f"\nAUTOMATED_SCORE={score}/80")
    print("MANUAL_SCORE_REQUIRED=areas-03-and-10/20")
    print(
        "Complete the placement/SCORECARD.md in your configured learner workspace; "
        "this diagnostic does not auto-declare readiness."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
