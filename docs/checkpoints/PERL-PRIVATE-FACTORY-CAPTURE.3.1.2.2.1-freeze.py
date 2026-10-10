"""One-shot preserve the accepted local-return boundary before block-value writes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de3b50dd06d4aff6babf379282f90368810d49e5'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


target = ROOT / (PREFIX + 'freeze.json')
before_path = PREFIX + 'before-local-return.json'
assert not target.exists() and not (ROOT / before_path).exists(), 'one-shot preservation already published'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
before = blob(CLAIM)
assert (ROOT / CLAIM).read_bytes() == before, 'original claim already changed'
record = json.loads(before)
bindings, names = [], []
for claim in record['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        names.append(claim['name'])
        bindings.extend(durability['inputs'])
        for entry in durability['inputs']:
            original = blob(entry['path'])
            assert digest(original) == entry['sha256'], 'original Git binding: ' + entry['path']
            assert (ROOT / entry['path']).read_bytes() == original, 'preservation must precede input writes'
        durability.update(mode='historical', revision=BASE)
assert names == ['method-required-local-return-isolation']
assert len(bindings) == 273
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
target.write_text(json.dumps({'revision': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': digest(before), 'after_sha256': digest(after),
    'verified_bindings': len(bindings), 'live_claims': names,
    'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only the one original live durability mode/revision fields change. All273 original Git-bound inputs, every proof/hash field and the already historical claim remain exact. No prior local-return runtime or book observation is refreshed.'}, indent=2) + '\n')
print('Local-return preservation PASS: original273 bindings retained historically')
