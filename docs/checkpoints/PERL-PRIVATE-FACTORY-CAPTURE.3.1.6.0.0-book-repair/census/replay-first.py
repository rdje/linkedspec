"""Replay the complete initial book composition from exact recoverable input bytes."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-book-repair/'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
before = json.loads(gzip.decompress((HERE / 'before.json.gz').read_bytes()))
assert before['producer_sha256'] == digest((HERE / 'capture-before.py').read_bytes())
claim_bytes = base64.b64decode(before['claim_base64'], validate=True)
assert digest(claim_bytes) == before['claim_sha256']
claim = json.loads(claim_bytes)
failed = json.loads(gzip.decompress((HERE.parent / 'before.json.gz').read_bytes()))
rows = [r for c in claim['claims'] if c['durability']['mode'] == 'live' for r in c['durability']['inputs']]
assert len(rows) == before['live_declarations'] == 521
inputs = {}
origins = {}
for row in rows:
    path = row['path']
    choices = []
    if path in failed['inputs']:
        choices.append(('failed03', base64.b64decode(failed['inputs'][path]['data'], validate=True)))
    if path in before['mutable_before']:
        choices.append(('initial-composition', base64.b64decode(before['mutable_before'][path], validate=True)))
    choices.append(('unchanged-tracked', (ROOT / path).read_bytes()))
    matches = [(origin, raw) for origin, raw in choices if digest(raw) == row['sha256']]
    assert matches, 'initial live input not recoverable: ' + path
    origin, raw = matches[0]
    assert path not in inputs or inputs[path] == raw
    inputs[path] = raw
    origins[path] = origin
assert len(inputs) == before['unique_inputs'] == 506
commands = [['python3', PREFIX + 'review.py'], ['python3', PREFIX + 'publish-claim.py']]
executions = []
with tempfile.TemporaryDirectory(prefix='copy-first-composition-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path,raw in inputs.items():
        relative = Path(path)
        assert not relative.is_absolute() and '..' not in relative.parts
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        target.chmod((ROOT / path).stat().st_mode & 0o777)
    claim_path = 'docs/claims/' + LEAF + '.json'
    (supplied / claim_path).write_bytes(claim_bytes)
    git_dir = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT).decode().strip()
    environment = dict(os.environ, GIT_DIR=git_dir, GIT_WORK_TREE=str(supplied), PYTHONDONTWRITEBYTECODE='1')
    for command in commands:
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        executions.append({'command': command, 'returncode': result.returncode,
                           'stdout_base64': base64.b64encode(result.stdout).decode(),
                           'stderr_base64': base64.b64encode(result.stderr).decode()})
        assert result.returncode == 0, (command, result.stderr.decode())
    assert all((supplied / p).read_bytes() == raw for p,raw in inputs.items())
    assert (supplied / claim_path).read_bytes() == claim_bytes
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'claim_sha256': digest(claim_bytes), 'live_declarations': len(rows), 'unique_inputs': len(inputs),
          'origins': origins, 'executions': executions, 'unchanged': True,
          'scope': 'Fresh actual initial book-composition review and publisher against every original521 declaration/506 distinct input and original124837-byte claim. Recovery uses retained failed03 bytes, explicitly retained mutable pre-census sources and unchanged tracked artifact bytes, each required to match its original SHA. Current census/source admission is separately verified; no original capture refreshed.'}
target = HERE / 'replay-first.json'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot initial composition replay'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'initial composition replay drift'
print('Initial book composition replay PASS: 521 bindings/506 files; actual original review/publication; unchanged bytes')
