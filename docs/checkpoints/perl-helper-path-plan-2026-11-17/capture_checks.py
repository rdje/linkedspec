"""Retain actual after-use focused-check channels and rendered plan paragraph."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
with tarfile.open(BASE / 'check-sources.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'capture_checks.py', BASE / 'review.py'):
        archive.add(path, arcname=str(path), recursive=False)
checks = []
for label, source, command in (
    ('review', '.linkedspec-data/perl-helper-path-plan-review.log', 'bash tools/run_python_project_data.sh docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py'),
    ('inherited-source-review', '.linkedspec-data/perl-helper-path-plan-source-review.log', 'bash tools/run_python_project_data.sh docs/checkpoints/perl-other-io-2026-11-17/review.py --current'),
    ('book', '.linkedspec-data/perl-helper-path-plan-book.log', 'bash tools/run_mdbook_local.sh'),
):
    body = Path(source).read_bytes()
    assert b'PASS' in body if label != 'book' else b'HTML book written' in body
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    checks.append(dict(command=command, source=source, target=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        recording='After-use actual combined stdout/stderr; successful sequential command chain observed exit0. No original separate-channel/outer-first-use credit.'))
html = Path('docs/linkedspec-book/book/development/documentation-workflow.html').read_text()
start = html.index('<p>Resolve an unresolved input cohort in bounded stages:')
paragraph = html[start:html.index('</p>', start) + 4]
assert 'complete source population' in paragraph and 'independent semantic or native-input verification' in paragraph
(BASE / 'book-rendered-paragraph.html').write_text(paragraph + '\n')
(BASE / 'checks.json').write_text(json.dumps(checks, indent=2) + '\n')
print('Recorded focused checks and actual rendered plan paragraph')
