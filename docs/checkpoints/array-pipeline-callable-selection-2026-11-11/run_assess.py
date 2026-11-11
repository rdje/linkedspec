"""Retain actual first recovery command, all channels and exit/result."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
packet = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(BASE / 'assess.py')])
assert not (BASE / 'assessment-command.json').exists()
(BASE / 'assessment-command.json').write_text(json.dumps(packet, indent=2) + '\n')
paths = [Path(__file__).relative_to(Path.cwd()), BASE / 'assess.py', BASE / 'cases.json', BASE / 'intake/observer-stdout.log.gz']
identities = {str(path): dict(bytes=len(path.read_bytes()), sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777) for path in paths}
(BASE / 'assessment-inputs.json').write_text(json.dumps(identities, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=packet['cwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, row in identities.items():
    path = Path(name)
    assert len(path.read_bytes()) == row['bytes'] and hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']

for channel in ('stdout', 'stderr'):
    (BASE / ('assessment-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'assessment-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'Actual reader failure retained; no PASS credit'
print(result.stdout.decode(), end='')
