"""Preserve the actual first render; correct only the new scalar-reference example."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
BOOK = Path('docs/linkedspec-book/src/development/documentation-workflow.md')
HTML = Path('docs/linkedspec-book/book/development/documentation-workflow.html')
before = BOOK.read_bytes()
old, new = rb'`\\$buffer`', rb'`\$buffer`'
assert before.count(old) == 1 and before.count(new) == 0
with tarfile.open(BASE / 'book-correction-before.tar.gz', 'x:gz') as archive:
    archive.add(BOOK, arcname=str(BOOK), recursive=False)
    archive.add(Path(__file__), arcname=str(BASE / 'qualify_book.py'), recursive=False)
log = Path('.linkedspec-data/perl-literal-open-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
with (BASE / 'book-first.log.gz').open('xb') as stream:
    stream.write(gzip.compress(log, mtime=0))
html = HTML.read_text()
start = html.index('<p>Literal file opens need mode')
paragraph = html[start:html.index('</p>', start) + len('</p>')]
assert '<code>\\\\$buffer</code>' in paragraph
(BASE / 'book-first-paragraph.html').write_text(paragraph + '\n')
after = before.replace(old, new, 1)
assert len(before) - len(after) == 1
BOOK.write_bytes(after)
spec = importlib.util.spec_from_file_location('literal_book_recorder', BASE / 'capture.py')
recorder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(recorder)
child = recorder.run('book-qualified', ['bash', 'tools/run_mdbook_local.sh'])
assert child.returncode == 0
html = HTML.read_text()
start = html.index('<p>Literal file opens need mode')
paragraph = html[start:html.index('</p>', start) + len('</p>')]
assert '<code>\\$buffer</code>' in paragraph and '<code>\\\\$buffer</code>' not in paragraph
assert 'accepts34 of191' in paragraph and 'All157 unmatched sites' in paragraph and "'&lt;:raw'" in paragraph
(BASE / 'book-qualified-paragraph.html').write_text(paragraph + '\n')
(BASE / 'book-correction.json').write_text(json.dumps(dict(result='PASS', path=str(BOOK),
    before_sha256=hashlib.sha256(before).hexdigest(), after_sha256=hashlib.sha256(after).hexdigest(),
    before_bytes=len(before), after_bytes=len(after), mode=stat.S_IMODE(BOOK.stat().st_mode),
    first_log_sha256=hashlib.sha256(log).hexdigest(), observed_first_exit=0, actual_qualified_exit=child.returncode,
    correction='One removed backslash in the new scalar-reference example only. Actual used publisher/preparer and first rendered source remain unchanged in their archives.',
    limits='After-use first log/render copies; source/example correction and actual rerender only. No full semantic/native/first-use closure.'), indent=2) + '\n')
print('Qualified one-backslash scalar-reference example and actual book rerender PASS')
