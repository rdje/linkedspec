"""Freeze exact accepted claim bindings before the selected shared doc edits."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
OUT = BASE / 'publication-inputs'
OUT.mkdir()
targets = ['docs/linkedspec-book/src/appendix/runtime-semantics.md', 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md', 'docs/knowledge/lua-runtime-structured-diagnostics.md', 'docs/knowledge/lua-callable-pipeline-result-guards.md', 'docs/knowledge/lua-callable-array-transform-result-guards.md', 'docs/knowledge/lua-callable-key-count-preservation.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md']

claims = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'docs/claims'], text=True).splitlines() if name.endswith('.json')]
assert claims
paths = claims + [Path(__file__).relative_to(ROOT), Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
identities, bodies = {}, {}
with tarfile.open(OUT / 'inputs-before-query.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        if path in claims:
            assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        bodies[str(path)] = body
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-query.tar.gz') as archive:
    assert len(archive.getnames()) == len(identities) and set(archive.getnames()) == identities.keys()
    for member in archive:
        assert archive.extractfile(member).read() == bodies[member.name] and member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
hits, live = [], []
for path in claims:
    for claim in json.loads(bodies[str(path)])['claims']:
        durability = claim['durability']
        if durability['status'] == 'checked':
            for item in durability['inputs']:
                if item['path'] in targets:
                    row = dict(record=str(path), claim=claim['name'], path=item['path'], mode=durability['mode'],
                        revision=durability.get('revision'), sha256=item['sha256'])
                    hits.append(row)
                    if durability['mode'] == 'live':
                        live.append(row)
result = dict(claim_records=len(claims), prospective_paths=targets, checked_intersections=hits,
    live_intersections=live, source_commit=ACTIVATION,
    scope='Exact accepted Git records only. The new raw-field record is not yet accepted; native custody and current pack falsification remain explicit gaps. Historical bindings keep their original hashes/revisions; no SDK or old claim is refreshed.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
assert not live, 'Live claim binding requires preservation before doc edits'
print(json.dumps(dict(claim_records=len(claims), checked_intersections=len(hits), live_intersections=len(live))))
