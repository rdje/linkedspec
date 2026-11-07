"""Capture every qualified writer/reader wrapper channel before physical storage."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'apply', 'replay', 'after')
phase = sys.argv[1]
prefix = BASE / ('advisory-step-' + phase)
assert not prefix.with_suffix('.exit.txt').exists()
if phase in ('before', 'after'):
    command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'capture_advisory_bound.py'), phase]
else:
    command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'preserve_advisory_claim.py')]
    if phase == 'apply': command.append('--apply')
prefix.with_suffix('.command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
actual = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for label, raw in (('stdout', actual.stdout), ('stderr', actual.stderr)):
    prefix.with_suffix('.' + label + '.log.gz').write_bytes(gzip.compress(raw, mtime=0))
prefix.with_suffix('.exit.txt').write_text(str(actual.returncode) + '\n')
print('Advisory step', phase, 'actual exit', actual.returncode)
assert actual.returncode == 0 and not actual.stderr, 'retain failed epoch unchanged; qualify separately'
print(actual.stdout.decode())
