"""Retain complete historical files and explicit presence/absence of callbacks."""
import json
import subprocess
import common as c

items = {}
for revision in ('fff219840212c26d78d75cda0ac9356f5f8d257c', '4e9250390785b9a36ae3c48abc17fabc97b75ac0'):
    value = subprocess.check_output(['git', 'show', revision + ':perl/LinkedSpec/ActionIR/MethodLowering.pm'], cwd=c.ROOT)
    blocks = {}
    for name in ('_lower_return_imatch_statement', '_lower_return_array_statement'):
        start = value.find(('sub ' + name + ' {').encode())
        if start < 0:
            blocks[name] = None
            continue
        end = value.find(b'\nsub ', start + 1)
        blocks[name] = c.encode(value[start:len(value) if end < 0 else end])
    items[revision] = dict(base64=c.encode(value), sha256=c.sha(value), blocks=blocks)
c.write_new(c.PREFIX + 'history-current.json.gz', dict(inputs=items,
    producer=c.read(c.PREFIX + 'history-current.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Full immutable LinkedSpec-owned Git files; absent removed callbacks are explicit null. '
          'Original failed sources and captures remain unchanged. No retired engine execution.'), packed=True)
for revision, item in items.items():
    for name, block in item['blocks'].items():
        print(revision, name)
        print(c.decode(block).decode() if block else 'ABSENT')
