"""Preserve the accepted package-flow publication before inventory documentation edits."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '91e972cfa0d214784b0172828f7baa378c25f23e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0.json'
PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-publish-claim.py'
WRITES = {
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'KNOWLEDGE_MAP.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'MEMORY.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
    'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md',
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0.json',
    'docs/knowledge/perl-method-trim-capture.md',
    'docs/knowledge/perl-method-slot-required-capture.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
before_path = PREFIX + 'before-package-flow.json'
baseline_path = PREFIX + 'baseline.json'
target = PREFIX + 'freeze.json'
assert all(not (ROOT / path).exists() for path in (before_path, baseline_path, target)), 'one-shot preservation'
intersections = []
for path in sorted((ROOT / 'docs/claims').glob('*.json')):
    relative = path.relative_to(ROOT).as_posix()
    record = json.loads(path.read_bytes())
    for row in record['claims']:
        durability = row['durability']
        if durability.get('mode') != 'live':
            continue
        common = WRITES & {entry['path'] for entry in durability['inputs']}
        if not common:
            continue
        assert path.read_bytes() == old(relative), 'accepted intersecting publication'
        for entry in durability['inputs']:
            raw = old(entry['path'])
            assert sha(raw) == entry['sha256'] and (ROOT / entry['path']).read_bytes() == raw
        intersections.append({'claim': relative, 'name': row['name'],
            'bindings': len(durability['inputs']), 'intersections': sorted(common)})
assert intersections == [{'claim': CLAIM, 'name': 'legacy-package-flow-callback-isolation',
    'bindings': 355, 'intersections': ['docs/knowledge/perl-method-slot-required-capture.md',
        'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']}]
before = old(CLAIM)
assert (ROOT / CLAIM).read_bytes() == before and len(before) == 120239
actual = subprocess.run(['python3', PUBLISHER], cwd=ROOT, capture_output=True)
baseline = {'producer_sha256': sha(Path(__file__).read_bytes()), 'command': ['python3', PUBLISHER],
    'returncode': actual.returncode, 'stdout_base64': base64.b64encode(actual.stdout).decode(),
    'stderr_base64': base64.b64encode(actual.stderr).decode()}
(ROOT / baseline_path).write_text(json.dumps(baseline, indent=2) + '\n')
assert actual.returncode == 0 and not actual.stderr and b'PASS' in actual.stdout, 'actual accepted publisher baseline'
value = json.loads(before)
changed = copy.deepcopy(value)
live = [row for row in changed['claims'] if row['durability'].get('mode') == 'live']
assert len(changed['claims']) == 3 and len(live) == 1 and len(live[0]['durability']['inputs']) == 355
live[0]['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(changed, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
(ROOT / target).write_text(json.dumps({'base': BASE, 'claim': CLAIM, 'before': before_path,
    'original_sha256': sha(before), 'after_sha256': sha(after),
    'producer_sha256': sha(Path(__file__).read_bytes()), 'planned_writes': sorted(WRITES),
    'intersections': intersections, 'scope': 'All355 accepted live bindings and full120239-byte three-claim publication remain exact, including both prior historical claims. Only one live mode/revision pair becomes historical at91e972cfa0. Actual accepted publisher baseline precedes bound documentation edits; runtime source and accepted consumers stay unchanged.'}, indent=2) + '\n')
print('Remaining-call inventory preservation PASS: original355/full120239 exact; actual accepted publisher baseline')
