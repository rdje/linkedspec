"""Derive the complete-book producer from the established supplied-book route."""
import ast
from pathlib import Path
import common as c

path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/book.py'
before = c.read(path)
source = c.decode(before['base64'])
old = b"PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/'"
assert source.count(old) == 1
source = source.replace(old, b"PREFIX = 'docs/checkpoints/knowledge-fields/'", 1)
old = b"MARKER = 'Checkpoint artifact parts'"
assert source.count(old) == 1
source = source.replace(old, b"MARKER = 'Evidence and verification lists'", 1)
marker = b'rows = []\n'
assert source.count(marker) == 1
snapshot = b'''snapshot = {'producer_sha256': digest(Path(__file__).read_bytes()),
            'inputs': {path: {'base64': base64.b64encode(value).decode(), 'sha256': digest(value), 'mode': modes[path]}
                       for path, value in files.items()},
            'scope': 'Complete actual57-source book plus32 recursively included tracked inputs, before any render command.'}
with (ROOT / (PREFIX + 'book-inputs.json.gz')).open('xb') as output:
    output.write(gzip.compress(json.dumps(snapshot, sort_keys=True).encode(), mtime=0))

'''
source = source.replace(marker, snapshot + marker, 1)
source = source.replace(b'current pipeline workflow and native invocation-scope teaching overlays',
                        b'current metadata-list workflow and unchanged native invocation-scope teaching')
ast.parse(source, filename=c.HOME + 'book.py')
record = dict(result='PASS', original=before, after_base64=c.encode(source), after_sha256=c.sha(source),
              producer_base64=c.encode(Path(__file__).read_bytes()),
              scope='Reuse the established complete tracked/recursive-include enumeration, explicit '
                    'supplied cwd/output semantics and four distinguishing render controls. Change '
                    'only the current metadata marker/owner and retain every actual input byte/mode '
                    'before rendering. Earlier book producer/epochs remain immutable.')
c.write_new(c.HOME + 'book-derivation.json', record)
with (c.ROOT / (c.HOME + 'book.py')).open('xb') as output:
    output.write(source)
print('Current metadata book producer prepared from exact established source')
