"""Retain the actual first readonly invocation, full channels and exit."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
target = BASE / 'review-command.json'
assert not target.exists()
sources = {str(BASE / name): hashlib.sha256((BASE / name).read_bytes()).hexdigest()
    for name in ('review.py', 'run_review.py', 'sealed-identities.json')}
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'review.py')]
target.write_text(json.dumps(dict(cwd='.', argv=argv, inputs=sources), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('review-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'review-exit.txt').write_text(str(result.returncode) + '\n')
for name, expected in sources.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == expected
assert result.returncode == 0 and not result.stderr, 'First actual failure retained; qualify separately'
summary = json.loads(result.stdout)
(BASE / 'review-result.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
