"""Validate exact retired-source recovery and current non-executable transport."""
import gzip
import json
import common as c


def originals():
    retained = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'retired-capture-sources.json.gz')).read_bytes()))
    records = {path: (item, retained['stubs'][path]) for path, item in retained['originals'].items()}
    prose = json.loads((c.ROOT / (c.PREFIX + 'prose-producer-transport.json')).read_bytes())
    value = c.decode(prose['original']['base64']).decode()
    assert value.count(prose['exact_old_line']) == 1
    assert value.replace(prose['exact_old_line'], prose['exact_new_line'], 1).encode() == c.decode(prose['fragment_transport']['base64'])
    records[prose['path']] = prose['original'], prose['stub']
    for path, (item, stub) in records.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        assert c.read(path) == stub, ('exact current retired source transport', path)
    return {path: item for path, (item, _) in records.items()}


def recover(path):
    records = originals()
    return records[path] if path in records else c.read(path)


def unchanged(inputs):
    records = originals()
    return all((records[path] if path in records else c.read(path)) == item for path, item in inputs.items())
