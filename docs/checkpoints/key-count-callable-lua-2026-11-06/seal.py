"""Bind completed Lua acquisition files and exact producer bytes without rerunning hosts."""
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/key-count-callable-lua-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot seal'
paths = []
for phase in ('intake', 'direct'):
    root = BASE / phase
    for host in ('puc', 'luajit'):
        assert (root / host / 'normal-exit.txt').read_text() == '0\n'
    paths += sorted(p for p in root.rglob('*') if p.is_file())
paths += [BASE / name for name in ('capture.py', 'observer.lua', 'freeze_profiles.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Completed per-host direct inputs, producers, modules/parsed specs and full channels sealed')
