"""Exercise the public rollover/reader commands against read-only project Git sources.

The fixture views contain ordinary files, not new repositories. Git only reads this
repository's existing metadata; no fixture command stages, commits or changes it.
"""

from pathlib import Path
import argparse
import base64
import gzip
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
# A committed pressure-bearing source keeps the regression independent of the
# changing live roots. The fixture shim resolves HEAD to this exact public Git
# identity and permits only the read commands used by the rollover producer.
SOURCE_REVISION = "b2156813fffed53622e640583a46a4ca94186a08"
SURFACES = {
    "change_history": ("CHANGES.md", "changes", rb"^## "),
    "engineering_notes": (
        "DEVELOPMENT_NOTES.md", "development-notes", rb"^(?:- 20\d{2}-\d{2}-\d{2}\b|## )"
    ),
}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {
        "encoding": "gzip-base64", "bytes": len(raw), "sha256": sha(raw),
        "data": base64.b64encode(gzip.compress(raw, mtime=0)).decode(),
    }


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode() + b"\n"


def project_report_path(relative):
    """Validate a project artifact destination without creating or writing it."""
    path = Path(relative)
    if path.is_absolute() or not path.parts or ".." in path.parts:
        raise ValueError("report requires a repository-relative artifact path")
    destination = ROOT / path
    resolved = destination.resolve()
    if (not resolved.is_relative_to(ROOT) or destination.is_symlink() or destination.is_dir()
            or resolved.relative_to(ROOT).parts[0] == ".git"):
        raise ValueError("report destination leaves project artifact storage")
    if (not resolved.parent.is_dir()
            or resolved.parent.stat().st_dev != ROOT.stat().st_dev):
        raise ValueError("report requires an existing parent on the repository volume")
    return destination


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-revision", default=SOURCE_REVISION)
    parser.add_argument("--original", action="store_true")
    parser.add_argument("--report")
    args = parser.parse_args()
    output = project_report_path(args.report) if args.report else None
    revision = subprocess.check_output(
        ["git", "rev-parse", args.source_revision], cwd=ROOT
    ).decode().strip()
    assert re.fullmatch(r"[0-9a-f]{40}", revision), "clean source commit"
    git_dir = Path(subprocess.check_output(
        ["git", "rev-parse", "--absolute-git-dir"], cwd=ROOT
    ).decode().strip())
    assert git_dir.is_relative_to(ROOT), "this project's Git metadata only"
    inputs = {}

    def source(path):
        raw = subprocess.check_output(["git", "show", revision + ":" + path], cwd=ROOT)
        if path in inputs:
            assert inputs[path] == raw
        inputs[path] = raw
        return raw

    producer_revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip()
    original_tool = subprocess.check_output(
        ["git", "show", producer_revision + ":tools/roll_document_history.pl"], cwd=ROOT
    )
    tool = original_tool if args.original else (ROOT / "tools/roll_document_history.pl").read_bytes()
    reader = (source("tools/read_document_history.pl") if args.original
              else (ROOT / "tools/read_document_history.pl").read_bytes())
    catalog_helper = (None if args.original else
                      (ROOT / "tools/lib/LinkedSpec/DocumentHistoryCatalog.pm").read_bytes())
    scratch = ROOT / ".linkedspec-data/scratch/history-rollover-eof"
    scratch.mkdir(parents=True, exist_ok=True)
    run_tree = Path(tempfile.mkdtemp(prefix="original-" if args.original else "repaired-", dir=scratch))
    assert run_tree.stat().st_dev == ROOT.stat().st_dev, "same-volume fixture views"
    commands, results, observations = [], [], []
    git_binary = shutil.which("git")
    assert git_binary, "published Git executable"
    shim = run_tree / "bin/git"
    shim.parent.mkdir()
    shim.write_text("""#!/usr/bin/env python3
import os
import sys
args = sys.argv[1:]
if len(args) >= 2 and args[0] == '-C':
    args = args[2:]
if not args or args[0] not in ('show', 'rev-parse'):
    raise SystemExit('fixture Git permits only source reads')
revision = os.environ['LINKEDSPEC_HISTORY_FIXTURE_SOURCE']
args = [revision if arg == 'HEAD' else revision + arg[4:] if arg.startswith('HEAD:') else arg
        for arg in args]
os.execv(os.environ['LINKEDSPEC_HISTORY_FIXTURE_GIT'], ['git', *args])
""")
    shim.chmod(0o755)

    def write(tree, path, raw):
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)

    def run(tree, command):
        # The two Perl tools only issue read-only Git show/rev-parse commands.
        env = os.environ.copy()
        env.update(GIT_DIR=str(git_dir), GIT_WORK_TREE=str(tree),
                   PATH=str(shim.parent) + os.pathsep + env['PATH'],
                   LINKEDSPEC_HISTORY_FIXTURE_SOURCE=revision,
                   LINKEDSPEC_HISTORY_FIXTURE_GIT=git_binary)
        def file_guard():
            rows = []
            for path in sorted(tree.rglob("*")):
                relative = path.relative_to(tree).as_posix()
                if path.is_symlink():
                    target = path.resolve().relative_to(ROOT).as_posix()
                    rows.append({"path": relative, "kind": "symbolic", "target": target})
                elif path.is_file():
                    raw = path.read_bytes()
                    rows.append({"path": relative, "kind": "regular", "bytes": len(raw), "sha256": sha(raw)})
            return rows

        before = file_guard()
        result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
        commands.append({
            "cwd": tree.relative_to(ROOT).as_posix(), "command": command,
            "exit": result.returncode, "stdout": envelope(result.stdout),
            "stderr": envelope(result.stderr),
            "inputs_before": before, "inputs_after": file_guard(),
        })
        return result

    def check(name, callback):
        try:
            callback()
        except AssertionError as error:
            results.append({"name": name, "ok": False, "reason": str(error)})
        else:
            results.append({"name": name, "ok": True})

    def require(condition, reason):
        assert condition, reason

    for surface, (current, family, boundary) in SURFACES.items():
        manifest_path = f"docs/history/{family}/manifest.jsonl"
        head = source(current)
        old_manifest = source(manifest_path)
        old_lines = old_manifest.splitlines(keepends=True)
        old_rows = [json.loads(line) for line in old_lines]
        archives = {row["target_path"]: source(row["target_path"]) for row in old_rows[1:]}
        archive_before = b"".join(archives[row["target_path"]] for row in old_rows[1:])
        starts = [match.start() for match in re.finditer(boundary, head, re.M)]
        assert len(starts) > 1, "independent committed fixture records"
        preamble, records = head[:starts[0]], [
            head[start: starts[i + 1] if i + 1 < len(starts) else len(head)]
            for i, start in enumerate(starts)
        ]
        # The new complete record remains comfortably below the 50% byte target.
        # Existing committed records provide the exact suffix that must be archived.
        title = (b"## 2026-10-06 rollover fixture\n" if surface == "change_history"
                 else b"- 2026-10-06 rollover fixture\n")
        fresh = title + b"x" * 25_000 + b"\n\n"
        candidate = preamble + fresh + b"".join(records)
        assert 58_983 <= len(candidate) and len(preamble + fresh) <= 32_768

        def view(name, root=candidate, manifest=old_manifest, catalogs=None):
            tree = run_tree / (surface + "-" + name)
            write(tree, current, root)
            write(tree, manifest_path, manifest)
            write(tree, "tools/roll_document_history.pl", tool)
            write(tree, "tools/read_document_history.pl", reader)
            if catalog_helper is not None:
                write(tree, "tools/lib/LinkedSpec/DocumentHistoryCatalog.pm", catalog_helper)
            for path, raw in (catalogs or {}).items():
                write(tree, path, raw)
            for path, raw in archives.items():
                write(tree, path, raw)
            return tree

        def snapshot(tree):
            return {p.relative_to(tree).as_posix():
                    ("symbolic", os.readlink(p)) if p.is_symlink() else ("regular", p.read_bytes())
                    for p in tree.rglob("*") if p.is_file() or p.is_symlink()}

        apply = ["perl", "tools/roll_document_history.pl", "--surface", surface, "--apply"]
        tree = view("fresh")
        applied = run(tree, apply)
        assert applied.returncode == 0 and applied.stderr == b"", "successful actual initial rollover"
        final_root = (tree / current).read_bytes()
        manifest = (tree / manifest_path).read_bytes()
        catalogs = {p.relative_to(tree).as_posix(): p.read_bytes()
                    for p in (tree / f"docs/history/{family}/catalog").glob("*.jsonl")}
        if args.original:
            lines = manifest.splitlines(keepends=True)
        else:
            expanded = run(tree, ["perl", "tools/read_document_history.pl", "--surface", surface,
                                  "--catalog-json"])
            assert expanded.returncode == 0, expanded.stderr
            lines = [canonical(value) for value in json.loads(expanded.stdout)]
        row = json.loads(lines[1])
        target = row["target_path"]
        part = (tree / target).read_bytes()
        prefix = head[:len(head) - len(part)]
        complete_retained = preamble + fresh + prefix[len(preamble):]
        removed = complete_retained[len(final_root):]
        check(surface + ": exact source/suffix/manifest", lambda: (
            require(lines[2:] == old_lines[1:], "older immutable manifest rows"),
            require(json.loads(lines[0]) == dict(old_rows[0], segment_count=len(old_rows)),
                    "only metadata segment count advances"),
            require(head.endswith(part) and re.match(boundary, part), "complete clean source suffix"),
            require(row["source_commit"] == revision and row["source_blob"] ==
                    subprocess.check_output(["git", "rev-parse", revision + ":" + current], cwd=ROOT).decode().strip(),
                    "exact Git source identity"),
            require(row["sha256"] == sha(part) and row["byte_count"] == len(part) and
                    row["line_count"] == len(part.splitlines()), "suffix counts and digest"),
            require(part == b"".join(head.splitlines(keepends=True)[
                row["source_start_line"] - 1:row["source_end_line"]]), "exact source line slice"),
            require(row["source_end_line"] == len(head.splitlines()), "source suffix endpoint"),
            require(complete_retained == final_root + removed and
                    removed.strip(b"\n") == b"", "only terminal LF separators removed"),
            require(preamble + final_root[len(preamble) + len(fresh):] + removed + part == head,
                    "complete old-root reconstruction including original separator"),
            require(len(final_root.splitlines()) <= 256 and len(final_root) <= 32_768,
                    "unchanged 50% target"),
            require(all((tree / path).read_bytes() == raw for path, raw in archives.items()),
                    "older immutable archive bytes"),
        ))
        whitespace = run(tree, [git_binary, "diff", "--no-index", "--check", "/dev/null", current])
        check(surface + ": ordinary EOF whitespace", lambda: require(
            whitespace.returncode == 1 and not whitespace.stdout and not whitespace.stderr,
            "generated hot root must pass ordinary Git whitespace checks"))
        queried = run(tree, ["perl", "tools/read_document_history.pl", "--surface", surface, "--all"])
        check(surface + ": archive-only query", lambda: require(
            queried.returncode == 0 and queried.stderr == b"" and queried.stdout == part + archive_before,
            "reader retains exact manifest order and archived bytes"))
        pressure = run(tree, ["perl", "tools/roll_document_history.pl", "--surface", surface, "--check"])
        check(surface + ": resulting pressure", lambda: require(
            pressure.returncode == 0 and pressure.stderr == b"", "resulting root passes unchanged pressure"))
        saved = snapshot(tree)
        noop = run(tree, apply)
        check(surface + ": below-pressure no-op", lambda: require(
            noop.returncode == 0 and noop.stderr == b"" and snapshot(tree) == saved,
            "below-pressure apply changes no file"))

        for state in ("orphan", "pending"):
            recovered_tree = view(state, manifest=manifest if state == "pending" else old_manifest,
                                  catalogs=catalogs if state == "pending" else None)
            write(recovered_tree, target, part)
            recovered = run(recovered_tree, apply)
            check(surface + ": " + state + " recovery", lambda: require(
                recovered.returncode == 0 and recovered.stderr == b"" and
                (recovered_tree / current).read_bytes() == final_root and
                (recovered_tree / manifest_path).read_bytes() == manifest and
                (recovered_tree / target).read_bytes() == part,
                "exact interrupted-publication recovery"))
            for corruption in ("missing", "corrupt", "symbolic"):
                if state == "orphan" and corruption == "missing":
                    continue  # An absent orphan is the normal fresh-publication case.
                bad_tree = view(state + "-" + corruption,
                                manifest=manifest if state == "pending" else old_manifest,
                                catalogs=catalogs if state == "pending" else None)
                if corruption == "corrupt":
                    write(bad_tree, target, part + b"changed\n")
                elif corruption == "symbolic":
                    write(bad_tree, "fixture-target.md", part)
                    (bad_tree / target).symlink_to(bad_tree / "fixture-target.md")
                before = snapshot(bad_tree)
                bad = run(bad_tree, apply)
                check(surface + ": " + state + " " + corruption + " rejection", lambda: require(
                    bad.returncode != 0 and snapshot(bad_tree) == before and
                    b"target" in bad.stderr,
                    "conflicting target rejected before any publication"))

        # Same clean-HEAD pending generation, but contradictory source-blob metadata.
        bad_row = dict(row, source_blob="0" * 40)
        bad_manifest = lines[0] + canonical(bad_row) + b"".join(lines[2:])
        bad_tree = view("pending-metadata", manifest=bad_manifest)
        write(bad_tree, target, part)
        before = snapshot(bad_tree)
        bad = run(bad_tree, apply)
        check(surface + ": pending metadata rejection", lambda: require(
            bad.returncode != 0 and snapshot(bad_tree) == before and b"pending" in bad.stderr,
            "contradictory pending generation rejected without duplicate archives"))

        rejection_cases = [
            ("rewrite", preamble + fresh + b"".join(records).replace(b"## ", b"## changed ", 1),
             b"record order/content changed"),
            ("reorder", preamble + fresh + records[1] + records[0] + b"".join(records[2:]),
             b"record order/content changed"),
            ("preamble", preamble + b"changed preamble\n" + fresh + b"".join(records),
             b"preamble"),
            ("uncommitted-byte-pressure", preamble + title + b"x" * 33_000 + b"\n\n" + b"".join(records),
             b"without archiving uncommitted records"),
            ("uncommitted-line-pressure", preamble + title + b"x\n" * 500 + b"\n" + b"".join(records),
             b"without archiving uncommitted records"),
        ]
        for name, root, reason in rejection_cases:
            bad_tree = view(name, root=root)
            before = snapshot(bad_tree)
            bad = run(bad_tree, apply)
            check(surface + ": " + name + " rejection", lambda: require(
                bad.returncode != 0 and reason in bad.stderr and snapshot(bad_tree) == before,
                "invalid input rejected before any publication"))
        observations.append({
            "surface": surface, "source_path": current, "candidate": envelope(candidate),
            "root": envelope(final_root), "manifest": envelope(manifest),
            "archive": envelope(part), "removed_separator": envelope(removed),
        })

    # These probes never write the supplied destinations. The symbolic escape
    # itself lives in managed scratch; its target is only resolved, never amended.
    escape = run_tree / "report-escape"
    escape.symlink_to(os.path.relpath(ROOT.parent, escape.parent), target_is_directory=True)
    path_probes = []
    for name, value, rejected in [
        ("relative destination", "docs/checkpoints/rollover-path-probe.json", False),
        ("traversal rejection", "../rollover-path-probe.json", True),
        ("absolute rejection", "/dev/null", True),
        ("symbolic parent rejection", escape.relative_to(ROOT).as_posix() + "/report.json", True),
        ("Git metadata rejection", ".git/rollover-path-probe.json", True),
    ]:
        try:
            project_report_path(value)
            observed = False
        except ValueError:
            observed = True
        path_probes.append({"name": name, "input": value, "rejected": observed})
        check("report path: " + name, lambda: require(observed == rejected,
              "resolved same-volume report destination guard"))
    traversal = ROOT / "../rollover-path-probe.json"
    prior_guard = {"lexical_accepts": traversal.is_relative_to(ROOT),
                   "resolved_inside": traversal.resolve().is_relative_to(ROOT)}
    assert prior_guard == {"lexical_accepts": True, "resolved_inside": False}, "actual prior lexical-guard defect"
    report = {
        "complete": True, "revision": revision, "producer_revision": producer_revision,
        "original": args.original, "git_shim": envelope(shim.read_bytes()),
        "producer": envelope(tool), "instrument_sha256": sha(Path(__file__).read_bytes()),
        "reader": envelope(reader),
        "catalog_helper": None if catalog_helper is None else envelope(catalog_helper),
        "source_inputs": [{"path": path, **envelope(raw)}
                          for path, raw in sorted(inputs.items())],
        "results": results, "commands": commands, "observations": observations,
        "report_path_probes": path_probes, "prior_report_guard": prior_guard,
    }
    if output is not None:
        output.write_text(json.dumps(report, indent=2) + "\n")
    for index, result in enumerate(results, 1):
        print(("ok" if result["ok"] else "not ok") + f" {index} - " + result["name"])
        if not result["ok"]:
            print("# " + result["reason"])
    print(f"1..{len(results)}")
    return 0 if all(result["ok"] for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
