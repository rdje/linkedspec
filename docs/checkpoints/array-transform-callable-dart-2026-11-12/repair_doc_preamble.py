"""Restore the unchanged changelog preamble after a draft insertion error."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
path = ROOT / 'CHANGES.md'
bad = path.read_bytes()
(BASE / 'changes-draft-before-preamble-repair.md.gz').write_bytes(gzip.compress(bad, mtime=0))
start = bad.index(b'## 2026-11-12 ')
end = bad.index(b'\n\n## ` records.', start)
record = bad[start:end] + b'\n\n'
original = subprocess.check_output(['git', 'show', '5ac1fac5eb7126cd8f952858f8df194914884830:CHANGES.md'], cwd=ROOT)
boundary = re.search(rb'^## ', original, re.M).start()
fixed = original[:boundary] + record + original[boundary:]
assert fixed[:boundary] == original[:boundary]
assert fixed[boundary + len(record):] == original[boundary:]
path.write_bytes(fixed)
(BASE / 'doc-preamble-qualification.json').write_text(json.dumps(dict(
    observed_check_exit=255, observed_combined_tool_output='change_history current preamble omits its history manifest',
    original_separated_channels='not retained by the direct exec tool call',
    root_cause='Draft insertion searched for an unanchored ## token and matched its inline preamble example.',
    repair='Restore exact clean-base preamble and all old records; insert the same new record only at the first line-anchored header.',
    original_sha256=hashlib.sha256(original).hexdigest(), draft_sha256=hashlib.sha256(bad).hexdigest(),
    repaired_sha256=hashlib.sha256(fixed).hexdigest()), indent=2) + '\n')
print('Restored exact clean-base changelog preamble/old records; same new record inserted at actual header')
