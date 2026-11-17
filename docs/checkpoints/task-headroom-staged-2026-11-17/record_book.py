"""Retain the observed successful book build and its new rendered paragraph."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
log = Path('.linkedspec-data/task-headroom-staged-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
with (BASE / 'book.log.gz').open('xb') as stream:
    stream.write(gzip.compress(log, mtime=0))
path = Path('docs/linkedspec-book/book/development/documentation-workflow.html')
body = path.read_bytes()
start = body.index(b'<p>The closed staged-parsing tree uses')
paragraph = body[start:body.index(b'</p>', start) + 4]
for value in (b'15 ordered IDs', b'19108-byte', b'11972', b'--tree STAGED-LINKED-PARSING', b'--epoch TYPE-REFERENCE-BOOK.1.2.23.4.36 --all', b'historical'):
    assert value in paragraph
with (BASE / 'book-rendered-paragraph.html').open('xb') as stream:
    stream.write(paragraph + bytes([10]))
(BASE / 'book-review.json').write_text(json.dumps(dict(result='PASS', command='bash tools/run_mdbook_local.sh', observed_build_exit=0,
    original_log_sha256=hashlib.sha256(log).hexdigest(), rendered_path=str(path), rendered_sha256=hashlib.sha256(body).hexdigest(),
    limits='After-use log and exact new paragraph copies only; no full-book/native/first-use/physical closure claim.'), indent=2) + chr(10))
print('book build/rendered epoch paragraph PASS')
