"""Independently recover accepted bindings and reject injected live bindings."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'index-publication-inputs'
report = json.loads((OUT / 'result.json').read_bytes())
identities = json.loads((OUT / 'input-identities.json').read_bytes())
bodies = {}
with tarfile.open(OUT / 'inputs-before-query.tar.gz') as archive:
    assert len(archive.getnames()) == len(identities) and set(archive.getnames()) == identities.keys()
    for member in archive:
        body = archive.extractfile(member).read()
        row = identities[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
        bodies[member.name] = body
names = [name for name in subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', report['source_commit'], 'docs/claims'], text=True).splitlines() if name.endswith('.json')]
assert set(names) == {name for name in bodies if name.startswith('docs/claims/')}
records = {}
for name in names:
    assert bodies[name] == subprocess.check_output(['git', 'show', report['source_commit'] + ':' + name])
    records[name] = json.loads(bodies[name])


def inspect(source):
    hits = []
    for name, record in source.items():
        for claim in record['claims']:
            durability = claim['durability']
            if durability['status'] == 'checked':
                for item in durability['inputs']:
                    if item['path'] in report['prospective_paths']:
                        assert durability['mode'] != 'live', 'live publication binding'
                        hits.append(dict(record=name, claim=claim['name'], path=item['path'], mode=durability['mode'],
                            revision=durability.get('revision'), sha256=item['sha256']))
    return hits


assert len(records) == report['claim_records']
assert inspect(records) == report['checked_intersections'] and report['live_intersections'] == []
controls = []
for target in report['prospective_paths']:
    matches = [row for row in report['checked_intersections'] if row['path'] == target]
    if not matches:
        continue
    match = matches[0]
    changed = copy.deepcopy(records)
    claim = next(row for row in changed[match['record']]['claims'] if row['name'] == match['claim'])
    assert claim['durability']['mode'] == 'historical', 'mutation precondition'
    claim['durability']['mode'] = 'live'
    try:
        inspect(changed)
    except AssertionError as failure:
        assert str(failure) == 'live publication binding'
    else:
        raise AssertionError('injected live binding accepted')
    controls.append(target)
print(json.dumps(dict(claim_records=len(records), historical_intersections=len(report['checked_intersections']),
    live_intersections=0, rejected_live_binding_controls=controls)))
