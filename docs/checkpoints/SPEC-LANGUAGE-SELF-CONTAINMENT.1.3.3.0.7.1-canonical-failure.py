"""Preserve and verify the actual first canonical documentation-pressure failure."""
import base64
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
LOG = ".linkedspec-data/scratch/nested-raw-readiness-repair/canonical.log"
CHAPTER = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
BOUNDARY = ("[readme-routing] FAIL: surface diagnostics exceeds control: " +
            CHAPTER + " lines 2053/2048\n").encode()


def validate(record):
    if (record["owner"] != OWNER or record["activation"] != "c9673d7eff39836fdc94d59b8d47639db5e937d4" or
            record["candidate"] != "72c60e97b43c7f69c833e378d8e81f70601eba254bede14da2b2416b6e8ac0ef"):
        raise ValueError("canonical failure candidate identity")
    if record["command"] != ["bash", "tools/run_ci_local.sh"] or record["exit"] != 1:
        raise ValueError("canonical failure command/exit")
    envelope = record["log_envelope"]
    try:
        raw = base64.b64decode(envelope["base64"], validate=True)
    except ValueError as error:
        raise ValueError("canonical failure base64") from error
    if len(raw) != envelope["bytes"] or hashlib.sha256(raw).hexdigest() != envelope["sha256"]:
        raise ValueError("canonical failure byte identity")
    if (envelope["original_path"] != LOG or BOUNDARY not in raw or
            b"  FAIL  README-STABILITY" not in raw or
            raw.count(b"  PASS  ") != 9 or
            not raw.endswith(b"doctrines: one or more doctrines FAILED \xe2\x80\x94 commit/merge blocked. Fix above; do not bypass.\n")):
        raise ValueError("canonical failure boundary")
    before = (ROOT / (PREFIX + "before-local-ci.md")).read_bytes()
    if len(before.splitlines()) != 2053 or hashlib.sha256(before).hexdigest() != record["chapter_sha256"]:
        raise ValueError("canonical failure chapter identity")
    return raw


if __name__ == "__main__":
    if sys.argv[1:] != ["--capture"]:
        raise ValueError("expected --capture")
    raw = (ROOT / LOG).read_bytes()
    record = {"owner": OWNER, "command": ["bash", "tools/run_ci_local.sh"], "exit": 1,
              "activation": "c9673d7eff39836fdc94d59b8d47639db5e937d4",
              "candidate": "72c60e97b43c7f69c833e378d8e81f70601eba254bede14da2b2416b6e8ac0ef",
              "chapter_sha256": hashlib.sha256((ROOT / (PREFIX + "before-local-ci.md")).read_bytes()).hexdigest(),
              "log_envelope": {"original_path": LOG, "bytes": len(raw),
                               "sha256": hashlib.sha256(raw).hexdigest(),
                               "base64": base64.b64encode(raw).decode("ascii")}}
    validate(record)
    print(json.dumps(record, indent=2))
