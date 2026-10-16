"""Preserve every intersecting live claim from the fixed accepted Git namespace."""
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd432a955ca7a976ccbc3fa047f97bc5e3103ea76'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.17-'
PUBLICATION = {'docs/ARTIFACT_CLEANUP.md', 'docs/tasks/REPO-HYGIENE.md',
               'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'docs/TASK_TREE.md',
               'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'CHANGES.md',
               'ROADMAP.md', 'ROADMAP_V2.md'}
sha = lambda value: hashlib.sha256(value).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
TARGET = ROOT / (PREFIX + 'freeze.json')
assert not TARGET.exists()
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                cwd=ROOT, text=True).splitlines()
census, records, writes = [], [], []
for path in sorted(paths):
    payload = old(path)
    assert (ROOT / path).read_bytes() == payload
    original = json.loads(payload)
    current = copy.deepcopy(original)
    hits, bindings = [], 0
    for index, claim in enumerate(original['claims']):
        d = claim['durability']
        if d.get('mode') != 'live' or not PUBLICATION & {x['path'] for x in d['inputs']}:
            continue
        for item in d['inputs']:
            assert sha(old(item['path'])) == item['sha256'] == sha((ROOT / item['path']).read_bytes())
            bindings += 1
        current['claims'][index]['durability'].update(mode='historical', revision=BASE)
        hits.append(index)
    census.append({'path': path, 'sha256': sha(payload), 'intersections': hits})
    if hits:
        before = PREFIX + 'before-' + Path(path).name
        with (ROOT / before).open('xb') as output:
            output.write(payload)
        after = (json.dumps(current, indent=2) + '\n').encode()
        records.append({'path': path, 'before': before, 'original_sha256': sha(payload),
                        'after_sha256': sha(after), 'verified_bindings': bindings})
        writes.append((path, after))
assert not records, 'planned metadata-only writes must leave all current callback inputs unchanged'
for path, value in writes:
    (ROOT / path).write_bytes(value)
report = {'revision': BASE, 'records': records, 'original_claim_census': census,
          'publication_paths': sorted(PUBLICATION), 'producer_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Fixed accepted claim namespace; zero original live intersections. Existing callback claim '
                   'and all456 input bindings remain unchanged. No original observation is refreshed.'}
with TARGET.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Fixed accepted claim census PASS; original live intersections:', len(records))
