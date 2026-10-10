"""One-shot preserve the accepted AST-call boundary before finite change-history writes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '9085eb1e5075146ca00dab52304f85937cf7ea05'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


target = ROOT / (PREFIX + 'freeze.json')
before_path = PREFIX + 'before-ast-call.json'
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
assert names == ['method-required-ast-call-isolation']
assert len(bindings) == 279
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
target.write_text(json.dumps({'revision': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': digest(before), 'after_sha256': digest(after),
    'verified_bindings': len(bindings), 'live_claims': names,
    'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only the one original live durability mode/revision fields change. All279 original Git-bound inputs, every proof/hash field and the already historical claim remain exact. No prior AST-call runtime or book observation is refreshed.'}, indent=2) + '\n')
print('AST-call preservation PASS: original279 bindings retained historically')
