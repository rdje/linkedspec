"""Record the small final source/publication checks and observed book rendering."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
with tarfile.open(BASE / 'validation-inputs.tar.gz', 'x:gz') as packed:
    for path in (BASE / 'validate.py', BASE / 'review_publication.py', BASE / 'roll_notes.py',
            Path('docs/linkedspec-book/src/development/documentation-workflow.md')):
        packed.add(path, arcname=str(path), recursive=False)
for label, argv in (
    ('review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py'), '--current']),
    ('publication-review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_publication.py')]),
):
    child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'commands' / (label + '.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    for channel in ('stdout', 'stderr'):
        (BASE / 'commands' / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    (BASE / 'commands' / (label + '-exit.txt')).write_text(str(child.returncode) + '\n')
    assert child.returncode == 0 and not child.stderr
    print(child.stdout.decode(), end='')
log = Path('.linkedspec-data/perl-other-io-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
html = Path('docs/linkedspec-book/book/development/documentation-workflow.html').read_text()
start = html.index('<p>IO syntax also needs operand roles.')
paragraph = html[start:html.index('</p>', start) + 4]
assert all(word in paragraph for word in ('322', '35', '122', '130', '121', 'handle origin', 'runtime reachability'))
(BASE / 'book-rendered-paragraph.html').write_text(paragraph + '\n')
(BASE / 'book.log.gz').write_bytes(gzip.compress(log, mtime=0))
(BASE / 'book-review.json').write_text(json.dumps(dict(result='PASS', command='bash tools/run_mdbook_local.sh',
    observed_build_exit=0, paragraph_sha256=hashlib.sha256((paragraph + '\n').encode()).hexdigest(),
    limits='Actual rendered paragraph and after-use combined build log; no full native/physical or outer-first-use claim.'), indent=2) + '\n')
print('Book build/rendered IO paragraph PASS')
