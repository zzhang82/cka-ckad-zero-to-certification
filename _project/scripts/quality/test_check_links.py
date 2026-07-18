#!/usr/bin/env python3
"""Regression tests for Git-aware Markdown link discovery."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import subprocess
import tempfile
import unittest
from pathlib import Path


CHECKER_PATH = Path(__file__).with_name("check_links.py")
SPEC = importlib.util.spec_from_file_location("check_links", CHECKER_PATH)
assert SPEC and SPEC.loader
CHECK_LINKS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECK_LINKS)


class GitAwareMarkdownDiscoveryTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self._temporary_directory.name)
        subprocess.run(["git", "init", "-q"], cwd=self.root, check=True)
        CHECK_LINKS.ROOT = self.root

    def tearDown(self) -> None:
        self._temporary_directory.cleanup()

    def run_checker(self) -> tuple[int, str]:
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            result = CHECK_LINKS.main()
        return result, output.getvalue()

    def test_scans_tracked_markdown(self) -> None:
        document = self.root / "tracked.md"
        document.write_text("[missing](tracked-target.md)\n", encoding="utf-8")
        subprocess.run(["git", "add", "tracked.md"], cwd=self.root, check=True)

        result, output = self.run_checker()

        self.assertEqual(result, 1)
        self.assertIn("tracked.md:1: missing tracked-target.md", output)

    def test_scans_nonignored_untracked_markdown(self) -> None:
        document = self.root / "untracked.md"
        document.write_text("[missing](untracked-target.md)\n", encoding="utf-8")

        result, output = self.run_checker()

        self.assertEqual(result, 1)
        self.assertIn("untracked.md:1: missing untracked-target.md", output)

    def test_skips_ignored_markdown_and_state(self) -> None:
        (self.root / ".gitignore").write_text("/private-learner/\n", encoding="utf-8")
        private = self.root / "private-learner"
        private.mkdir()
        (private / "notes.md").write_text("[secret](missing.md)\n", encoding="utf-8")

        state = self.root / ".state"
        state.mkdir()
        state_document = state / "runtime.md"
        state_document.write_text("[runtime](missing.md)\n", encoding="utf-8")
        subprocess.run(["git", "add", "-f", ".state/runtime.md"], cwd=self.root, check=True)

        result, output = self.run_checker()

        self.assertEqual(result, 0)
        self.assertNotIn("secret", output)
        self.assertNotIn("runtime", output)


if __name__ == "__main__":
    unittest.main()
