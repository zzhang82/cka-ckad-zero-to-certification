#!/usr/bin/env python3
"""Validate project metadata with no third-party dependencies."""

from __future__ import annotations

import json
import re
import sys
from datetime import date
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[2]
VALID_WEEKS = {f"week-{number:02d}" for number in range(13)}
VALID_AUTHORITY = {"official", "purchased", "community"}
VALID_ADOPTION = {"primary", "map-only", "supplemental", "link-only", "reject"}
VALID_TRACK = {"shared", "cka", "ckad", "remediation"}
VALID_STATUS = {"planned", "active", "passed", "conditional", "repeat"}


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"{path.relative_to(ROOT)}: {exc}") from exc


def nonempty_list(value: object) -> bool:
    return isinstance(value, list) and bool(value) and all(isinstance(item, str) and item.strip() for item in value)


def main() -> int:
    errors: list[str] = []
    catalog_path = ROOT / "sources" / "catalog.json"

    try:
        catalog = load_json(catalog_path)
    except ValueError as exc:
        print(f"ERROR {exc}")
        return 1

    resources = catalog.get("resources")
    if not isinstance(resources, list) or not resources:
        errors.append("sources/catalog.json: resources must be a non-empty array")
        resources = []

    resource_ids: set[str] = set()
    required_resource_fields = {
        "id", "title", "url", "owner", "authority", "access", "license",
        "adoption", "weeks", "last_verified", "notes",
    }

    for index, resource in enumerate(resources):
        label = f"sources/catalog.json resources[{index}]"
        if not isinstance(resource, dict):
            errors.append(f"{label}: must be an object")
            continue
        missing = required_resource_fields - resource.keys()
        if missing:
            errors.append(f"{label}: missing {sorted(missing)}")
            continue
        resource_id = resource["id"]
        if not isinstance(resource_id, str) or not re.fullmatch(r"[a-z0-9][a-z0-9-]+", resource_id):
            errors.append(f"{label}: invalid id {resource_id!r}")
        elif resource_id in resource_ids:
            errors.append(f"{label}: duplicate id {resource_id}")
        else:
            resource_ids.add(resource_id)
        parsed = urlparse(resource["url"])
        if parsed.scheme != "https" or not parsed.netloc:
            errors.append(f"{label}: URL must be an absolute HTTPS URL")
        if resource["authority"] not in VALID_AUTHORITY:
            errors.append(f"{label}: invalid authority {resource['authority']!r}")
        if resource["adoption"] not in VALID_ADOPTION:
            errors.append(f"{label}: invalid adoption {resource['adoption']!r}")
        weeks = resource["weeks"]
        if not nonempty_list(weeks) or not set(weeks).issubset(VALID_WEEKS):
            errors.append(f"{label}: invalid weeks {weeks!r}")
        try:
            date.fromisoformat(resource["last_verified"])
        except (TypeError, ValueError):
            errors.append(f"{label}: last_verified must be YYYY-MM-DD")

    week_files = sorted((ROOT / "weeks").glob("week-*/week.json"))
    if not week_files:
        errors.append("weeks/: no week.json files found")

    for week_path in week_files:
        rel = week_path.relative_to(ROOT)
        try:
            week = load_json(week_path)
        except ValueError as exc:
            errors.append(str(exc))
            continue
        required = {"id", "title", "track", "status", "planned_hours", "target", "resource_ids", "deliverables", "acceptance"}
        missing = required - week.keys()
        if missing:
            errors.append(f"{rel}: missing {sorted(missing)}")
            continue
        if week["id"] != week_path.parent.name or week["id"] not in VALID_WEEKS:
            errors.append(f"{rel}: id must match directory and be week-00 through week-12")
        if week["track"] not in VALID_TRACK:
            errors.append(f"{rel}: invalid track {week['track']!r}")
        if week["status"] not in VALID_STATUS:
            errors.append(f"{rel}: invalid status {week['status']!r}")
        if not isinstance(week["planned_hours"], (int, float)) or not 1 <= week["planned_hours"] <= 40:
            errors.append(f"{rel}: planned_hours must be between 1 and 40")
        for field in ("resource_ids", "deliverables", "acceptance"):
            if not nonempty_list(week[field]):
                errors.append(f"{rel}: {field} must be a non-empty string array")
        unknown = sorted(set(week["resource_ids"]) - resource_ids)
        if unknown:
            errors.append(f"{rel}: unknown resource IDs {unknown}")
        for required_file in ("README.md", "START_HERE.md"):
            if not (week_path.parent / required_file).is_file():
                errors.append(f"{rel.parent}: missing {required_file}")

    if errors:
        for error in errors:
            print(f"ERROR {error}")
        print(f"Validation failed with {len(errors)} error(s).")
        return 1

    print(f"Validated {len(resources)} resources and {len(week_files)} week contract(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
