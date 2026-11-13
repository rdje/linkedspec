"""Check additional storage-registry bindings before the focused test is admitted."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OUT = BASE / 'storage-inputs'
OUT.mkdir()
targets = ['doctrine/project_data_storage/python_entrypoints.json', 'doctrine/project_data_storage/python_temporary_owners.json']
source = BASE / 'publication-inputs'
with tarfile.open(source / 'inputs-before-query.tar.gz') as archive:
    records = {member.name: json.loads(archive.extractfile(member).read())
               for member in archive if member.name.startswith('docs/claims/')}
assert len(records) == json.loads((source / 'result.json').read_bytes())['claim_records']
# The only record edited since that accepted snapshot has a completed exact
# mode/revision-only preservation. Keep the accepted source and qualify its mode.
name = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'
old = records[name]
selected = next(row for row in old['claims'] if row['name'] == 'backend-task-evidence-path-scope')
selected['durability'].update(mode='historical', revision='b370de8d31e3f38da6abf8ed4702a523aa3d6d97')
assert json.loads(Path(name).read_bytes()) == old
paths = [Path(__file__).relative_to(Path.cwd()), Path(name)] + [Path(path) for path in targets]
with tarfile.open(OUT / 'inputs-before-query.tar.gz', 'x:gz') as archive:
    for path in paths:
        archive.add(path, arcname=str(path), recursive=False)
hits = []
for record, body in records.items():
    for claim in body['claims']:
        leg = claim['durability']
        if leg['status'] == 'checked':
            for row in leg['inputs']:
                if row['path'] in targets:
                    hits.append(dict(record=record, claim=claim['name'], path=row['path'], mode=leg['mode'],
                                     revision=leg.get('revision'), sha256=row['sha256']))
live = [row for row in hits if row['mode'] == 'live']
(OUT / 'result.json').write_text(json.dumps(dict(prospective_paths=targets, records=len(records), intersections=hits,
    live_intersections=live, accepted_source=str(source), qualified_mode_record=name), indent=2, sort_keys=True) + '\n')
assert not live, 'Additional live storage binding requires preservation'
print(json.dumps(dict(records=len(records), intersections=len(hits), live_intersections=len(live))))
