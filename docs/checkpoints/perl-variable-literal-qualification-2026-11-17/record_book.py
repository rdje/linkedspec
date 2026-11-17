"""Retain the actual successful book log and source-binding paragraph."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
log = Path('.linkedspec-data/perl-variable-literal-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
with (BASE / 'book.log.gz').open('xb') as stream:
    stream.write(gzip.compress(log, mtime=0))
path = Path('docs/linkedspec-book/book/development/documentation-workflow.html')
body = path.read_bytes()
start = body.index(b'<p>Variable-bound paths need a narrower source claim')
paragraph = body[start:body.index(b'</p>', start) + 4]
for value in (b'Across159', b'among192', b'preserving191 unmatched', b'historical JSON', b'not a new execution verdict'):
    assert value in paragraph
with (BASE / 'book-rendered-paragraph.html').open('xb') as stream:
    stream.write(paragraph + bytes([10]))
(BASE / 'book-review.json').write_text(json.dumps(dict(result='PASS', command='bash tools/run_mdbook_local.sh', observed_build_exit=0,
    log_sha256=hashlib.sha256(log).hexdigest(), rendered_path=str(path), rendered_sha256=hashlib.sha256(body).hexdigest(),
    limits='After-use log/paragraph copies; no full-book/native/outer-first-use/physical closure claim.'), indent=2) + chr(10))
print('book build/rendered binding paragraph PASS')
