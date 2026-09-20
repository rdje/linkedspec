#!/usr/bin/env python3
"""Exercise Cargo workspace discovery against isolated committed native sources.

Run through tools/run_python_project_data.sh from the LinkedSpec root. Only the
current example manifest is overlaid; dependency worktrees are never copied or
edited. This metadata regression needs no generated parser sources or builds.
The separate Lispish verifier checks actual native execution.
"""

import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile


def main():
    root = Path(__file__).resolve().parents[3]
    scratch = Path(os.environ.get("LINKEDSPEC_SCRATCH_ROOT", root / ".linkedspec-data/scratch"))
    scratch.mkdir(parents=True, exist_ok=True)
    if scratch.stat().st_dev != root.stat().st_dev:
        raise RuntimeError("workspace fixtures must share the repository volume")
    checks = []

    with tempfile.TemporaryDirectory(prefix="rust-workspace-", dir=scratch) as temporary:
        host = Path(temporary)
        vendor = host / "vendor/linkedspec"

        def archive(checkout, destination, paths, revision="HEAD"):
            # Git supplies committed blobs, excluding generated outputs,
            # caches and unrelated changes in a developer's dependency worktree.
            raw = subprocess.check_output(
                ["git", "-C", str(checkout), "archive", revision, *paths], timeout=120,
            )
            destination.mkdir(parents=True, exist_ok=True)
            with tarfile.open(fileobj=io.BytesIO(raw)) as source:
                source.extractall(destination, filter="data")

        rgx_pin = subprocess.check_output(
            ["git", "-C", str(root), "rev-parse", "HEAD:rgx"], text=True,
        ).strip()
        pgen_pin = subprocess.check_output(
            ["git", "-C", str(root / "rgx"), "rev-parse", f"{rgx_pin}:subs/pgen"], text=True,
        ).strip()
        archive(root, vendor, ["rust", "examples/integration/rust"])
        archive(root / "rgx", vendor / "rgx", [
            "Cargo.toml", "rgx-core", "rgx-cli", "rgx-bench", "rgx-wasm", "rgx-capi",
        ], rgx_pin)
        archive(root / "rgx/subs/pgen", vendor / "rgx/subs/pgen", ["rust"], pgen_pin)
        example = vendor / "examples/integration/rust/Cargo.toml"
        example.write_bytes((root / "examples/integration/rust/Cargo.toml").read_bytes())
        for name in ("app", "support"):
            package = host / name
            (package / "src").mkdir(parents=True)
            (package / "Cargo.toml").write_text(
                f'[package]\nname = "{name}"\nversion = "0.1.0"\nedition = "2024"\n',
                encoding="utf-8",
            )
            (package / "src/lib.rs").write_text("", encoding="utf-8")
        manifest = host / "Cargo.toml"
        host_workspace = '[workspace]\nresolver = "2"\nmembers = ["app", "support"]\n'
        wrapper = ["bash", str(root / "tools/run_cargo_local.sh")]

        def metadata(label, path, expected_root=None, expected_members=None):
            result = subprocess.run(
                wrapper + ["metadata", "--offline", "--no-deps", "--format-version", "1",
                           "--manifest-path", str(path)],
                cwd=host, capture_output=True, text=True, encoding="utf-8", timeout=120,
                check=False,
            )
            if expected_root is None:
                assert result.returncode == 101, (label, result.returncode, result.stderr)
                assert "current package believes it's in a workspace when it's not" in result.stderr
                assert str(manifest) in result.stderr, (label, result.stderr)
            else:
                assert result.returncode == 0, (label, result.returncode, result.stderr)
                value = json.loads(result.stdout)
                assert Path(value["workspace_root"]) == expected_root, (label, value["workspace_root"])
                members = {p["name"] for p in value["packages"] if p["id"] in value["workspace_members"]}
                assert members == expected_members, (label, members)
            checks.append(label)

        pgen = vendor / "rgx/subs/pgen/rust/Cargo.toml"
        library = vendor / "rust/Cargo.toml"
        # No host manifest: the three packages/workspaces stand alone.
        metadata("standalone example", example, example.parent, {"linkedspec-integration-example"})
        metadata("standalone PGEN", pgen, pgen.parent, {"pgen"})
        metadata("standalone library", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})

        manifest.write_text(host_workspace, encoding="utf-8")
        metadata("example isolates itself in a host", example, example.parent, {"linkedspec-integration-example"})
        metadata("library isolates itself in a host", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})
        metadata("PGEN still requires host exclusion", pgen)

        manifest.write_text(host_workspace + 'exclude = ["vendor/linkedspec"]\n', encoding="utf-8")
        metadata("host keeps only application members", manifest, host, {"app", "support"})
        metadata("excluded example", example, example.parent, {"linkedspec-integration-example"})
        metadata("excluded PGEN", pgen, pgen.parent, {"pgen"})
        metadata("excluded library", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})

    print(json.dumps({"status": "PASS", "checks": checks}))


if __name__ == "__main__":
    main()
