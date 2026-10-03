"""Reproduce the original missing-report failure and verify tracked-data recovery."""
import contextlib
import hashlib
import io
import json
from pathlib import Path
import runpy
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
BEFORE_SHA = "9d186b46847aa51ec6e4cc031528f67faad3786dd9ce7b8c5fbfd56e6b20d94b"
before = ROOT / f"docs/checkpoints/{OWNER}-mode-proof-before.py"
after = ROOT / f"docs/checkpoints/{OWNER}-mode-proof.py"
assert hashlib.sha256(before.read_bytes()).hexdigest() == BEFORE_SHA
missing = ROOT / ".linkedspec-data/scratch/normalization-correction-objective-audit-3.log"
original_read = Path.read_bytes
results = []
for name, source in (("original", before), ("repaired", after)):
    attempts = []

    def deny_report(path):
        if path == missing:
            attempts.append(path.relative_to(ROOT).as_posix())
            raise FileNotFoundError("controlled fresh-checkout audit-report absence")
        return original_read(path)

    output = io.StringIO()
    try:
        with patch.object(Path, "read_bytes", deny_report), contextlib.redirect_stdout(output):
            runpy.run_path(str(source), run_name="__main__")
    except FileNotFoundError as error:
        assert name == "original"
        assert str(error) == "controlled fresh-checkout audit-report absence"
        assert attempts == [missing.relative_to(ROOT).as_posix()]
        result = "RED: original requires the absent ignored report"
    else:
        assert name == "repaired" and attempts == []
        report = json.loads(output.getvalue())
        assert report["status"] == "PASS"
        quiet, snapshot = report["modes"]
        assert quiet["legacy_reads"] == quiet["tracked_writes"] == []
        assert quiet["captured_report_reads"] == 0
        assert snapshot["legacy_reads"] == [".linkedspec-data/scratch/context-lua-storage.log"]
        assert snapshot["tracked_writes"] == [] and snapshot["captured_report_reads"] == 1
        result = "GREEN: tracked report data needs no ignored report read"
    results.append({"mode": name, "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                    "original_report_read_attempts": attempts, "result": result})
print(json.dumps({"status": "PASS", "controls": results,
    "scope": "Actual report-read denial; both mode proofs guard tracked writes and legacy log reads. No original artifact moved, removed or overwritten."}, sort_keys=True))
