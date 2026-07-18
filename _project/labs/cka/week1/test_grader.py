#!/usr/bin/env python3
"""Adversarial pure fixtures for all Week 1 grader modes."""

from __future__ import annotations

import copy
import unittest

from grader import IMAGE, MODES, NAMESPACES, evaluate


def metadata(name: str, namespace: str, **extra: object) -> dict:
    result = {"name": name, "namespace": namespace}
    result.update(extra)
    return result


def deployment(name: str, namespace: str, labels: dict[str, str]) -> dict:
    return {
        "metadata": metadata(name, namespace, generation=3),
        "spec": {
            "replicas": 2,
            "selector": {"matchLabels": copy.deepcopy(labels)},
            "template": {
                "metadata": {"labels": copy.deepcopy(labels)},
                "spec": {
                    "containers": [
                        {
                            "name": "web",
                            "image": IMAGE,
                            "args": ["netexec", "--http-port=8080"],
                            "ports": [{"name": "http", "containerPort": 8080}],
                            "readinessProbe": {"httpGet": {"path": "/healthz", "port": "http"}},
                        }
                    ]
                },
            },
        },
        "status": {
            "observedGeneration": 3,
            "updatedReplicas": 2,
            "readyReplicas": 2,
            "availableReplicas": 2,
        },
    }


def valid_snapshot(mode: str) -> dict:
    namespace = NAMESPACES[mode]
    if mode == "objects":
        name = "object-web"
        labels = {
            "app.kubernetes.io/name": "object-web",
            "lab.cka-ckad.dev/week": "week-01",
        }
        deploy = deployment(name, namespace, labels)
        deploy["metadata"]["labels"] = copy.deepcopy(labels)
        deploy["metadata"]["annotations"] = {"lab.cka-ckad.dev/owner": "learner"}
        selector = {"app.kubernetes.io/name": "object-web"}
    elif mode == "debug":
        name = "debug-web"
        labels = {"app": "debug-web"}
        deploy = deployment(name, namespace, labels)
        selector = {"app": "debug-web"}
    else:
        name = "sprint-web"
        labels = {"app": "sprint-web"}
        deploy = deployment(name, namespace, labels)
        selector = {"app": "sprint-web"}

    snapshot = {
        "namespace": {"apiVersion": "v1", "kind": "Namespace", "metadata": {"name": namespace}},
        "deployment": deploy,
        "service": {
            "metadata": metadata(name, namespace),
            "spec": {"selector": selector, "ports": [{"port": 80, "targetPort": "http"}]},
        },
        "endpoint_slices": {
            "items": [
                {
                    "metadata": metadata(
                        f"{name}-abc",
                        namespace,
                        labels={"kubernetes.io/service-name": name},
                    ),
                    "endpoints": [{"conditions": {"ready": True}, "addresses": ["10.0.0.8"]}],
                }
            ]
        },
        "http_ok": True,
    }
    if mode == "sprint":
        snapshot["pod"] = {
            "metadata": metadata("sprint-probe", namespace, labels={"task": "sprint-probe"}),
            "spec": {"containers": [{"name": "probe", "image": IMAGE, "args": ["pause"]}]},
            "status": {"conditions": [{"type": "Ready", "status": "True"}]},
        }
    return snapshot


def passes(mode: str, snapshot: dict) -> bool:
    return all(result[0] for result in evaluate(mode, snapshot).values())


class WeekOneGraderTests(unittest.TestCase):
    def test_golden_contract_for_every_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                self.assertTrue(passes(mode, valid_snapshot(mode)))

    def test_materially_different_valid_forms_for_every_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                snapshot = valid_snapshot(mode)
                container = snapshot["deployment"]["spec"]["template"]["spec"]["containers"][0]
                container["command"] = ["/agnhost"]
                container["args"] = ["netexec", "--http-port=8080", "--udp-port=0"]
                snapshot["service"]["spec"]["ports"][0]["targetPort"] = 8080
                snapshot["endpoint_slices"]["items"].append({"metadata": {"namespace": "noise"}})
                if mode == "sprint":
                    snapshot["pod"]["spec"]["containers"][0]["command"] = ["agnhost"]
                    snapshot["pod"]["spec"]["containers"][0]["args"] = ["pause"]
                self.assertTrue(passes(mode, snapshot))

    def test_guided_lab_accepts_a_kubectl_generated_selector(self) -> None:
        snapshot = valid_snapshot("objects")
        template_labels = snapshot["deployment"]["spec"]["template"]["metadata"]["labels"]
        template_labels["app"] = "object-web"
        snapshot["deployment"]["spec"]["selector"]["matchLabels"] = {"app": "object-web"}
        self.assertTrue(passes("objects", snapshot))

    def test_guided_lab_rejects_a_selector_not_satisfied_by_the_template(self) -> None:
        snapshot = valid_snapshot("objects")
        snapshot["deployment"]["spec"]["selector"]["matchLabels"] = {"app": "wrong"}
        self.assertFalse(passes("objects", snapshot))

    def test_near_miss_fails_each_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                snapshot = valid_snapshot(mode)
                snapshot["deployment"]["status"]["readyReplicas"] = 1
                self.assertFalse(passes(mode, snapshot))

    def test_documented_alternative_pod_container_name_passes_sprint(self) -> None:
        snapshot = valid_snapshot("sprint")
        snapshot["pod"]["spec"]["containers"][0]["name"] = "sprint-probe"
        self.assertTrue(passes("sprint", snapshot))

    def test_required_named_http_port_cannot_be_omitted(self) -> None:
        for mode in ("objects", "sprint"):
            with self.subTest(mode=mode):
                snapshot = valid_snapshot(mode)
                snapshot["deployment"]["spec"]["template"]["spec"]["containers"][0]["ports"] = []
                self.assertFalse(passes(mode, snapshot))

    def test_partial_state_fails_each_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                source = valid_snapshot(mode)
                self.assertFalse(passes(mode, {"namespace": source["namespace"]}))

    def test_wrong_namespace_fails_each_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                snapshot = valid_snapshot(mode)
                snapshot["namespace"]["metadata"]["name"] = "wrong-namespace"
                snapshot["deployment"]["metadata"]["namespace"] = "wrong-namespace"
                snapshot["service"]["metadata"]["namespace"] = "wrong-namespace"
                snapshot["endpoint_slices"]["items"][0]["metadata"]["namespace"] = "wrong-namespace"
                if mode == "sprint":
                    snapshot["pod"]["metadata"]["namespace"] = "wrong-namespace"
                self.assertFalse(passes(mode, snapshot))

    def test_post_reset_empty_state_fails_each_mode(self) -> None:
        for mode in MODES:
            with self.subTest(mode=mode):
                self.assertFalse(passes(mode, {}))

    def test_mode_specific_contracts_cannot_substitute_for_each_other(self) -> None:
        for mode in MODES:
            other = next(candidate for candidate in MODES if candidate != mode)
            with self.subTest(mode=mode, fixture=other):
                self.assertFalse(passes(mode, valid_snapshot(other)))


if __name__ == "__main__":
    unittest.main()
