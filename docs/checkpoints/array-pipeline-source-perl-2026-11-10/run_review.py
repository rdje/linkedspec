"""Retain the actual first readonly command, full channels and exit."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
target = BASE / 'review-command.json'
assert not target.exists()
packet = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')])
target.write_text(json.dumps(packet, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=packet['cwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('review-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'review-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'First readonly failure retained without PASS credit'
(BASE / 'review-result.json').write_bytes(result.stdout)
print(result.stdout.decode())
