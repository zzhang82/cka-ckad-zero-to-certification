#!/usr/bin/env python3
"""Adversarial fixtures for every machine-scored Week 0 placement area."""

from __future__ import annotations

import copy
import unittest

from grader import AREA_IDS, IMAGE_DIGEST, evaluate


def metadata(name: str, namespace: str = "week0-diagnostic", **extra: object) -> dict:
    value = {"name": name, "namespace": namespace}
    value.update(extra)
    return value


def ready_status(**extra: object) -> dict:
    value = {"conditions": [{"type": "Ready", "status": "True"}]}
    value.update(extra)
    return value


def valid_snapshot() -> dict:
    image = f"registry.example/agnhost@{IMAGE_DIGEST}"
    deployment = {
        "metadata": metadata("web", generation=7),
        "spec": {
            "replicas": 3,
            "template": {
                "spec": {
                    "containers": [
                        {
                            "name": "web",
                            "image": image,
                            "env": [
                                {
                                    "name": "MODE",
                                    "valueFrom": {
                                        "configMapKeyRef": {"name": "app-config", "key": "MODE"}
                                    },
                                },
                                {
                                    "name": "API_TOKEN",
                                    "valueFrom": {
                                        "secretKeyRef": {"name": "api-credentials", "key": "token"}
                                    },
                                },
                            ],
                        }
                    ]
                }
            },
        },
        "status": {
            "observedGeneration": 7,
            "updatedReplicas": 3,
            "readyReplicas": 3,
            "availableReplicas": 3,
        },
    }
    return {
        "kinds_ok": True,
        "http_ok": True,
        "yaml_pod": {
            "metadata": metadata("yaml-proof", labels={"diagnostic": "yaml"}),
            "spec": {"containers": [{"name": "proof", "image": image, "args": ["pause"]}]},
            "status": ready_status(),
        },
        "deployment": deployment,
        "service": {
            "metadata": metadata("web"),
            "spec": {"selector": {"app": "diagnostic-web"}},
        },
        "endpoint_slices": {
            "items": [
                {
                    "metadata": metadata(
                        "web-abc",
                        labels={"kubernetes.io/service-name": "web"},
                    ),
                    "endpoints": [{"conditions": {"ready": True}, "addresses": ["10.0.0.2"]}],
                }
            ]
        },
        "configmap": {"metadata": metadata("app-config"), "data": {"MODE": "diagnostic"}},
        "secret": {
            "metadata": metadata("api-credentials"),
            "data": {"token": "cmVhZHk="},
        },
        "scheduled_pod": {
            "metadata": metadata("scheduled"),
            "spec": {
                "nodeSelector": {"diagnostic-ready": "true"},
                "nodeName": "node-a",
                "containers": [{"name": "scheduled", "image": image}],
            },
            "status": ready_status(),
        },
        "nodes": {
            "items": [
                {
                    "metadata": {
                        "name": "node-a",
                        "labels": {"diagnostic-ready": "true"},
                    }
                }
            ]
        },
        "pvc": {
            "metadata": metadata("work-data"),
            "spec": {"resources": {"requests": {"storage": "64Mi"}}},
            "status": {"phase": "Bound"},
        },
        "storage_pod": {
            "metadata": metadata("storage-check"),
            "spec": {
                "volumes": [
                    {
                        "name": "data",
                        "persistentVolumeClaim": {"claimName": "work-data"},
                    }
                ],
                "containers": [
                    {
                        "name": "storage",
                        "image": image,
                        "volumeMounts": [{"name": "data", "mountPath": "/data"}],
                    }
                ],
            },
            "status": ready_status(),
        },
    }


def passed_areas(snapshot: dict) -> set[str]:
    return {area for area, (passed, _) in evaluate(snapshot).items() if passed}


class GraderContractTests(unittest.TestCase):
    def test_documented_golden_solution(self) -> None:
        self.assertEqual(passed_areas(valid_snapshot()), set(AREA_IDS))

    def test_materially_different_valid_solution(self) -> None:
        snapshot = valid_snapshot()
        snapshot["yaml_pod"]["spec"]["containers"][0]["command"] = ["/agnhost"]
        snapshot["yaml_pod"]["spec"]["containers"][0]["args"] = ["pause"]
        snapshot["pvc"]["spec"]["resources"]["requests"]["storage"] = "0.0625Gi"
        snapshot["scheduled_pod"]["spec"]["nodeSelector"]["topology.kubernetes.io/zone"] = "local"
        snapshot["deployment"]["spec"]["template"]["spec"]["containers"][0]["env"].append(
            {"name": "EXTRA", "value": "allowed"}
        )
        self.assertEqual(passed_areas(snapshot), set(AREA_IDS))

    def test_incorrect_near_misses_all_fail(self) -> None:
        snapshot = valid_snapshot()
        snapshot["kinds_ok"] = False
        snapshot["yaml_pod"]["spec"]["containers"][0]["args"] = ["netexec"]
        snapshot["deployment"]["spec"]["replicas"] = 4
        snapshot["endpoint_slices"]["items"][0]["endpoints"][0]["conditions"]["ready"] = False
        snapshot["scheduled_pod"]["spec"]["nodeSelector"] = {}
        snapshot["pvc"]["spec"]["resources"]["requests"]["storage"] = "1Mi"
        self.assertEqual(passed_areas(snapshot), set())

    def test_secret_contract_is_isolated_and_exact(self) -> None:
        cases = {
            "wrong-value": lambda snapshot: snapshot["secret"]["data"].update(token="d3Jvbmc="),
            "wrong-env-name": lambda snapshot: snapshot["deployment"]["spec"]["template"]["spec"][
                "containers"
            ][0]["env"][1].update(name="TOKEN"),
            "wrong-ref-key": lambda snapshot: snapshot["deployment"]["spec"]["template"]["spec"][
                "containers"
            ][0]["env"][1]["valueFrom"]["secretKeyRef"].update(key="wrong"),
        }
        expected = set(AREA_IDS) - {"area-07"}
        for name, mutate in cases.items():
            with self.subTest(name=name):
                snapshot = valid_snapshot()
                mutate(snapshot)
                self.assertEqual(passed_areas(snapshot), expected)

    def test_partial_state_scores_only_completed_area(self) -> None:
        snapshot = {"yaml_pod": copy.deepcopy(valid_snapshot()["yaml_pod"])}
        self.assertEqual(passed_areas(snapshot), {"area-02"})

    def test_wrong_namespace_state_fails(self) -> None:
        snapshot = valid_snapshot()
        snapshot["kinds_ok"] = False
        snapshot["http_ok"] = False
        for key in (
            "yaml_pod",
            "deployment",
            "service",
            "configmap",
            "secret",
            "scheduled_pod",
            "pvc",
            "storage_pod",
        ):
            snapshot[key]["metadata"]["namespace"] = "wrong-namespace"
        snapshot["endpoint_slices"]["items"][0]["metadata"]["namespace"] = "wrong-namespace"
        self.assertEqual(passed_areas(snapshot), set())

    def test_post_reset_empty_state_fails(self) -> None:
        self.assertEqual(passed_areas({}), set())


if __name__ == "__main__":
    unittest.main()
