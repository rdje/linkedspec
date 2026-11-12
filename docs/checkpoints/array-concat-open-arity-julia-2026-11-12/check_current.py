"""Activation/pre-staging identity check for the actual declared direct inputs."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '952f8a022c59a478614ba1413e0e36e49e7e14e8'
assert subprocess.run(['git', 'diff', '--cached', '--quiet']).returncode == 0
packet = json.loads((BASE / 'direct/custody.json').read_bytes())[0]
assert packet['tag'] == 'root'
for name, row in packet['files'].items():
    path = Path(name)
    assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
    assert path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(packet['files']),
    scope='Actual finite direct SDK/source/fixture/grammar/wrapper/instrument inputs at activation/pre-staging only. No future freshness or complete native/cache/transitive/toolchain/OS closure.')))
