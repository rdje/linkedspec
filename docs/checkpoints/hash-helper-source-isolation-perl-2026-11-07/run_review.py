"""Retain exact first readonly recovery channels, including any failure."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert not (BASE / 'review-exit.txt').exists(), 'one-shot recovery'
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]
(BASE / 'review-command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
    (BASE / ('review-' + name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'review-exit.txt').write_text(str(result.returncode) + '\n')
print('First source recovery retained, exit', result.returncode)
if result.returncode == 0:
    print(result.stdout.decode(), end='')
assert result.returncode == 0, 'preserve failed instrument and qualify separately'
