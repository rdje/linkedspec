"""Preserve the refused no-write attempt and qualify actual source/render bytes."""
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
source = BOOK.read_bytes()
render = HTML.read_bytes()
start = render.index(b'<p>Literal file opens need mode')
paragraph = render[start:render.index(b'</p>', start) + 4]
with (BASE / 'book-rendered-paragraph.html').open('xb') as stream:
    stream.write(paragraph + bytes([10]))
logs = [('book-first', '.linkedspec-data/perl-literal-open-book.log'),
    ('book-refused', '.linkedspec-data/perl-literal-open-book-qualification.log')]
for label, name in logs:
    with (BASE / (label + '.log.gz')).open('xb') as stream:
        stream.write(gzip.compress(Path(name).read_bytes(), mtime=0))
names = {str(BOOK), str(BASE / 'book-rendered-paragraph.html')}
names |= {str(BASE / n) for n in ('capture_book_bytes.py', 'review_book_bytes.py', 'qualify_book.py', 'publish.py', 'prepare_publication.py', 'book-first.log.gz', 'book-refused.log.gz')}
identities = {}
with tarfile.open(BASE / 'book-byte-inputs.tar.gz', 'x:gz') as archive:
    for name in sorted(names):
        path = Path(name)
        body = path.read_bytes()
        identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'book-byte-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + chr(10))
spec = importlib.util.spec_from_file_location('book_byte_recorder', BASE / 'capture.py')
recorder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(recorder)
needle = bytes([96, 92, 36]) + b'buffer' + bytes([96])
assert source.count(needle) == 1
for label, snippet in [('book-source-byte', needle), ('book-two-slash-control', bytes([96, 92, 92, 36]) + b'buffer' + bytes([96]))]:
    child = recorder.run(label, ['od', '-An', '-tu1'], snippet + bytes([10]))
    assert child.returncode == 0 and not child.stderr
spec = importlib.util.spec_from_file_location('book_byte_reader', BASE / 'review_book_bytes.py')
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
report = reader.review()
(BASE / 'book-byte-review.json').write_text(json.dumps(report, indent=2, sort_keys=True) + chr(10))
assert BOOK.read_bytes() == source, 'book remains unchanged'
print(json.dumps(report, sort_keys=True))
