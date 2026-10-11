"""One-shot preservation and actual diagnosis before documentation-pointer writes."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'd95a25c8b5904bfbc893aee5249dbaf278496eb3'
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-'
WRITES = {
    'docs/decisions/0133-finite-engineering-notes-member.md',
    'docs/knowledge/finite-engineering-notes-member-0131.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'KNOWLEDGE_MAP.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md',
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def run(args):
    result = subprocess.run(args, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return {'command': args, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
assert not (ROOT / (DIR + 'freeze.json')).exists()
assert not (ROOT / (DIR + 'diagnosis.json')).exists()
selected = []
for path in sorted((ROOT / 'docs/claims').glob('*.json')):
    relative = path.relative_to(ROOT).as_posix()
    raw = path.read_bytes()
    record = json.loads(raw)
    names, bindings, intersections = [], [], set()
    for claim in record['claims']:
        durability = claim['durability']
        common = WRITES & {entry['path'] for entry in durability.get('inputs', [])}
        if durability.get('mode') != 'live' or not common:
            continue
        names.append(claim['name'])
        intersections.update(common)
        for entry in durability['inputs']:
            original = old(entry['path'])
            assert sha(original) == entry['sha256'], 'accepted Git binding: ' + entry['path']
            assert read(entry['path']) == original, 'preservation precedes writes: ' + entry['path']
            bindings.append(entry)
        durability.update(mode='historical', revision=BASE)
    if names:
        assert raw == old(relative), 'accepted full claim'
        before = DIR + 'before-' + path.name
        assert not (ROOT / before).exists()
        selected.append({'claim': relative, 'before': before, 'names': names,
                         'bindings': len(bindings), 'intersections': sorted(intersections),
                         'original_sha256': sha(raw),
                         'after_sha256': sha((json.dumps(record, indent=2) + '\n').encode()),
                         '_raw': raw, '_after': (json.dumps(record, indent=2) + '\n').encode()})
assert [(row['claim'], row['bindings']) for row in selected] == [
    ('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json', 377)]
diagnosis = {
    'producer_sha256': sha(Path(__file__).read_bytes()), 'base': BASE,
    'stale': run(['python3', PREFIX + 'capacity.py', 'review']),
    'guarded': run(['python3', OLD + 'publish.py']),
    'scope': 'Actual current-input command channels before any bound write. The old instrument requires its original logical draft; the accepted guarded publisher handles the corrected root. No historical observation is refreshed.',
}
(ROOT / (DIR + 'diagnosis.json')).write_text(json.dumps(diagnosis, indent=2) + '\n')
assert diagnosis['stale']['returncode'] != 0
assert b'complete current root reconstruction' in base64.b64decode(diagnosis['stale']['stderr_base64'])
assert diagnosis['guarded']['returncode'] == 0 and not base64.b64decode(diagnosis['guarded']['stderr_base64'])
for row in selected:
    (ROOT / row['before']).write_bytes(row.pop('_raw'))
    (ROOT / row['claim']).write_bytes(row.pop('_after'))
report = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'planned_writes': sorted(WRITES), 'records': selected,
          'scope': 'Every intersecting live record is preserved before bound writes; only live durability mode/revision changes. Exact original full claims and all input hashes remain recoverable at accepted Git. Other historical claims, producers and observations remain unchanged.'}
(ROOT / (DIR + 'freeze.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Preservation PASS: all live intersections; accepted377 bindings and exact claim retained; stale RED/guarded GREEN actual channels')
