"""Check frozen accepted claim bindings before synchronizing both roadmap frontiers."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
path = BASE / 'publication-inputs/inputs-before-query.tar.gz'
sealed = json.loads((BASE / 'sealed-identities.json').read_bytes())
row = sealed[str(path.relative_to(ROOT))]; raw = path.read_bytes()
assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
identities = json.loads((BASE / 'publication-inputs/input-identities.json').read_bytes())
hits, records = [], 0
with tarfile.open(path) as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        raw = archive.extractfile(member).read(); row = identities[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
        if not member.name.startswith('docs/claims/'):
            continue
        records += 1
        for claim in json.loads(raw)['claims']:
            leg = claim['durability']
            if leg['status'] == 'checked':
                hits += [dict(record=member.name, claim=claim['name'], mode=leg['mode'], revision=leg.get('revision'), **item)
                    for item in leg['inputs'] if item['path'] in ('ROADMAP.md', 'ROADMAP_V2.md')]
assert records == 206
(BASE / 'roadmap-bindings.json').write_text(json.dumps(dict(records=records, intersections=hits,
    scope='Frozen accepted claim metadata before current-frontier synchronization; original records/revisions/hashes unchanged.'), indent=2, sort_keys=True) + '\n')
assert all(row['mode'] == 'historical' for row in hits), 'preserve live bindings before editing'
print(json.dumps(dict(records=records, historical_intersections=len(hits), live=0)))
