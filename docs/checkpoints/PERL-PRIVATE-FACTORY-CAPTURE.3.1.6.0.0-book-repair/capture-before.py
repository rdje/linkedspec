"""Retain failed attempt03 and every live input before the book-only repair."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
CLAIM = 'docs/claims/' + LEAF + '.json'
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
BASE = '2b4e484a9bf27471d23d86f72aa25c7616b2bd3b'
EXPECTED_DIFF = '52f2aaa8933cbd9adaafcd09fb3b17769e817bf660083f13d54977e3de62cee6'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert not (HERE / 'before.json.gz').exists(), 'one-shot failed candidate capture'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
patch = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff', 'HEAD'], cwd=ROOT)
assert digest(patch) == EXPECTED_DIFF, 'failed staged candidate changed'
claim = (ROOT / CLAIM).read_bytes()
rows = [row for c in json.loads(claim)['claims'] if c['durability']['mode'] == 'live'
        for row in c['durability']['inputs']]
inputs = {}
for row in rows:
    path = row['path']
    p = Path(path)
    assert not p.is_absolute() and '..' not in p.parts and not (ROOT / p).is_symlink()
    raw = (ROOT / p).read_bytes()
    assert digest(raw) == row['sha256'], 'original live binding drift: ' + path
    entry = {'sha256': digest(raw), 'bytes': len(raw),
             'mode': (ROOT / p).stat().st_mode & 0o777,
             'data': base64.b64encode(raw).decode()}
    assert path not in inputs or inputs[path] == entry
    inputs[path] = entry
assert (ROOT / BOOK).read_bytes() == subprocess.check_output(['git', 'show', BASE + ':' + BOOK], cwd=ROOT)
channels = {}
for name in ('stdout.log', 'stderr.log'):
    raw = (ROOT / '.linkedspec-data/verification' / LEAF / 'attempt-03' / name).read_bytes()
    channels[name] = {'sha256': digest(raw), 'bytes': len(raw), 'data': base64.b64encode(raw).decode()}
assert b'without explicit removed/rejected/migrated historical context' in base64.b64decode(channels['stderr.log']['data'])
packet = {'version': 1, 'base_head': BASE, 'fingerprint': BASE + ' ' + EXPECTED_DIFF,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'tool_reported_exit_code': 1,
          'exit_provenance': 'Transcribed actual terminal completion of session71622, not an original transport envelope.',
          'candidate_patch': {'sha256': digest(patch), 'bytes': len(patch), 'data': base64.b64encode(patch).decode()},
          'claim': {'path': CLAIM, 'sha256': digest(claim), 'data': base64.b64encode(claim).decode()},
          'inputs': inputs, 'live_declarations': len(rows), 'unique_live_inputs': len(inputs),
          'channels': channels,
          'scope': 'Complete failed staged binary diff, redirected channels and all live claim input bytes/modes. Book passage equals activation HEAD. No successful canonical receipt or external toolchain/OS input recovery is claimed.'}
raw = (json.dumps(packet, indent=2) + '\n').encode()
packed = gzip.compress(raw, mtime=0)
(HERE / 'before.json.gz').write_bytes(packed)
(HERE / 'before-index.json').write_text(json.dumps({
    'encoding': 'gzip-json', 'sha256': digest(packed), 'uncompressed_sha256': digest(raw),
    'uncompressed_bytes': len(raw), 'producer_sha256': packet['producer_sha256'],
    'fingerprint': packet['fingerprint'], 'live_declarations': len(rows),
    'unique_live_inputs': len(inputs), 'result': 'retained failed attempt03'}, indent=2) + '\n')
print('Failed attempt03 retained:', len(rows), 'live declarations;', len(inputs), 'unique inputs;', len(packed), 'compressed bytes')
