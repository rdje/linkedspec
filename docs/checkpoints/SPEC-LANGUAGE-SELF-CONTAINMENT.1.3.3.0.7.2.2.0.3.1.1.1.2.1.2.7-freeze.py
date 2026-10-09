"""Freeze intersecting original claims without refreshing their measured inputs."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '31fe4fd3655466018a509d894fc6bca3a331944d'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
PREVIOUS = LEAF[:-1] + '6'
PUBLISHER = 'docs/checkpoints/' + PREVIOUS + '-publish.py'
PUBLICATION = {'CHANGES.md', 'DEVELOPMENT_NOTES.md', PUBLISHER}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert ('- ID: `' + LEAF + '`\n  Status: `active`') in (ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md').read_text()
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

(ROOT / (PREFIX + 'before-publisher.py')).write_bytes(blob(PUBLISHER))
report = {'revision': BASE, 'records': records,
          'original_publisher_sha256': digest(blob(PUBLISHER)),
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Only durability mode/revision change; all original statements, proof fields and hashes remain exact.'}
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Frozen', len(records), 'original records;', sum(r['verified_bindings'] for r in records), 'original bindings')
