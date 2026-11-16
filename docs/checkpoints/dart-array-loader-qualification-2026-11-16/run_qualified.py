"""Retain qualification command channels without replacing the original capture records."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd()); phase = sys.argv[1]
assert phase in ('qualify', 'review-qualified')
script = 'qualify.py' if phase == 'qualify' else 'review_qualified.py'
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / script)]
if phase == 'review-qualified':
    argv.append('--current')
with (BASE / (phase + '-command.json')).open('x') as stream:
    json.dump(dict(argv=argv, cwd='.'), stream, indent=2); stream.write('\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / (phase + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / (phase + '-exit.txt')).write_text(str(result.returncode) + '\n')
print(result.stdout.decode(), end='')
if result.stderr:
    print(result.stderr.decode(), end='', file=sys.stderr)
assert result.returncode == 0, 'actual qualification failure retained'
