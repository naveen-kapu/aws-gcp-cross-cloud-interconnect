#!/usr/bin/env python3
import os
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

class TestRepoStructure(unittest.TestCase):
    def test_directories_exist(self):
        expected_dirs = [
            "docs",
            "terraform",
            "terraform/aws",
            "terraform/gcp",
            "scripts",
            "examples",
            "diagrams",
        ]
        for d in expected_dirs:
            path = os.path.join(ROOT, d)
            with self.subTest(directory=d):
                self.assertTrue(os.path.isdir(path), f"Missing directory: {d}")

    def test_key_files_exist(self):
        expected_files = [
            "README.md",
            "CONTRIBUTING.md",
            "LICENSE",
            "terraform/aws/main.tf",
            "terraform/aws/variables.tf",
            "terraform/aws/outputs.tf",
            "terraform/gcp/main.tf",
            "terraform/gcp/variables.tf",
            "terraform/gcp/outputs.tf",
            "scripts/validate-connectivity.sh",
            "scripts/run-tests.sh",
        ]
        for f in expected_files:
            path = os.path.join(ROOT, f)
            with self.subTest(file=f):
                self.assertTrue(os.path.isfile(path), f"Missing file: {f}")

if __name__ == "__main__":
    unittest.main()
