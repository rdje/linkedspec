"""Check all live bindings before extending the same-cause guard repair."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
paths = {'perl/LinkedSpec/ActionIR/FlowExpr.pm', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'}
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'additional-census.json')
assert not target.exists()
rows, selected = [], []
for source in sorted((ROOT / 'docs/claims').glob('*.json')):
    payload = source.read_bytes()
    record = json.loads(payload)
    hits = []
    for index, claim in enumerate(record['claims']):
        d = claim['durability']
        if d.get('mode') == 'live':
            overlap = sorted(paths & {x['path'] for x in d['inputs']})
            if overlap:
                hits.append(dict(claim_index=index, paths=overlap))
    path = source.relative_to(ROOT).as_posix()
    rows.append(dict(path=path, sha256=sha(payload), live_intersections=hits))
    if hits:
        selected.append(path)
        assert path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
        assert payload == (ROOT / (PREFIX + 'initial-claim.json')).read_bytes()
assert selected == ['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json']
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
    paths=sorted(paths), census=rows, selected=selected,
    scope='Complete current registered claim namespace, including the uncommitted initial draft. Only that fully preserved draft has live bindings to the two additional repair owners. No other claim is relabeled or refreshed; no fake revision is introduced.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Additional default-owner live census PASS:only the complete preserved initial draft is affected')
