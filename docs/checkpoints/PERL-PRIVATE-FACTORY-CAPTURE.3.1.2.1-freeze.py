"""One-shot preserve the inline claim before block dependency input writes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '65bd00faa0b10abc106a6da2283391c268ee88fa'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


target = ROOT / (PREFIX + 'freeze.json')
before_path = PREFIX + 'before-inline.json'
assert not target.exists() and not (ROOT / before_path).exists(), 'one-shot preservation already published'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
before = blob(CLAIM)
assert (ROOT / CLAIM).read_bytes() == before, 'original claim already changed'
record = json.loads(before)
bindings = []
for claim in record['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        bindings.extend(durability['inputs'])
        for entry in durability['inputs']:
            original = blob(entry['path'])
            assert digest(original) == entry['sha256'], 'original Git binding: ' + entry['path']
            assert (ROOT / entry['path']).read_bytes() == original, 'preservation must precede input writes'
        durability.update(mode='historical', revision=BASE)
assert len(bindings) == 242
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
target.write_text(json.dumps({'revision': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': digest(before), 'after_sha256': digest(after), 'verified_bindings': len(bindings),
    'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only original live durability mode/revision changes. Every original proof field/hash and already historical binding stays exact; no historical measurement is refreshed.'}, indent=2) + '\n')
print('Inline preservation PASS: original242 bindings retained historically')
