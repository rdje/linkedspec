"""Activation/pre-staging identity gate for actual declared SDK/direct inputs."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '9a6b229ce3f944ef3822e71935b1c40c109f74b9'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=ROOT).returncode == 0
files = json.loads((BASE / 'direct/input-identities.json').read_bytes())
writer = json.loads((BASE / 'repair-run/identities.json').read_bytes())
for name, row in writer.items():
    if name not in ('lua/src/linkedspec/interpreter.lua', 'lua/test/run.lua'):
        files[name] = row
trace = json.loads((BASE / 'traceq/input-identities.json').read_bytes())
for name, row in trace.items():
    if name.startswith(str(BASE) + '/'):
        files[name] = row
for name, row in files.items():
    path = Path(name)
    assert not path.is_absolute() and '..' not in path.parts
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(files),
    scope='Exact actual direct SDK/instrument/fixture/grammar/wrapper inputs at activation/pre-staging; no future freshness or native/cache/transitive admission.')))
