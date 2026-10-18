"""One-shot live-binding census before the foundation retrieval-card update."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '2b35b77ea0e08d178ccb054a8f8310dbe0abb9c1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
CARD = 'docs/knowledge/perl-private-emission-foundation.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'foundation-census.json')
assert not target.exists(), 'one-shot pre-write census'
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                cwd=ROOT, text=True).splitlines()
assert sorted(paths) == sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/claims').glob('*.json'))
assert (ROOT / CARD).read_bytes() == subprocess.check_output(['git', 'show', BASE + ':' + CARD], cwd=ROOT)
rows = []
for path in sorted(paths):
    raw = (ROOT / path).read_bytes()
    value = json.loads(raw)
    hits = [i for i, c in enumerate(value['claims']) if c['durability'].get('mode') == 'live'
            and CARD in {x['path'] for x in c['durability'].get('inputs', [])}]
    rows.append({'path': path, 'sha256': sha(raw), 'live_intersections': hits})
assert not any(x['live_intersections'] for x in rows), 'preserve any intersecting live publication before card writes'
report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'card': CARD, 'original_card_sha256': sha((ROOT / CARD).read_bytes()), 'census': rows,
          'scope': 'Fixed accepted claim namespace, current durability modes after the separately preserved .5.5 publication. No live declared binding names this additional card. Its original complete body remains in accepted Git; the complete original/current Knowledge capture will retain its metadata update. No claim record or old observation changes here.'}
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Foundation pre-write census PASS: no additional live claim intersection')
