"""Retain actual prose producer and exact fragment transport before its stub."""
import gzip
import json
import common as c

path = c.PREFIX + 'finish-prose.py'
proposals = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'docs-proposals-final.json.gz')).read_bytes()))
original = proposals['producer']
transport = c.read(path)
old = "old = 'construct values, and exact `array" + "(IDENTIFIER)` / `hash" + "(IDENTIFIER)` selectors are removed'"
new = "old = 'construct values, and exact `array' + '(IDENTIFIER)` / `hash' + '(IDENTIFIER)` selectors are removed'"
value = c.decode(original['base64']).decode()
assert value.count(old) == 1 and value.replace(old, new, 1).encode() == c.decode(transport['base64'])
stub = ('"""Retired prose writer; exact source is retained in prose-producer-transport.json."""\n'
        'raise SystemExit("Retired writer: use publish.py for readonly current verification")\n').encode()
replacement = dict(base64=c.encode(stub), sha256=c.sha(stub), mode=transport['mode'])
c.write_new(c.PREFIX + 'prose-producer-transport.json', dict(path=path, original=original,
    fragment_transport=transport, stub=replacement, exact_old_line=old, exact_new_line=new,
    producer=c.read(c.PREFIX + 'retire-prose.py')))
(c.ROOT / path).write_bytes(stub)
print('Actual prose producer and exact fragment inverse retained; entrypoint retired')
