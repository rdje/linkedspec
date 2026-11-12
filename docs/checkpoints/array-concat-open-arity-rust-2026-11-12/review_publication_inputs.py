"""Independent frozen-claim publication query and distinguishing live-binding controls."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-concat-open-arity-rust-2026-11-12')
OUT = BASE / 'publication-inputs'
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'


def intersections(records, targets):
    result = []
    for path, record in records.items():
        for claim in record['claims']:
            leg = claim['durability']
            if leg['status'] == 'checked':
                result += [dict(record=path, claim=claim['name'], path=row['path'], mode=leg['mode'],
                    revision=leg.get('revision'), sha256=row['sha256']) for row in leg['inputs'] if row['path'] in targets]
    return result


def safe(rows):
    assert all(row['mode'] != 'live' for row in rows)


rows = json.loads((ROOT / OUT / 'input-identities.json').read_bytes())
inputs = {}
with tarfile.open(ROOT / OUT / 'inputs-before-query.tar.gz') as archive:
    for member in archive:
        assert member.isfile() and member.name not in inputs
        raw = archive.extractfile(member).read(); row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
        inputs[member.name] = raw
assert inputs.keys() == rows.keys()
producer = str(BASE / 'check_publication_inputs.py')
assert inputs[producer] == (ROOT / producer).read_bytes()
names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ACTIVATION, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
names = sorted(name for name in names if name.count('/') == 2 and name.endswith('.json'))
assert names == sorted(name for name in inputs if name.startswith('docs/claims/'))
records = {}
for name in names:
    assert inputs[name] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
    records[name] = json.loads(inputs[name])
actual = json.loads((ROOT / OUT / 'result.json').read_bytes())
assert actual['source_commit'] == ACTIVATION and actual['claim_records'] == len(names)
hits = intersections(records, set(actual['prospective_paths']))
assert hits == actual['checked_intersections'] and actual['live_intersections'] == []
safe(hits)
controls = []
for target in actual['prospective_paths']:
    selected = next((row for row in hits if row['path'] == target), None)
    if selected is None:
        continue
    altered = copy.deepcopy(hits)
    index = hits.index(selected); altered[index]['mode'] = 'live'
    assert hits[index]['mode'] == 'historical'
    try:
        safe(altered)
    except AssertionError:
        controls.append(target)
    else:
        raise AssertionError('ineffective live-binding control')
assert controls
print(json.dumps(dict(publication_input_query='PASS', accepted_records=len(names), historical_intersections=len(hits),
    live_intersections=0, rejected_live_binding_controls=controls,
    scope='Frozen accepted claim metadata only; no original claim/hash/revision change or runtime replay.'), indent=2))
