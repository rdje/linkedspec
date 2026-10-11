"""Preserve accepted dropped-trim proof before small optional-kind writes."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'
PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-publish-claim.py'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
CARD = 'docs/knowledge/perl-method-trim-capture.md'
WRITES = {MODULE, BOOK, CARD, CLAIM, 'docs/knowledge/perl-legacy-hash-kind-callback.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'KNOWLEDGE_MAP.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md', 'ROADMAP.md',
    'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
before_path = PREFIX + 'before-trim.json'
baseline_path = PREFIX + 'baseline.json'
target = PREFIX + 'freeze.json'
assert all(not (ROOT / path).exists() for path in (before_path, baseline_path, target)), 'one-shot preservation'
intersections = []
for path in sorted((ROOT / 'docs/claims').glob('*.json')):
    relative = path.relative_to(ROOT).as_posix()
    for row in json.loads(path.read_bytes())['claims']:
        durability = row['durability']
        if durability.get('mode') != 'live':
            continue
        common = WRITES & {entry['path'] for entry in durability['inputs']}
        if not common:
            continue
        assert path.read_bytes() == old(relative), 'accepted intersecting record'
        for entry in durability['inputs']:
            raw = old(entry['path'])
            assert sha(raw) == entry['sha256'] and (ROOT / entry['path']).read_bytes() == raw
        intersections.append({'claim': relative, 'name': row['name'],
            'bindings': len(durability['inputs']), 'intersections': sorted(common)})
assert intersections == [{'claim': CLAIM, 'name': 'inline-required-dropped-value-trim-isolation',
    'bindings': 339, 'intersections': sorted((MODULE, BOOK, CARD))}]
before = old(CLAIM)
assert (ROOT / CLAIM).read_bytes() == before and len(before) == 78325
actual = subprocess.run(['python3', PUBLISHER], cwd=ROOT, capture_output=True)
baseline = {'producer_sha256': sha(Path(__file__).read_bytes()),
    'command': ['python3', PUBLISHER], 'returncode': actual.returncode,
    'stdout_base64': base64.b64encode(actual.stdout).decode(),
    'stderr_base64': base64.b64encode(actual.stderr).decode()}
(ROOT / baseline_path).write_text(json.dumps(baseline, indent=2) + '\n')
assert actual.returncode == 0 and not actual.stderr and b'PASS' in actual.stdout
changed = copy.deepcopy(json.loads(before))
assert len(changed['claims']) == 1 and changed['claims'][0]['durability']['mode'] == 'live'
changed['claims'][0]['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(changed, indent=2) + '\n').encode()
(ROOT / before_path).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
(ROOT / target).write_text(json.dumps({'base': BASE, 'claim': CLAIM,
    'before': before_path, 'original_sha256': sha(before), 'after_sha256': sha(after),
    'producer_sha256': sha(Path(__file__).read_bytes()), 'planned_writes': sorted(WRITES),
    'intersections': intersections,
    'scope': 'Every339 accepted live binding and full78325-byte original dropped-trim record remains exact. Actual accepted readonly publisher baseline precedes runtime/book/card writes. Only its sole live mode/revision pair becomes historical61cca1ccc; all older historical publications and first native/counterfactual observations remain unchanged.'}, indent=2) + '\n')
print('Small optional-kind preservation PASS: original339/full78325 exact; actual accepted publisher baseline')
