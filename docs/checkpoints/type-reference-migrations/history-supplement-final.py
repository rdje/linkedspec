"""Retain historical lowerers with an explicit final-function EOF boundary."""
import subprocess
from pathlib import Path
import common as c

revisions = ['fff219840212c26d78d75cda0ac9356f5f8d257c', '4e9250390785b9a36ae3c48abc17fabc97b75ac0']
path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
items = {}
for revision in revisions:
    value = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=c.ROOT)
    blocks = {}
    for name in ('_lower_return_imatch_statement', '_lower_return_array_statement'):
        start = value.index(('sub ' + name + ' {').encode())
        end = value.find(b'\nsub ', start + 1)
        if end < 0:
            end = len(value)
        assert end > start
        blocks[name] = c.encode(value[start:end])
    items[revision] = dict(path=path, base64=c.encode(value), sha256=c.sha(value), blocks=blocks)
c.write_new(c.PREFIX + 'history-supplement-final.json.gz', dict(result='CAPTURED', inputs=items,
    producer=c.read(c.PREFIX + 'history-supplement.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Additional immutable LinkedSpec-owned callback source; the initial history capture '
          'remains unchanged. No retired engine or dependency implementation is executed.'), packed=True)
for name, value in items[revisions[0]]['blocks'].items():
    print(name)
    print(c.decode(value).decode())
