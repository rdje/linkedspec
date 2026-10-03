"""Distinguish actual legacy-log reads and tracked writes in the two review modes."""
import contextlib
import io
import json
from pathlib import Path
import runpy
import sys
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
review = ROOT / f"docs/checkpoints/{OWNER}-review.py"
capture = json.loads((ROOT / f"docs/checkpoints/{OWNER}-verification.json").read_text())
legacy = {ROOT / name for name in capture["audit_report"]["retained_log_hashes"]}
original_read = Path.read_bytes
original_argv = sys.argv
results = []
for arguments in (["--normalization-only"], []):
    attempts = {"legacy_reads": [], "tracked_writes": []}

    def read_guard(path):
        if path in legacy:
            attempts["legacy_reads"].append(path.relative_to(ROOT).as_posix())
            raise PermissionError("controlled legacy artifact read denial")
        return original_read(path)

    def write_guard(path, *args, **kwargs):
        attempts["tracked_writes"].append(path.relative_to(ROOT).as_posix())
        raise PermissionError("controlled tracked capture write denial")

    output = io.StringIO()
    sys.argv = [str(review), *arguments]
    try:
        with patch.object(Path, "read_bytes", read_guard), patch.object(Path, "write_text", write_guard), \
                contextlib.redirect_stdout(output):
            runpy.run_path(str(review), run_name="__main__")
    except SystemExit as error:
        assert arguments and error.code == 0
    except PermissionError as error:
        assert not arguments and str(error) == "controlled legacy artifact read denial"
    else:
        raise AssertionError("review mode missed its distinguishing boundary")
    finally:
        sys.argv = original_argv
    assert attempts["tracked_writes"] == []
    if arguments:
        assert attempts["legacy_reads"] == []
        report = json.loads(output.getvalue())
        assert report["normalization_paired_cases"] == 7
        assert len(report["observation_corruptions_rejected"]) == 4
    else:
        assert attempts["legacy_reads"] == [".linkedspec-data/scratch/context-lua-storage.log"]
    results.append({"mode": arguments[0] if arguments else "snapshot-writer", **attempts})
print(json.dumps({"status": "PASS", "modes": results,
    "scope": "Actual guarded reads/writes; no original artifact moved, removed or overwritten."}, sort_keys=True))
