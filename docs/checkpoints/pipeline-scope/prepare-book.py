"""Derive a distinct renderer from the exact archived original renderer."""
import json
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, load, sha, encode, decode

original = load()
source = decode(original['inputs'][OLD + 'book.py']['base64'])
before = source
changes = [(('PREFIX = ' + repr(OLD)).encode(), ('PREFIX = ' + repr(PREFIX)).encode()),
           (b"MARKER = 'Pipeline scope proof'", b"MARKER = 'Pipeline observation transport'")]
for old, new in changes:
    assert source.count(old) == 1
    source = source.replace(old, new)
with (ROOT / (PREFIX + 'book.py')).open('xb') as output: output.write(source)
report = dict(result='PASS', original_sha256=sha(before), original_source_base64=encode(before),
              current_sha256=sha(source), producer_sha256=sha(Path(__file__).read_bytes()),
              replacements=[dict(before=old.decode(), after=new.decode()) for old, new in changes])
with (ROOT / (PREFIX + 'book-derivation.json')).open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
print('Distinct complete-book renderer derived; only namespace/transport marker change')
