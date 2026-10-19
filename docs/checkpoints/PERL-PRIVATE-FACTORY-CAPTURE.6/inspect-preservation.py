"""Read-only census of accepted live claims intersecting the pipeline owner."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
prior = json.loads((ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/preservation.json').read_bytes())
owned = set(prior['owned_bound_paths'])
owned.update({'perl/LinkedSpec/ActionIR/RewritePipeline.pm',
              'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'})
for path in sorted((ROOT / 'docs/claims').glob('*.json')):
    data = path.read_bytes()
    record = json.loads(data)
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        hits = sorted(owned & {item['path'] for item in durability.get('inputs', [])})
        if durability.get('mode') == 'live' and hits:
            print(path.relative_to(ROOT), index, len(durability['inputs']), len(data), hits)
