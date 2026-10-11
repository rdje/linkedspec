"""One-shot outer capture, including an actual preserved-preflight recurrence."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/'
target = ROOT / (DIR + 'recovery-invocation.json')
reached = ROOT / (DIR + 'recovery-invocation-reached.json')
assert not target.exists() and not reached.exists()
sha = lambda raw: hashlib.sha256(raw).hexdigest()
data = {'producer_sha256': sha(Path(__file__).read_bytes()), 'rows': [],
        'original_failed_boundary': 'The population draft original tool invocation exited1 at original_sha256 comparison before a recovery report or publisher execution. No original outer invocation capsule was saved; this separately identified fresh recurrence does not reconstruct it.'}
for name, source in (('population-draft-recurrence', 'review-population-draft.py'),
                     ('corrected', 'review.py')):
    command = ['python3', DIR + source, '--capture-original']
    raw = (ROOT / (DIR + source)).read_bytes()
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    row = {'name': name, 'command': command, 'source_sha256': sha(raw),
           'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode()}
    data['rows'].append(row)
    reached.write_text(json.dumps(data, indent=2) + '\n')
    if name == 'population-draft-recurrence':
        assert result.returncode != 0 and b"assert row['original_sha256'] == sha(original_raw)" in result.stderr
        assert not (ROOT / (DIR + 'original-replay.json')).exists()
        assert not (ROOT / (DIR + 'original-replay-reached.json')).exists()
    else:
        assert result.returncode == 0 and not result.stderr, 'corrected full recovery'
target.write_text(json.dumps(data, indent=2) + '\n')
print('Recovery outer capture PASS: actual draft preflight RED and corrected full original recovery')
