"""Prelanding current named SDK/grammar/instrument identity; historical review is separate."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
identities = json.loads((HERE / 'qualified/input-identities.json').read_bytes())
selected = {name: row for name, row in identities.items()
    if name.startswith(('perl/', 'specs/')) or name.endswith(('.py', '.pl'))}
for name, row in selected.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], 'named current input changed: ' + name
    assert path.stat().st_mode & 0o777 == row['mode'], 'named current mode changed: ' + name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'e29638a99224be51fe454a1935a428c2a1a9a270'
print(json.dumps(dict(result='PASS', current_named_inputs=len(selected),
    scope='Prelanding SDK/grammar/actual intake instrument identities only; no new runtime or historical-first-use inference.'), sort_keys=True))
