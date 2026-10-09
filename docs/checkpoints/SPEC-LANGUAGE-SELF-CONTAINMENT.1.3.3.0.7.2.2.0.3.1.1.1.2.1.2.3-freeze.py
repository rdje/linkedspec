"""One-shot preservation of the original input-join measurement boundary."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4f0499d2634e9c04e6a3d07ee85f4159f5380834'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
OLD = 'docs/claims/' + LEAF[:-1] + '2.json'
PUBLICATION = {'docs/knowledge/perl-original-event-input-grants.md',
               'docs/knowledge/perl-private-input-authority-selection.md',
               'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert not (ROOT / (PREFIX + 'freeze.json')).exists(), 'one-shot preservation already published'
prepared = []
for path in subprocess.check_output(['git', 'ls-files', 'docs/claims'], cwd=ROOT, text=True).splitlines():
    original = (ROOT / path).read_bytes()
    record = json.loads(original)
    count = 0
    for claim in record['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live' or not any(e['path'] in PUBLICATION for e in durability['inputs']):
            continue
        assert original == blob(path), 'original claim already changed'
        for entry in durability['inputs']:
            assert digest(blob(entry['path'])) == entry['sha256'], entry['path']
            count += 1
        durability.update(mode='historical', revision=BASE)
    if count:
        snapshot = PREFIX + 'before-' + Path(path).name
        assert not (ROOT / snapshot).exists()
        prepared.append((path, original, record, snapshot, count))
assert [(p, n) for p, _, _, _, n in prepared] == [(OLD, 287)]
records = []
for path, original, record, snapshot, count in prepared:
    (ROOT / snapshot).write_bytes(original)
    (ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
    records.append({'path': path, 'before': snapshot, 'original_sha256': digest(original),
                    'after_sha256': digest((ROOT / path).read_bytes()), 'verified_bindings': count})
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps({
    'revision': BASE, 'records': records, 'producer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only original live durability mode/revision changes. All original statements/proof fields/hashes and the separately historical original-recovery claim remain exact.'}, indent=2) + '\n')
print('Preserved original input-join claim: 287 bindings at', BASE)
