"""Seal completed copy normal/control inputs, modules, producers and full channels."""
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/copy-result-guard-perl-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot completed evidence seal'
paths = []
for phase in ('before', 'after', 'final', 'direct'):
    root = BASE / phase
    assert (root / 'exit.txt').is_file()
    paths += sorted(path for path in root.rglob('*') if path.is_file())
assert (BASE / 'causal-control-exit.txt').read_text() == '0\n'
paths += sorted(path for path in (BASE / 'logical-control').rglob('*') if path.is_file())
paths += [BASE / name for name in ('write_preservation.py', 'capture.py', 'capture_final.py',
          'observe_control.pl', 'causal_control.py', 'causal-control-result.log', 'causal-control-stderr.log',
          'causal-control-exit.txt', 'producer-change.patch', 'producer-change-final.patch', 'review.py', 'seal.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    body = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual completed normal/control epochs, producers and module/handler strings sealed')
