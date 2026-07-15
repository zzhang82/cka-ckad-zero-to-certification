#!/usr/bin/env python3
"""Check repository-local Markdown links without depending on the network."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[2]
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
SKIP_PREFIXES = ("http://", "https://", "mailto:", "#")


def main() -> int:
    errors: list[str] = []
    checked = 0

    for document in sorted(ROOT.rglob("*.md")):
        if any(part in {".git", ".venv", "learner-state", "dist"} for part in document.parts):
            continue
        text = document.read_text(encoding="utf-8")
        for line_number, line in enumerate(text.splitlines(), start=1):
            for match in LINK.finditer(line):
                destination = match.group(1).strip().split(maxsplit=1)[0].strip("<>")
                if not destination or destination.startswith(SKIP_PREFIXES):
                    continue
                path_text = unquote(destination.split("#", 1)[0])
                if not path_text:
                    continue
                target = (document.parent / path_text).resolve()
                checked += 1
                if not target.exists():
                    relative_document = document.relative_to(ROOT)
                    errors.append(f"{relative_document}:{line_number}: missing {destination}")

    if errors:
        print("Local Markdown link check failed:")
        for error in errors:
            print(f"  {error}")
        return 1

    print(f"Validated {checked} repository-local Markdown link(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
