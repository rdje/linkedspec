"""Gate live current files against the actual direct-run root inputs."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
assert subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=ROOT).returncode == 0
packets = json.loads((BASE / 'direct/custody.json').read_bytes())
packet, = [row for row in packets if row['archive'].endswith('/root-inputs.tar.gz')]
for name, row in packet['files'].items():
    path = ROOT / name
    assert not Path(name).is_absolute() and '..' not in Path(name).parts and not path.is_symlink()
    assert path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(packet['files']),
    scope='Actual direct-run SDK/spec/test/fixture/instrument/wrapper identities at activation/pre-staging only; no future freshness or full native/cache/transitive closure.')))
