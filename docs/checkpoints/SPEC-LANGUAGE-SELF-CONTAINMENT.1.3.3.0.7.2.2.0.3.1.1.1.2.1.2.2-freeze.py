"""Preserve original measured claims before changing their live input surfaces."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '3dbe7b10a8b6cbe1f6ea92afcb235cc1a71cd59e'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
PUBLICATION = {'perl/LinkedSpec/ActionIR/SourceEmissions.pm',
               'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
               'docs/knowledge/perl-private-input-authority-selection.md',
               'docs/knowledge/perl-private-emission-foundation.md',
               'docs/knowledge/perl-private-method-input-captures.md',
               'docs/knowledge/perl-private-ast-input-frames.md',
               'CHANGES.md', 'DEVELOPMENT_NOTES.md'}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert not (ROOT / (PREFIX + 'freeze.json')).exists(), 'one-shot preservation; use the retained before records'
records = []
for path in subprocess.check_output(['git', 'ls-files', 'docs/claims'], cwd=ROOT, text=True).splitlines():
    original = blob(path)
    record = json.loads(original)
    count = 0
    for claim in record['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live' or not any(entry['path'] in PUBLICATION for entry in durability['inputs']):
            continue
        for entry in durability['inputs']:
            assert digest(blob(entry['path'])) == entry['sha256'], entry['path']
            count += 1
        durability.update(mode='historical', revision=BASE)
    if not count:
        continue
    assert (ROOT / path).read_bytes() == original, path
    snapshot = PREFIX + 'before-' + Path(path).name
    (ROOT / snapshot).write_bytes(original)
    (ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
    records.append({'path': path, 'before': snapshot, 'original_sha256': digest(original),
                    'after_sha256': digest((ROOT / path).read_bytes()), 'verified_bindings': count})
report = {'revision': BASE, 'records': records, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Only durability mode/revision change; original statements, proof fields and all input hashes remain exact.'}
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Preserved', len(records), 'original claims and', sum(r['verified_bindings'] for r in records), 'original input bindings')
