"""Preserve intersecting claims at their actual immutable activation revision."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '476bbd1f916edb4c6593bad3c5a8381447c211b6'
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
PUBLICATION = {'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md',
               'LIVE_ACHIEVEMENT_STATUS.md', 'docs/TASK_TREE.md',
               'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md',
               'docs/knowledge/perl-private-method-argument-authority.md'}

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
records = []
for path in subprocess.check_output(['git', 'ls-files', 'docs/claims'], cwd=ROOT, text=True).splitlines():
    original = blob(path)
    record = json.loads(original)
    changed = False
    count = 0
    for claim in record['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live' or not any(entry['path'] in PUBLICATION for entry in durability['inputs']):
            continue
        for entry in durability['inputs']:
            assert digest(blob(entry['path'])) == entry['sha256'], entry['path']
            count += 1
        durability.update(mode='historical', revision=BASE)
        changed = True
    if not changed:
        continue
    current = (ROOT / path).read_bytes()
    assert json.loads(current) in (json.loads(original), record), path
    snapshot = PREFIX + 'before-' + Path(path).name
    (ROOT / snapshot).write_bytes(original)
    (ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
    records.append({'path': path, 'before': snapshot, 'original_sha256': digest(original),
                    'after_sha256': digest((ROOT / path).read_bytes()), 'verified_bindings': count})
report = {'revision': BASE, 'records': records,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Only durability mode/revision change; original claim statements and hashes are preserved.'}
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Frozen intersecting claims:', len(records), '; original bindings:', sum(r['verified_bindings'] for r in records))
