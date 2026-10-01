"""Audit the bounded lossless milestone's committed source and retained-log evidence.

Run through tools/run_python_project_data.sh from any working directory. This reads
only LinkedSpec and its Git history; it does not execute or inspect dependencies.
"""

import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[3]
PREFIX = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3."
LEAVES = ("1", "2", "3", "4.1", "4.2", "4.3", "4.4")
BOOK = "docs/linkedspec-book/src/architecture/structured-format-program.md"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def read_relative(path):
    candidate = Path(path)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise ValueError(f"non-repository evidence path: {path}")
    resolved = (ROOT / candidate).resolve()
    resolved.relative_to(ROOT)
    return resolved.read_bytes()


def audit():
    checkpoints, current_sources, logs, updates = {}, {}, {}, []
    references = 0
    for leaf in LEAVES:
        path = f"docs/checkpoints/{PREFIX}{leaf}-verification.json"
        contents = read_relative(path)
        record = json.loads(contents)
        assert record["owner"] == PREFIX + leaf, path
        # The addition commit is the producing revision even after future annotations.
        commit = git("log", "--diff-filter=A", "-1", "--format=%H", "--", path).decode().strip()
        assert len(commit) == 40, f"missing producing commit: {path}"
        assert git("show", f"{commit}:{path}") == contents, f"checkpoint changed since production: {path}"
        for source, expected in record["source_hashes"].items():
            historical = digest(git("show", f"{commit}:{source}"))
            assert historical == expected, f"source differs at producing commit: {path}: {source}"
            current = digest(read_relative(source))
            references += 1
            current_sources[source] = current
            if current != expected:
                # Only the book has evolved between these leaves; no executable exception.
                assert source == BOOK, f"unreconciled current source drift: {path}: {source}"
                updates.append({"checkpoint": path, "source": source,
                                "producing_commit": commit, "recorded": expected, "current": current})
        for log, entry in record["logs"].items():
            expected = entry["sha256"] if isinstance(entry, dict) else entry
            assert digest(read_relative(log)) == expected, f"retained log mismatch: {log}"
            assert log not in logs, f"duplicate retained log counted twice: {log}"
            logs[log] = expected
        checkpoints[path] = {"sha256": digest(contents), "producing_commit": commit,
                             "source_references": len(record["source_hashes"]), "logs": len(record["logs"])}

    cases = json.loads(read_relative("tests/language-readiness/lossless-segments/cases.json"))
    child = json.loads(read_relative("tests/language-readiness/lossless-child/cases.json"))
    assert len(cases["accept"]) == 13 and len(child["accept"]) == 4 and len(child["reject"]) == 15
    segments = 0
    for row in cases["accept"]:
        cursor, pieces = 0, []
        for part in row["expected"]:
            span = part["span"]
            first, last = span if isinstance(span, list) else (span["start"], span["end"])
            assert first == cursor and 0 <= first <= last <= len(row["input"]), row["id"]
            assert row["input"][first:last] == part["text"], row["id"]
            pieces.append(part["text"])
            cursor = last
            segments += 1
        assert cursor == len(row["input"]) and "".join(pieces) == row["input"], row["id"]
    assert references == 180 and len(logs) == 47 and segments == 39
    return {"source_references": references, "unique_sources": len(current_sources),
            "retained_logs": len(logs), "segmentation_cases": 13, "segments": segments,
            "child_accept": 4, "child_reject": 15, "checkpoints": checkpoints,
            "current_source_hashes": current_sources, "log_hashes": logs,
            "historically_verified_book_updates": updates,
            "limits": "Source/log integrity and independent segment slicing; runtime execution remains the recorded per-leaf proof."}


if __name__ == "__main__":
    print(json.dumps(audit(), indent=2, sort_keys=True))
