"""One actual original-binding corruption RED and readonly proof review."""
import base64
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1.json'
COMMAND = ['python3', PREFIX + 'review.py']
REASON = 'original claim changed beyond mode/revision'
TARGET = ROOT / (PREFIX + 'preservation-control.json')
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
original = (ROOT / CLAIM).read_bytes()
changed = json.loads(original)
changed['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
mutated = (json.dumps(changed, indent=2) + '\n').encode()
assert mutated != original


def run():
    result = subprocess.run(COMMAND, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    return {'command': COMMAND, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot preservation control already captured'
    try:
        (ROOT / CLAIM).write_bytes(mutated)
        red = run()
    finally:
        (ROOT / CLAIM).write_bytes(original)
    restored = run()
    report = {'producer_sha256': digest(Path(__file__).read_bytes()),
              'reviewer_sha256': digest((ROOT / COMMAND[1]).read_bytes()),
              'claim': CLAIM, 'original_sha256': digest(original),
              'mutated_base64': base64.b64encode(mutated).decode(),
              'reason': REASON, 'red': red, 'restored': restored,
              'unchanged': (ROOT / CLAIM).read_bytes() == original,
              'scope': 'Exactly one original frozen binding is corrupted; actual readonly reviewer rejects it beyond mode/revision. Original claim bytes restore before actual readonly PASS. No historical measurement is refreshed.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
report = json.loads(TARGET.read_bytes())
assert report['producer_sha256'] == digest(Path(__file__).read_bytes())
assert report['reviewer_sha256'] == digest((ROOT / COMMAND[1]).read_bytes())
assert report['claim'] == CLAIM and report['original_sha256'] == digest(original)
assert base64.b64decode(report['mutated_base64'], validate=True) == mutated
assert report['reason'] == REASON and report['unchanged'] is True
assert report['red']['command'] == COMMAND and report['red']['returncode'] != 0
assert REASON.encode() in base64.b64decode(report['red']['stderr_base64'], validate=True)
base64.b64decode(report['red']['stdout_base64'], validate=True)
assert report['restored']['command'] == COMMAND and report['restored']['returncode'] == 0
assert b'original275 preserved' in base64.b64decode(report['restored']['stdout_base64'], validate=True)
assert not base64.b64decode(report['restored']['stderr_base64'], validate=True)
print('Historical preservation control PASS: actual original-binding RED/restored readonly PASS')
