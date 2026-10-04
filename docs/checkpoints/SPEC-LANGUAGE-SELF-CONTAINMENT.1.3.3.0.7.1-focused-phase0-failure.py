"""Preserve and independently review the completed full focused Phase0 failure."""
import base64
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
LOG = ".linkedspec-data/scratch/nested-raw-readiness-repair/phase0-span-check.log"


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def validate(record):
    if (record["owner"] != OWNER or record["command"] != ["bash", "tools/project_data_run.sh", "prove", "-Iperl", "t/phase0_regression.t"]
            or record["exit"] != 1):
        raise ValueError("focused Phase0 identity")
    try:
        raw = base64.b64decode(record["log_envelope"]["base64"], validate=True)
    except ValueError as error:
        raise ValueError("focused Phase0 base64") from error
    if len(raw) != record["log_envelope"]["bytes"] or sha(raw) != record["log_envelope"]["sha256"]:
        raise ValueError("focused Phase0 bytes")
    if (len(re.findall(rb"^#   Failed test '", raw, re.M)) != 24 or
            b"Failed 24/1034 subtests" not in raw or
            b"Failed tests:  815-826, 829, 851-856, 858, 860-861, 1021-1022" not in raw or
            not raw.endswith(b"Result: FAIL\n")):
        raise ValueError("focused Phase0 failure boundary")
    for path, expected in record["frozen_inputs"].items():
        if sha((ROOT / path).read_bytes()) != expected:
            raise ValueError("focused Phase0 frozen input")
    return raw


if __name__ == "__main__":
    if sys.argv[1:] != ["--capture"]:
        raise ValueError("--capture required")
    raw = (ROOT / LOG).read_bytes()
    paths = [PREFIX + "before-span-phase0.t"] + [PREFIX + "before-compat-" + name + ".pm"
             for name in ("Parser", "RuleIR", "EmitContext", "Diagnostics", "RawDependencies")]
    record = {"owner": OWNER, "command": ["bash", "tools/project_data_run.sh", "prove", "-Iperl", "t/phase0_regression.t"],
              "exit": 1, "log_envelope": {"original_path": LOG, "bytes": len(raw), "sha256": sha(raw),
                                           "base64": base64.b64encode(raw).decode()},
              "frozen_inputs": {path: sha((ROOT / path).read_bytes()) for path in paths},
              "limits": "Complete merged prove output and full1034-test failure summary, not full verbose TAP. Twenty-four metadata assertions fail; child Perl exit24, prove/project wrapper exit1. Exact pre-classification production snapshots bind this worktree run; it is not canonical receipt proof."}
    validate(record)
    print(json.dumps(record, indent=2))
