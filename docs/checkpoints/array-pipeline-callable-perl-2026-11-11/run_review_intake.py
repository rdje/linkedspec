"""Retain actual first recovery command, all channels and exit/result."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
packet = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(BASE / 'intake_review_intake.py')])
assert not (BASE / 'intake-review-command.json').exists()
(BASE / 'intake-review-command.json').write_text(json.dumps(packet, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=packet['cwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('intake-review-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'intake-review-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'Actual reader failure retained; no PASS credit'
summary = json.loads(result.stdout)
(BASE / 'intake-review-result.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
