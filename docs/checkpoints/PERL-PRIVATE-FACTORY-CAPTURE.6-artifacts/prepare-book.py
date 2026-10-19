"""Retain and derive the current full-book renderer without replaying its predecessor."""
import json
from pathlib import Path
import artifact as a

manifest = a.load_manifest()
path = a.PREFIX + 'book.py'
source = (a.ROOT / path).read_bytes()
assert a.sha(source) == manifest['inputs'][path]['sha256']
before = source
changes = [(('PREFIX = ' + repr(a.PREFIX)).encode(), ('PREFIX = ' + repr(a.HOME)).encode()),
           (b"MARKER = 'Pipeline observation transport'", b"MARKER = 'Checkpoint artifact parts'")]
for old, new in changes:
    assert source.count(old) == 1
    source = source.replace(old, new)
with (a.ROOT / (a.HOME + 'book.py')).open('xb') as output: output.write(source)
report = dict(result='PASS', before_base64=a.encode(before), before_sha256=a.sha(before),
              after_sha256=a.sha(source), producer_sha256=a.sha(Path(__file__).read_bytes()),
              replacements=[dict(before=old.decode(), after=new.decode()) for old, new in changes])
with (a.ROOT / (a.HOME + 'book-derivation.json')).open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
print('Current artifact book renderer derived from exact original669 source')
