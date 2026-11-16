"""Retain actual command channels; outer launcher first-use is not claimed."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
phase = sys.argv[1]
assert phase in ('capture', 'review')
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / (phase + '.py'))]
if phase == 'review':
    argv.append('--current')
with (BASE / (phase + '-command.json')).open('x') as stream:
    json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
    stream.write('\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (BASE / (phase + '-' + name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(BASE / (phase + '-exit.txt')).write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'command failed; original channels retained'
print(result.stdout.decode(), end='')
