"""Enumerate every claim binding before selected shared publication edits."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'publication-inputs'
OUT.mkdir()
ACTIVATION = 'bf01d855bf913a5a839670669d9ad91e9c6314df'
targets = [
    'docs/linkedspec-book/src/appendix/backend-handoff.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/knowledge/normal-hook-archive-reference-contracts.md',
    'docs/tasks/REPO-HYGIENE.md',
]
claims = sorted(Path('docs/claims').glob('*.json'))
assert claims and subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
paths = claims + [BASE / 'check_publication_inputs.py', Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
rows, bodies = {}, {}
with tarfile.open(OUT / 'inputs-before-query.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        if path in claims:
            assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        bodies[str(path)] = body
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'inputs-before-query.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        body = archive.extractfile(member).read(); row = rows[member.name]
        assert body == bodies[member.name] and member.mode & 0o777 == row['mode']
hits, live = [], []
for path in claims:
    record = json.loads(bodies[str(path)])
    for claim in record['claims']:
        durability = claim['durability']
        if durability['status'] != 'checked':
            continue
        for item in durability['inputs']:
            if item['path'] not in targets:
                continue
            row = dict(record=str(path), claim=claim['name'], path=item['path'],
                mode=durability['mode'], revision=durability.get('revision'), sha256=item['sha256'])
            hits.append(row)
            if durability['mode'] == 'live':
                live.append(row)
result = dict(claim_records=len(claims), prospective_paths=targets, checked_intersections=hits,
    live_intersections=live, source_commit=ACTIVATION,
    scope='Every current claim record enumerated from exact accepted Git bytes before shared book/card edits; historical bindings stay at their original revisions. No SDK observation or claim hash is refreshed.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
assert not live, 'Live binding must be preserved before dependent publication edits; result retained'
print(json.dumps(dict(claim_records=len(claims), checked_intersections=len(hits), live_intersections=len(live)), sort_keys=True))
