"""Losslessly preserve the completed second canonical failure and its identity."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "c9673d7eff39836fdc94d59b8d47639db5e937d4"
CANDIDATE = "ebed0056cb566605ced5c235c02df5770f817619bae796ca09e84a2bb9ff7913"
LOG = ".linkedspec-data/scratch/nested-raw-readiness-repair/canonical-accepted.log"


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def validate(record):
    if (record["owner"] != OWNER or record["activation"] != BASE or
            record["candidate"] != CANDIDATE or record["command"] != ["bash", "tools/run_ci_local.sh"] or
            record["exit"] != 1):
        raise ValueError("runtime canonical candidate identity")
    envelope = record["log_envelope"]
    try:
        packed = base64.b64decode(envelope["base64"], validate=True)
    except ValueError as error:
        raise ValueError("runtime canonical base64") from error
    if (envelope["encoding"] != "gzip+base64" or len(packed) != envelope["compressed_bytes"] or
            sha(packed) != envelope["compressed_sha256"]):
        raise ValueError("runtime canonical compressed identity")
    try:
        raw = gzip.decompress(packed)
    except (OSError, EOFError) as error:
        raise ValueError("runtime canonical gzip") from error
    if len(raw) != envelope["bytes"] or sha(raw) != envelope["sha256"]:
        raise ValueError("runtime canonical raw identity")
    if (envelope["original_path"] != LOG or raw.count(b"  PASS  ") != 10 or
            raw.count(b"#   Failed test 'bridge_keyword_") != 2 or
            b"# Looks like you failed 2 tests of 605.\n" not in raw or
            b"  Failed tests:  86, 181\n" not in raw or
            not raw.endswith(b"Result: FAIL\n")):
        raise ValueError("runtime canonical failure boundary")
    old = (ROOT / (PREFIX + "before-codeblock-push.t")).read_bytes()
    if sha(old) != record["baseline_test_sha256"]:
        raise ValueError("runtime canonical fixture identity")
    return raw


if __name__ == "__main__":
    if sys.argv[1:] != ["--capture"]:
        raise ValueError("expected --capture")
    raw = (ROOT / LOG).read_bytes()
    packed = gzip.compress(raw, mtime=0)
    record = {"owner": OWNER, "activation": BASE, "candidate": CANDIDATE,
              "command": ["bash", "tools/run_ci_local.sh"], "exit": 1,
              "baseline_test_sha256": sha((ROOT / (PREFIX + "before-codeblock-push.t")).read_bytes()),
              "log_envelope": {"original_path": LOG, "encoding": "gzip+base64",
                               "bytes": len(raw), "sha256": sha(raw),
                               "compressed_bytes": len(packed), "compressed_sha256": sha(packed),
                               "base64": base64.b64encode(packed).decode("ascii")}}
    validate(record)
    print(json.dumps(record, indent=2))
