"""Retain final focused checks and verify the recorded reader epoch distinction."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
TARGET = Path('docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py')
qualification = json.loads((BASE / 'plan-reader-qualification.json').read_bytes())
assert hashlib.sha256(TARGET.read_bytes()).hexdigest() == qualification['new_sha256']
assert gzip.decompress((BASE / 'plan-reader-after.py.gz').read_bytes()) == TARGET.read_bytes()
with tarfile.open(BASE / 'plan-reader-before.tar.gz') as archive:
    original = archive.extractfile(str(TARGET)).read()
    state = archive.extractfile('docs/tasks/TYPE-REFERENCE-BOOK.overview.md').read()
assert hashlib.sha256(original).hexdigest() == qualification['old_sha256']
assert original == subprocess.check_output(['git', 'show', qualification['accepted_epoch'] + ':' + str(TARGET)])
for label, code in (('old-plan-reader', 1), ('historical-plan-reader', 0), ('current-plan-reader', 1)):
    assert (BASE / (label + '-exit.txt')).read_text() == str(code) + '\n'
    output = gzip.decompress((BASE / (label + '-stdout.gz')).read_bytes())
    error = gzip.decompress((BASE / (label + '-stderr.gz')).read_bytes())
    if code:
        assert b'Status: `pending`' in error and not output
    else:
        assert not error and json.loads(output)['input_epoch'] == qualification['accepted_epoch']
with tarfile.open(BASE / 'final-inputs.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'final_checks.py', TARGET, BASE / 'PUBLICATION_QUESTION.md',
            Path('MEMORY.md'), Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'),
            Path('docs/linkedspec-book/src/development/documentation-workflow.md')):
        archive.add(path, arcname=str(path), recursive=False)
for label, argv in (
    ('final-metadata', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]),
    ('final-plan', ['bash', 'tools/run_python_project_data.sh', str(TARGET)]),
    ('final-memory', ['bash', 'scripts/check_memory_architecture.sh']),
    ('final-changes', ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']),
    ('final-notes', ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--check']),
):
    (BASE / (label + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    (BASE / (label + '-exit.txt')).write_text(str(child.returncode) + '\n')
    assert child.returncode == 0, child.stderr.decode()
    print(label + ': PASS')
html = Path('docs/linkedspec-book/book/development/documentation-workflow.html').read_text()
paragraphs = []
for prefix in ('<p>A dated retention review can also reuse a clean Git input', '<p>Historical recovery readers should bind task status'):
    start = html.index(prefix)
    paragraphs.append(html[start:html.index('</p>', start) + 4])
(BASE / 'book-rendered-paragraphs.html').write_text('\n'.join(paragraphs) + '\n')
log = Path('.linkedspec-data/artifact-review-nov17-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
(BASE / 'book.log.gz').write_bytes(gzip.compress(log, mtime=0))
assert json.loads((BASE / 'director-reply.json').read_bytes())['permission_pending'] is False
print('recorded epoch RED/GREEN/RED, director reply and rendered book: PASS')
