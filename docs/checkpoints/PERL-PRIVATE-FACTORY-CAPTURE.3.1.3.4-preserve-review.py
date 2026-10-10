"""Readonly exact279-input AST-call preservation; --capture records first review once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '9085eb1e5075146ca00dab52304f85937cf7ea05'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1.json'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


freeze = json.loads(read(PREFIX + 'freeze.json'))
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 279
assert freeze['producer_sha256'] == digest(read(PREFIX + 'freeze.py'))
before = read(freeze['before'])
assert before == blob(CLAIM) and digest(before) == freeze['original_sha256']
expected = json.loads(before)
names, inputs = [], []
for claim in expected['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        names.append(claim['name'])
        inputs.extend(durability['inputs'])
        durability.update(mode='historical', revision=BASE)
assert names == freeze['live_claims'] == ['method-required-ast-call-isolation']
assert len(inputs) == 279
for entry in inputs:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim Git input identity'
current = read(CLAIM)
assert json.loads(current) == expected, 'original claim changed beyond mode/revision'
assert digest(current) == freeze['after_sha256']
report = {'result': 'PASS', 'revision': BASE, 'historical_bindings_preserved': len(inputs),
          'producer_sha256': digest(Path(__file__).read_bytes()), 'checked': dict(sorted(checked.items())),
          'scope': 'All279 original AST-call Git input bindings and every proof/hash field remain exact. Only one live durability mode/revision changes; the already historical hash-key preservation claim stays unchanged. No AST-call runtime or book measurement is refreshed.'}
target = ROOT / (PREFIX + 'preserve-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot preservation review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('AST-call preservation review PASS; original279 preserved with mode/revision-only change')
