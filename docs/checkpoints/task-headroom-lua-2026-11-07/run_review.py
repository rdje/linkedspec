"""Capture the first readonly review without replacing an earlier attempt."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert not (BASE / 'review-exit.txt').exists()
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]
(BASE / 'review-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
    (BASE / ('review-' + name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'review-exit.txt').write_text(str(result.returncode) + '\n')
print('First readonly review actual exit', result.returncode)
assert result.returncode == 0 and not result.stderr, 'retain failure unchanged; qualify separately'
(BASE / 'review-result.json').write_bytes(result.stdout)
print(result.stdout.decode())
