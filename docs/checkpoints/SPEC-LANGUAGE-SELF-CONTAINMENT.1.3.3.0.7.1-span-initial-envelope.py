"""Losslessly preserve initial diagnostic streams while keeping patch whitespace clean."""
import base64
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"


def envelope(raw, source):
    return {"owner": OWNER, "source": source, "encoding": "base64",
            "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest(),
            "base64": base64.b64encode(raw).decode(),
            "limits": "Original initial diagnostic output, preserved byte-exact including trailing spaces. This is excluded instrument evidence, not successful current compiler proof."}


def validate(record):
    raw = base64.b64decode(record["base64"], validate=True)
    if record["owner"] != OWNER or record["encoding"] != "base64" or len(raw) != record["bytes"] \
            or hashlib.sha256(raw).hexdigest() != record["sha256"]:
        raise ValueError("initial diagnostic envelope byte identity")
    return raw


if __name__ == "__main__":
    if sys.argv[1:] == ["--capture"]:
        for name in ("span-initial.json", "span-unit-initial.log"):
            path = ROOT / (PREFIX + name)
            raw = path.read_bytes()
            record = envelope(raw, PREFIX + name)
            assert validate(record) == raw
            path.write_text(json.dumps(record, indent=2) + "\n")
    elif sys.argv[1:] == ["--capture-interrupted"]:
        source = ".linkedspec-data/scratch/nested-raw-readiness-repair/canonical-compat-final.log"
        record = envelope((ROOT / source).read_bytes(), source)
        record.update({"kind": "interrupted_canonical_startup", "exit": 143,
                       "activation": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
                       "staged_content_sha256": hashlib.sha256(subprocess.check_output(
                           ["git", "diff", "--cached", "--binary", "--full-index", "--no-ext-diff", "HEAD"], cwd=ROOT)).hexdigest(),
                       "command": "bash tools/run_ci_local.sh > " + source + " 2>&1",
                       "limits": "Owned canonical runner stopped with TERM after a failed staged whitespace check, during doctrine startup. Partial stream only; no successful receipt or failed-test/complete-gate claim."})
        validate(record)
        (ROOT / (PREFIX + "canonical-interrupted.json")).write_text(json.dumps(record, indent=2) + "\n")
    elif sys.argv[1:]:
        raise ValueError("unexpected arguments")
    records = [json.loads((ROOT / (PREFIX + name)).read_bytes())
               for name in ("span-initial.json", "span-unit-initial.log")]
    print(json.dumps({"owner": OWNER, "result": "PASS", "preserved_bytes": [len(validate(record)) for record in records],
                      "limits": "Storage encoding only; actual raw compiler/TAP diagnostic bytes remain recoverable."}, indent=2))
