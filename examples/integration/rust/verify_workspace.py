#!/usr/bin/env python3
"""Exercise LinkedSpec's Cargo workspace boundaries in an isolated application.

Run through tools/run_python_project_data.sh from the LinkedSpec root. Only the
current example manifest is overlaid. The prepared RGX checkout is linked as an
opaque dependency; no internal dependency directories or manifests are selected, copied,
queried directly or edited. Prepare RGX through its published integration guide
before running this check. Metadata proves LinkedSpec/application membership;
the separate public-bootstrap and Lispish checks prove preparation/native use.
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
    dependency = (root / "rgx").resolve(strict=True)
    if dependency.stat().st_dev != root.stat().st_dev:
        raise RuntimeError("RGX must share the repository volume")
    if not (dependency / "docs/INTEGRATION.md").is_file():
        raise RuntimeError("initialize RGX and follow its published integration guide first")
    checks = []

    with tempfile.TemporaryDirectory(prefix="rust-workspace-", dir=scratch) as temporary:
        host = Path(temporary)
        vendor = host / "vendor/linkedspec"

        def archive_linkedspec():
            # Only LinkedSpec-owned source enters the fixture. Cargo handles
            # the opaque dependency through the normal published crate path.
            raw = subprocess.check_output(
                ["git", "-C", str(root), "archive", "HEAD", "rust", "examples/integration/rust"],
                timeout=120,
            )
            vendor.mkdir(parents=True, exist_ok=True)
            with tarfile.open(fileobj=io.BytesIO(raw)) as source:
                source.extractall(vendor, filter="data")

        archive_linkedspec()
        (vendor / "rgx").symlink_to(os.path.relpath(dependency, vendor), target_is_directory=True)
        example = vendor / "examples/integration/rust/Cargo.toml"
        example_source = (root / "examples/integration/rust/Cargo.toml").read_text(encoding="utf-8")
        assert example_source.count("\n[workspace]\n") == 1, "example must own one workspace boundary"
        example.write_text(example_source, encoding="utf-8")
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
                wrapper + ["metadata", "--offline", "--locked", "--no-deps", "--format-version", "1",
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

        library = vendor / "rust/Cargo.toml"
        # Only LinkedSpec and application manifests are passed to Cargo.
        metadata("standalone example", example, example.parent, {"linkedspec-integration-example"})
        metadata("standalone library", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})

        manifest.write_text(host_workspace, encoding="utf-8")
        metadata("example isolates itself in a host", example, example.parent, {"linkedspec-integration-example"})
        metadata("library isolates itself in a host", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})
        example.write_text(example_source.replace("\n[workspace]\n", "\n", 1), encoding="utf-8")
        metadata("missing example boundary rejects enclosing workspace", example)

        manifest.write_text(host_workspace + 'exclude = ["vendor/linkedspec"]\n', encoding="utf-8")
        metadata("host exclusion isolates boundary-less example", example, example.parent,
                 {"linkedspec-integration-example"})
        example.write_text(example_source, encoding="utf-8")
        metadata("host keeps only application members", manifest, host, {"app", "support"})
        metadata("excluded example", example, example.parent, {"linkedspec-integration-example"})
        metadata("excluded library", library, library.parent, {"linkedspec-core", "linkedspec-runtime"})

    print(json.dumps({"status": "PASS", "checks": checks}))


if __name__ == "__main__":
    main()
