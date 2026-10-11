"""One-shot late census extension; retain every original observation unchanged."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
BASE = '6392b8a6512a639265d150acb11b0e9a8451ea3d'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert not (ROOT / (PREFIX + 'census-repair.json')).exists(), 'one-shot repair'
draft = read(PREFIX + 'draft-plan.json')
assert read(PREFIX + 'plan.json') == draft, 'original draft still exact'
plan = json.loads(draft)
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--',
    'docs/history/development-notes', 'docs/history/changes', 'docs/decisions'], cwd=ROOT).decode().splitlines()
paths = sorted(p for p in paths if p not in ('docs/decisions/INDEX.md', 'docs/history/changes/manifest.jsonl'))
assert len(paths) == len(set(paths)) == 226
assert len(plan['preserved']) == 180 and set(plan['preserved']) < set(paths)
added = {p: sha(old(p)) for p in paths if p not in plan['preserved']}
assert len(added) == 46 and all(p.startswith('docs/history/development-notes/') for p in added)
for path in paths:
    assert read(path) == old(path), 'accepted original remains unchanged: ' + path
    if path in plan['preserved']:
        assert plan['preserved'][path] == sha(old(path))
plan['preserved'] = {p: sha(old(p)) for p in paths}
plan['reviewer_sha256'] = sha(read(PREFIX + 'capacity.py'))
raw = (json.dumps(plan, indent=2) + '\n').encode()
(ROOT / (PREFIX + 'plan.json')).write_bytes(raw)
tails = ['capacity.py', 'plan.json', 'controls.json', 'evidence.json', 'evidence-reached.json',
         'preservation-controls.json', 'preservation-reached.json']
report = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'drafts': {PREFIX + 'draft-' + tail: sha(read(PREFIX + 'draft-' + tail)) for tail in tails},
          'added': added, 'plan_sha256': sha(raw),
          'scope': 'Original applied producer omitted46 engineering-history files through a duplicate directory. '
              'All180 original identities and actual reached observations remain exact in draft artifacts. '
              'This late extension verifies all46 added files against accepted Git/current bytes and changes only '
              'the preservation census plus corrected reviewer identity. Original apply/rollover/pressure/control '
              'channels are never refreshed. Fresh current reviewer and preservation captures follow separately.'}
(ROOT / (PREFIX + 'census-repair.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Census repair PASS: original180 retained;46 exact unchanged Git inputs added; complete226')
