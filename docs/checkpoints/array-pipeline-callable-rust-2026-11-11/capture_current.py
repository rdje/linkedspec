"""Record one actual current-source check without overwriting earlier evidence."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
target = BASE / 'current-command.json'
assert not target.exists()
names = ('check_current.py', 'capture_current.py', 'direct/custody.json')
inputs = {str(BASE / name): hashlib.sha256((BASE / name).read_bytes()).hexdigest() for name in names}
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'check_current.py')]
target.write_text(json.dumps(dict(cwd='.', argv=argv, inputs=inputs), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('current-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'current-exit.txt').write_text(str(result.returncode) + '\n')
for name, expected in inputs.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == expected
assert result.returncode == 0 and not result.stderr, 'Actual source-check failure retained'
(BASE / 'current-result.json').write_bytes(result.stdout)
print(result.stdout.decode(), end='')
