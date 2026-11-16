"""Preserve actual phase channels once; completed writers are never replayed."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
phase = sys.argv[1]
phases = {'capture': ['capture.py'], 'review': ['review.py', '--current'],
          'historical-pressure': ['historical_pressure.py'], 'publish': ['publish.py']}
if phase == 'book':
    command = ['bash', 'tools/run_mdbook_local.sh']
else:
    assert phase in phases
    script, *arguments = phases[phase]
    command = ['bash', 'tools/run_python_project_data.sh', str(BASE / script), *arguments]
folder = BASE / 'phases' / phase
folder.mkdir(parents=True)
with (folder / 'command.json').open('x') as stream:
    json.dump(dict(argv=command, cwd='.'), stream, indent=2)
    stream.write('\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (folder / (channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(folder / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0, 'actual failed phase retained:' + phase
if phase != 'book':
    assert result.stderr == b'', 'unexpected phase stderr retained:' + phase
if phase in ('review', 'historical-pressure'):
    json.loads(result.stdout)
    (BASE / (phase + '-stdout.json')).write_bytes(result.stdout)
    (BASE / (phase + '-stderr.txt')).write_bytes(result.stderr)
print('Completed ' + phase + '; full actual channels retained.')
