"""Bind completed public selection and copy qualification without rerunning behavior."""
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-selection-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot seal'
paths = []
for phase in ('intake', 'copy-controls'):
    root = BASE / phase
    assert (root / 'exit.txt').read_text() == '0\n'
    paths += sorted(p for p in root.iterdir() if p.is_file())
paths += [BASE / name for name in ('capture.py', 'observer.pl', 'cases.py', 'cases.json',
          'capture_copy.py', 'copy_cases.py', 'copy-controls.json', 'freeze_targets.py', 'review.py', 'seal.py')]
paths += [Path('tests/fixtures') / name for name in ('hash_view_result_guard_cases.json', 'copy_result_guard_cases.json')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual complete public epochs and unchanged source projections sealed')
