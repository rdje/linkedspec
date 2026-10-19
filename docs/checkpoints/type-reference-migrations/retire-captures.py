"""Losslessly retain retired diagnostic producers as data before executable stubs."""
import common as c

originals, stubs = {}, {}
for name in ('capture-native.py', 'prepare-docs.py', 'prepare-docs-final.py'):
    path = c.PREFIX + name
    item = c.read(path)
    originals[path] = item
    stub = ('"""Retired one-shot capture; recover exact source from retired-capture-sources.json.gz."""\n'
            'raise SystemExit("Retired capture: use publish.py for readonly current verification")\n').encode()
    stubs[path] = dict(base64=c.encode(stub), sha256=c.sha(stub), mode=item['mode'])
c.write_new(c.PREFIX + 'retired-capture-sources.json.gz', dict(originals=originals, stubs=stubs,
    producer=c.read(c.PREFIX + 'retire-captures.py'),
    scope='Exact full original diagnostic Python source and filesystem modes remain recoverable as data. '
          'Only retired capture entrypoints become explicit non-executable stubs. No native channel '
          'or original capture input is rewritten; fresh current verification uses saved cases/native.pl.'), packed=True)
for path, item in stubs.items():
    assert c.read(path) == originals[path]
    (c.ROOT / path).write_bytes(c.decode(item['base64']))
print('Three retired diagnostic producer sources archived exactly; executable entrypoints retired')
