"""Preserve accepted scalar callback evidence before finite history admission writes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd8418423e7461235280e9a34b9d90f4571fc9490'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


target = ROOT / (PREFIX + 'freeze.json')
before_path = PREFIX + 'before-scalar.json'
assert not target.exists() and not (ROOT / before_path).exists(), 'one-shot preservation already published'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
before = blob(CLAIM)
assert (ROOT / CLAIM).read_bytes() == before, 'original claim already changed'
record = json.loads(before)
bindings, names = [], []
for claim in record['claims']:
    durability = claim['durability']
    if durability.get('mode') != 'live':
        continue
    names.append(claim['name'])
    bindings.extend(durability['inputs'])
    for entry in durability['inputs']:
        original = blob(entry['path'])
        assert digest(original) == entry['sha256'], 'original Git binding: ' + entry['path']
        assert (ROOT / entry['path']).read_bytes() == original, 'preservation must precede input writes: ' + entry['path']
    durability.update(mode='historical', revision=BASE)
assert names == ['scalar-required-callback-isolation']
assert len(bindings) == 337 and len({entry['path'] for entry in bindings}) == 337
assert target.parent.stat().st_dev == ROOT.stat().st_dev
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
target.write_text(json.dumps({'revision': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': digest(before), 'after_sha256': digest(after),
    'verified_bindings': len(bindings), 'live_claims': names,
    'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only original live durability mode/revision changes. All337 accepted inputs and every original proof/hash field remain recoverable at the accepted Git revision. Earlier historical array-boundary preservation is unchanged. No runtime, CI or book observation is refreshed.'}, indent=2) + '\n')
print('Accepted scalar callback preservation PASS: original337 bindings retained historically')
