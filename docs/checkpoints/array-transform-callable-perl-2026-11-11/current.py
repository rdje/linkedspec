"""Check current named SDK/grammar/intake instruments before staging, not later history."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
selected = {}
for phase in ('intake', 'terminal'):
    for name, row in json.loads((HERE / phase / 'input-identities.json').read_bytes()).items():
        if name.startswith(('perl/', 'specs/')) or name.endswith(('.py', '.pl')):
            if name in selected: assert selected[name] == row
            selected[name] = row
for name, row in selected.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '51e1eb3522d2e7b963841be4388144437265ac44'
print(json.dumps(dict(result='PASS', named_current_inputs=len(selected),
    scope='Pre-staging SDK/grammar/actual acquisition instruments; no new runtime or historical freshness claim.'), sort_keys=True))
