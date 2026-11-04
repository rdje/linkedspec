"""Preserve the preceding restoration claims at their exact committed boundary."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
PREFIX = "docs/checkpoints/task-acceptance-backend-scope/"
RECORD = "docs/claims/TYPE-REFERENCE-BOOK.1.2.20.1.10.json"
NAMES = {"approved-archive-reference-preservation", "historical-objective-current-source-integrity"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    revision = json.loads((ROOT / (PREFIX + "before.json")).read_bytes())["base"]
    before = subprocess.check_output(["git", "show", f"{revision}:{RECORD}"], cwd=ROOT)
    original = json.loads(before)
    expected = copy.deepcopy(original)
    inputs = {}
    seen = set()
    for claim in expected["claims"]:
        if claim["name"] not in NAMES:
            continue
        seen.add(claim["name"])
        leg = claim["durability"]
        assert leg["status"] == "checked" and leg["mode"] == "live" and "revision" not in leg
        for row in leg["inputs"]:
            previous = inputs.setdefault(row["path"], row["sha256"])
            assert previous == row["sha256"], "original input identity disagreement"
        leg.update(mode="historical", revision=revision)
    assert seen == NAMES, "original claim population changed"
    # Verify every original artifact identity against Git, not current worktree
    # bytes, before changing either claim's live/historical declaration.
    process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for name, digest in sorted(inputs.items()):
            process.stdin.write(f"{revision}:{name}\n".encode())
            process.stdin.flush()
            header = process.stdout.readline().split()
            assert len(header) == 3 and header[1] == b"blob", f"missing historical input {name}"
            remaining = int(header[2])
            hasher = hashlib.sha256()
            while remaining:
                raw = process.stdout.read(min(remaining, 1024 * 1024))
                assert raw, f"truncated historical input {name}"
                hasher.update(raw)
                remaining -= len(raw)
            assert process.stdout.read(1) == b"\n"
            assert hasher.hexdigest() == digest, f"historical input differs: {name}"
    finally:
        process.stdin.close()
        assert process.wait() == 0
    target = ROOT / RECORD
    if args.apply:
        assert target.read_bytes() == before, "preservation writer requires exact predecessor record"
        target.write_text(json.dumps(expected, separators=(",", ":")) + "\n")
    assert json.loads(target.read_bytes()) == expected, "fields other than mode/revision changed"
    print(f"claim-preservation: PASS original fields and {len(inputs)} Git input identities; only mode/revision change")


if __name__ == "__main__":
    main()
