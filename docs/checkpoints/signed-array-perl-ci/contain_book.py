"""Preserve canonical3, then contain only layout proven byte-identical after rendering."""
import base64
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context

PAGE = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
REGISTRY = "doctrine/readme_stability/routes.jsonl"


def save(name, value):
    raw = gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0)
    assert len(raw) <= 32 * 1024 * 1024, name
    with (HERE / name).open("xb") as output:
        output.write(raw)


def render(packets):
    with tempfile.TemporaryDirectory(prefix="signed-book-contain-", dir=os.environ["TMPDIR"]) as folder:
        root = Path(folder)
        assert root.stat().st_dev == ROOT.stat().st_dev
        for path, item in packets.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            raw = c.decode(item["base64"])
            assert c.sha(raw) == item["sha256"]
            target.write_bytes(raw)
            target.chmod(item["mode"])
        command = ["mdbook", "build", "docs/linkedspec-book", "-d", "output"]
        env = {key: value for key, value in os.environ.items() if not key.startswith("MDBOOK_")}
        run = subprocess.run(command, cwd=root, env=env, capture_output=True)
        assert run.returncode == 0, run.stderr.decode()
        files = {}
        for path in sorted((root / "output").rglob("*")):
            if path.is_file():
                assert not path.is_symlink()
                raw = path.read_bytes()
                files[path.relative_to(root / "output").as_posix()] = dict(
                    base64=c.encode(raw), sha256=c.sha(raw), bytes=len(raw), mode=path.stat().st_mode & 0o7777)
        return dict(command=command, returncode=run.returncode, stdout_base64=c.encode(run.stdout),
            stderr_base64=c.encode(run.stderr), files=files)


def manifest(run):
    return {path: {key: item[key] for key in ("sha256", "bytes", "mode")}
        for path, item in run["files"].items()}


def main():
    staged = subprocess.run(["git", "diff", "--cached", "--full-index", "--binary"], cwd=ROOT, capture_output=True)
    assert staged.returncode == 0 and c.sha(staged.stdout) == "d2056c827e241b58cfecba06a2f39db7b2b0f9bae8b8aaabf5861a57ef870cb4"
    del staged
    names = subprocess.check_output(["git", "diff", "--cached", "--name-only"], cwd=ROOT).decode().splitlines()
    assert len(names) == 161
    index = subprocess.check_output(["git", "ls-files", "--stage", "-z"], cwd=ROOT)
    candidate = {}
    for row in index.split(b"\0"):
        if row:
            meta, name = row.split(b"\t", 1)
            path = name.decode()
            if path in names:
                mode, oid, stage = meta.decode().split()
                assert stage == "0"
                raw = subprocess.check_output(["git", "show", ":" + path], cwd=ROOT)
                item = dict(mode=mode, git_oid=oid, sha256=c.sha(raw))
                if path.endswith((".gz", ".part")):
                    assert c.identity(path)["sha256"] == item["sha256"]
                else:
                    item["base64"] = c.encode(raw)
                candidate[path] = item
    original_inputs = json.loads(gzip.decompress((HERE / "book-inputs.json.gz").read_bytes()))["inputs"]
    packets = {path: c.read(path) for path in original_inputs}
    assert packets == original_inputs
    surfaces = {row["id"]: row for line in c.source(REGISTRY).read_text().splitlines()
        if (row := json.loads(line)).get("type") == "surface"}
    public_paths = {path for pattern in surfaces["public_reference"]["members"] for path in ROOT.glob(pattern) if path.is_file()}
    public_before = sum(len(path.read_bytes().splitlines()) for path in public_paths)
    raw = c.source(PAGE).read_bytes()
    lines = raw.splitlines(keepends=True)
    page_before = len(lines)
    page_limit = surfaces["diagnostics"]["limits"]["max_lines_per_file"]
    public_limit = surfaces["public_reference"]["limits"]["max_total_lines"]
    remove_count = max(page_before - page_limit, public_before - public_limit) + 3
    assert (page_before, public_before, remove_count) == (2057, 50006, 12)
    removable, fence = [], None
    for position, line in enumerate(lines):
        match = re.match(rb"^ {0,3}(`{3,}|~{3,})", line)
        if fence:
            if match and match[1][:1] == fence[:1] and len(match[1]) >= len(fence) and not line[match.end():].strip():
                fence = None
            continue
        if match:
            fence = match[1]
            continue
        if position and re.match(rb"^#{1,6} ", line) and lines[position - 1] == b"\n":
            removable.append(position - 1)
    chosen = set(removable[:remove_count])
    assert len(chosen) == remove_count
    changed_raw = b"".join(line for position, line in enumerate(lines) if position not in chosen)
    assert [line for line in raw.splitlines() if line] == [line for line in changed_raw.splitlines() if line]
    changed = copy.deepcopy(packets)
    changed[PAGE].update(base64=c.encode(changed_raw), sha256=c.sha(changed_raw))
    epoch = context.snapshot()
    save("contain-before.json.gz", dict(context=epoch, producer=c.read(Path(__file__).relative_to(ROOT).as_posix()),
        candidate=dict(base=c.BASE, fingerprint="d2056c827e241b58cfecba06a2f39db7b2b0f9bae8b8aaabf5861a57ef870cb4",
            files=candidate, index_base64=c.encode(index)),
        actual_ci_log=c.read(".linkedspec-data/verification/signed-perl-canonical3.log"), actual_ci_exit=143,
        registry=c.read(REGISTRY), inputs=packets, changed_page=changed[PAGE], removed_zero_based_lines=sorted(chosen),
        counts=dict(page_before=page_before, page_limit=page_limit, public_before=public_before, public_limit=public_limit),
        scope="Before any source edit, preserve exact failed161-file candidate and actual pressure reports. Controlled candidate removes only twelve empty heading separators outside fences. Every output file must retain byte/mode identity; no route/cap/content/example change."))
    before = render(packets)
    save("contain-original-output.json.gz", before)
    after = render(changed)
    assert manifest(before) == manifest(after), "full rendered output identity"
    for path in before["files"]:
        assert before["files"][path]["base64"] == after["files"][path]["base64"], path
    fault_packets = copy.deepcopy(changed)
    marker = b"Perl signed-array selector regression"
    assert changed_raw.count(marker) == 1
    faulty_raw = changed_raw.replace(marker, b"Changed containment control heading", 1)
    fault_packets[PAGE].update(base64=c.encode(faulty_raw), sha256=c.sha(faulty_raw))
    save("contain-fault-input.json.gz", fault_packets[PAGE])
    fault = render(fault_packets)
    assert manifest(fault) != manifest(after)
    ci_html = "development/local-ci-and-regression.html"
    assert fault["files"][ci_html]["base64"] != after["files"][ci_html]["base64"]
    assert c.unchanged(epoch["inputs"])
    save("contain-runs.json.gz", dict(after={key: value for key, value in after.items() if key != "files"},
        after_manifest=manifest(after), fault={key: value for key, value in fault.items() if key != "files"},
        fault_manifest=manifest(fault), fault_ci_html=fault["files"][ci_html], inputs_unchanged=True,
        counts=dict(output_files=len(after["files"]), output_bytes=sum(item["bytes"] for item in after["files"].values()),
            page_after=page_before - remove_count, public_after=public_before - remove_count),
        full_bytes_and_modes_identical=True, heading_control_rejected=True))
    c.source(PAGE).write_bytes(changed_raw)
    assert len(c.source(PAGE).read_bytes().splitlines()) <= page_limit
    print("Blank-only containment PASS:", remove_count, "lines;", len(after["files"]),
        "complete output files byte/mode-identical; heading fault rejects; page", page_before - remove_count,
        "public", public_before - remove_count, flush=True)


if __name__ == "__main__":
    main()
