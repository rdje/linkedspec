"""One-shot preservation of the constructor claim before MethodLowering default selection writes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '33e57deee73e27b97e9c21116bc70942f3f33772'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


target = ROOT / (PREFIX + 'freeze.json')
before_path = PREFIX + 'before-construction.json'
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
assert len(bindings) == 244
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
target.write_text(json.dumps({
    'revision': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': digest(before), 'after_sha256': digest(after),
    'verified_bindings': len(bindings), 'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only original live durability mode/revision changes. All original proof fields and hashes, including already historical bindings, remain exact. No historical measurement is refreshed.'
}, indent=2) + '\n')
print('Constructor preservation PASS: original244 bindings retained historically')
