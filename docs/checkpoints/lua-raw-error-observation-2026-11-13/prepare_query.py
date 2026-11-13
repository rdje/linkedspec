"""Preserve the accepted narrow-query templates before adapting this query."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c'
targets = ['docs/linkedspec-book/src/appendix/runtime-semantics.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
    'docs/knowledge/lua-runtime-structured-diagnostics.md', 'docs/knowledge/lua-callable-pipeline-result-guards.md',
    'docs/knowledge/lua-callable-array-transform-result-guards.md', 'docs/knowledge/lua-callable-key-count-preservation.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md']
templates = {}
for name in ('check_publication_inputs.py', 'review_publication_inputs.py'):
    source = Path('docs/checkpoints/ram-host-size-preflight-2026-11-12') / name
    body = source.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(source)])
    (BASE / ('template-' + name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    templates[str(source)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=source.stat().st_mode & 0o777)
    text = body.decode()
    if name.startswith('check_'):
        text = text.replace("ACTIVATION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'", "ACTIVATION = '" + ACTIVATION + "'")
        start = text.index('targets = ')
        end = text.index('\n', start)
        text = text[:start] + 'targets = ' + repr(targets) + text[end:]
        text = text.replace('The new resource operational record is not yet accepted and has two explicitly disclosed gaps.',
            'The new raw-field record is not yet accepted; native custody and current pack falsification remain explicit gaps.')
    assert not (BASE / name).exists()
    (BASE / name).write_text(text)
(BASE / 'query-template-identities.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
with tarfile.open(BASE / 'query-preparation-before-use.tar.gz', 'x:gz') as archive:
    archive.add(BASE / 'prepare_query.py', arcname=str(BASE / 'prepare_query.py'), recursive=False)
print('Prepared accepted-claim query/recovery from retained exact templates; no old producer replay')
