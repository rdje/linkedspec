"""Prepare fresh accepted-binding queries without replaying previous writers."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-concat-open-arity-julia-2026-11-12')
ACTIVATION = 'a3faaf97292550ba1e3001604e1e379d478bcdd4'
identities = {}
for name in ('check_publication_inputs.py', 'review_publication_inputs.py'):
    path = OLD / name
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    image = BASE / ('publication-template-' + name + '.gz')
    image.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(image.read_bytes()) == body
    identities[str(path)] = dict(image=str(image), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
    text = body.decode().replace('952f8a022c59a478614ba1413e0e36e49e7e14e8', ACTIVATION)
    if name == 'check_publication_inputs.py':
        start = text.index('targets = [')
        end = text.index('\nclaims = ', start)
        text = text[:start] + '''targets = ['docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
''' + text[end:]
        text = text.replace('The new Julia operational record', 'The new daily31 record')
        text = text.replace('has two explicitly disclosed gaps', 'discloses its native and auxiliary telemetry gaps')
    else:
        start = text.index('    match = next(')
        end = text.index('    try:\n        inspect(changed)', start)
        text = text[:start] + '''    matches = [row for row in report['checked_intersections'] if row['path'] == target]
    changed = copy.deepcopy(records)
    if matches:
        match = matches[0]
        claim = next(row for row in changed[match['record']]['claims'] if row['name'] == match['claim'])
        assert claim['durability']['mode'] == 'historical', 'mutation precondition'
        claim['durability']['mode'] = 'live'
    else:
        # An authored future-binding control also covers a target with no
        # present historical intersection; it is not an accepted claim record.
        changed['synthetic-live-control'] = dict(claims=[dict(name='future-live-binding',
            durability=dict(status='checked', mode='live', inputs=[dict(path=target, sha256='0' * 64)]))])
''' + text[end:]
    compile(text, name, 'exec')
    target = BASE / name
    assert not target.exists()
    target.write_text(text)
(BASE / 'publication-template-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
print('Prepared exact accepted-claim query and independent six-target live-binding controls before maintenance publication')
