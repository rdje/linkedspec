"""Bind completed acquisition files and their actual producer bytes without rerunning Julia."""
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/key-count-callable-julia-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot seal'
paths = []
for phase in ('intake', 'direct'):
    root = BASE / phase
    assert (root / 'exit.txt').read_text() == '0\n'
    paths += sorted(p for p in root.iterdir() if p.is_file())
paths += [BASE / name for name in ('capture.py', 'observer.jl', 'freeze_profiles.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Completed inputs, producers, actual modules/parsed specs and raw channels sealed')
