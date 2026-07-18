#!/usr/bin/env python3
"""Check repository-local Markdown links without depending on the network."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[3]
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
SKIP_PREFIXES = ("http://", "https://", "mailto:", "#")


def markdown_documents() -> list[Path]:
    """Return tracked and nonignored untracked Markdown files."""
    result = subprocess.run(
        [
            "git",
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
            "--",
            "*.md",
        ],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    documents = []
    for encoded_path in result.stdout.split(b"\0"):
        if not encoded_path:
            continue
        relative_path = Path(os.fsdecode(encoded_path))
        if relative_path.parts and relative_path.parts[0] == ".state":
            continue
        document = ROOT / relative_path
        if document.is_file():
            documents.append(document)
    return sorted(documents)


def main() -> int:
    errors: list[str] = []
    checked = 0

    for document in markdown_documents():
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
