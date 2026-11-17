"""Disclose the refused display-misreading attempt without changing earlier claims."""
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
plan = json.loads((BASE / 'plan.json').read_bytes())
owner = plan['owner']
path = Path('docs/claims/' + owner + '.json')
record = json.loads(path.read_bytes())
assert len(record['claims']) == 3
report = json.loads((BASE / 'book-byte-review.json').read_bytes())
assert report['result'] == 'PASS' and report['actual_book_edit'] is False
with tarfile.open(BASE / 'book-disclosure-before.tar.gz', 'x:gz') as archive:
    for item in (path, BASE / 'book-byte-review.json', BASE / 'publish_book_review.py'):
        archive.add(item, arcname=str(item), recursive=False)
record['claims'].append(dict(name='book-scalar-reference-bytes',
    statement='The new source and rendered example each contain one ASCII92 backslash. The correction attempt refused at its first guard before writing; no book correction occurred.',
    scope=report['limits'], rederive=dict(status='checked',
        command='bash tools/run_python_project_data.sh ' + str(BASE / 'review_book_bytes.py'),
        granularity='Actual retained source/render paragraph, publisher literal, failed corrector source/traceback and native od stdin/stdout/stderr/exit bytes.', result=json.dumps(report, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='The escaped display might represent two actual book backslashes, or a two-backslash specimen might satisfy the single-byte oracle.',
        oracle='Independent native od unsigned-byte output against literal ASCII sequence; source/render raw byte counts and original publisher paragraph.',
        red_control='Actual two-backslash stdin produces two92 bytes at od exit0 and fails the one92-byte oracle. Healthy source has one92; the original correction guard refuses before its write.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Actual source/render paragraph, new audit instruments, old refused corrector and after-use failure/build logs retained. Native od/renderer/toolchain/OS, original refused-producer first-use/outer launch and full source-origin/per-read/physical closure remain4.2/SESSION5. No missing first-use channel is reconstructed.')))
path.write_text(json.dumps(record, indent=2) + chr(10))
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + owner + '`' + chr(10))
end = text.index(chr(10) + '- ID:', start + 1)
node = text[start:end] + '  Book review: Display misreading triggered a no-write guard refusal; native byte proof confirms original source/render one ASCII92, two-byte control RED. Failed attempt retained; no book edit.' + chr(10)
path.write_text(text[:start] + node + text[end:])
path = Path('DEVELOPMENT_NOTES.md')
text = path.read_text()
first, end = text.index(chr(10) + '## '), text.index(chr(10) + '## ', text.index(chr(10) + '## ') + 1)
note = text[first:end]
assert owner in note
note += chr(10) + 'Book verification also retains a refused correction caused by reading JSON display escaping as source bytes. Native od confirms one ASCII92 in source/render and rejects an actual two92 control; the original published paragraph remains unchanged.' + chr(10)
path.write_text(text[:first] + note + text[end:])
print('Retained refused attempt and appended only the new book-byte claim')
