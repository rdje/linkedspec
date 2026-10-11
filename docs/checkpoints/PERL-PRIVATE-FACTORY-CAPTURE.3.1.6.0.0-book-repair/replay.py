"""Replay original readonly proof using only the retained failed-candidate inputs."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
packed = (HERE / 'before.json.gz').read_bytes()
index = json.loads((HERE / 'before-index.json').read_bytes())
raw = gzip.decompress(packed)
assert digest(packed) == index['sha256'] and digest(raw) == index['uncompressed_sha256']
assert len(raw) == index['uncompressed_bytes']
packet = json.loads(raw)
assert packet['producer_sha256'] == digest((HERE / 'capture-before.py').read_bytes())
assert packet['tool_reported_exit_code'] == 1
assert packet['fingerprint'] == index['fingerprint']
patch = base64.b64decode(packet['candidate_patch']['data'], validate=True)
assert digest(patch) == packet['candidate_patch']['sha256']
assert len(patch) == packet['candidate_patch']['bytes']
assert packet['fingerprint'] == packet['base_head'] + ' ' + digest(patch)
for channel in packet['channels'].values():
    body = base64.b64decode(channel['data'], validate=True)
    assert digest(body) == channel['sha256'] and len(body) == channel['bytes']
assert b'without explicit removed/rejected/migrated historical context' in base64.b64decode(packet['channels']['stderr.log']['data'])
claim = base64.b64decode(packet['claim']['data'], validate=True)
assert digest(claim) == packet['claim']['sha256']
declarations = [row for c in json.loads(claim)['claims'] if c['durability']['mode'] == 'live'
                for row in c['durability']['inputs']]
assert len(declarations) == packet['live_declarations'] == 502
assert {r['path']: r['sha256'] for r in declarations} == {p: r['sha256'] for p, r in packet['inputs'].items()}
assert len(packet['inputs']) == packet['unique_live_inputs'] == 487
commands = [
    ['python3', PREFIX + 'final-review.py'],
    ['python3', PREFIX + 'canonical/publish-claim.py'],
    ['python3', PREFIX + 'publish-claim.py'],
]
rows = []
with tempfile.TemporaryDirectory(prefix='copy-original-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    expected = {}
    for path, row in packet['inputs'].items():
        p = Path(path)
        assert not p.is_absolute() and '..' not in p.parts
        body = base64.b64decode(row['data'], validate=True)
        assert digest(body) == row['sha256'] and len(body) == row['bytes']
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)
        target.chmod(row['mode'])
        expected[path] = digest(body)
    target = supplied / packet['claim']['path']
    target.write_bytes(claim)
    expected[packet['claim']['path']] = digest(claim)
    # Reuse this repository's object database/index strictly for original Git
    # blobs and tracked-path discovery. No separate checkout/repository is amended.
    git_dir = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT).decode().strip()
    environment = dict(os.environ, GIT_DIR=git_dir, GIT_WORK_TREE=str(supplied),
                       PYTHONDONTWRITEBYTECODE='1')
    for command in commands:
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        rows.append({'command': command, 'returncode': result.returncode,
                     'stdout_base64': base64.b64encode(result.stdout).decode(),
                     'stderr_base64': base64.b64encode(result.stderr).decode()})
        assert result.returncode == 0, (command, result.stderr.decode())
    assert all(digest((supplied / p).read_bytes()) == h for p, h in expected.items()), 'readonly replay altered supplied bytes'
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'snapshot_sha256': digest(packed), 'live_declarations': len(declarations),
          'unique_live_inputs': len(packet['inputs']), 'rows': rows, 'unchanged': True,
          'scope': 'Fresh original readonly final review and both original publications against every retained failed03 live input and original claim. Original instruments/observations unchanged. Current runtime/CI source equality and corrected book are separately checked; no successful canonical admission is inferred.'}
target = HERE / 'replay.json'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot replay capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'original replay drift'
print('Original proof replay PASS: 502 bindings/487 files; final review and both publications; supplied bytes unchanged')
