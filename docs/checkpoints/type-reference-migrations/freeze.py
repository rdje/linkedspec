"""Freeze only the accepted metadata claim's mode/revision after its actual baseline."""
import copy
import gzip
import json
from pathlib import Path
import common as c

record = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
baseline = json.loads((c.ROOT / (c.PREFIX + 'baseline.json')).read_bytes())
assert baseline['result'] == 'PASS' and baseline['command']['returncode'] == 0
assert baseline['preservation_sha256'] == c.sha((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes())
assert c.read(c.PRIOR_CLAIM) == record['original'] and c.unchanged(record['inputs'])
assert all(c.unchanged(item['inputs']) for item in record['live'].values())
raw = c.decode(record['original']['base64'])
expected = copy.deepcopy(json.loads(raw))
expected['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
token = b'"mode": "live",'
assert raw.count(token) == 1
value = raw.replace(token, b'"mode": "historical",\n    "revision": "' + c.BASE.encode() + b'",', 1)
assert json.loads(value) == expected and len(value) <= 131072
(c.ROOT / c.PRIOR_CLAIM).write_bytes(value)
assert c.unchanged(record['inputs'])
assert (c.ROOT / c.PRIOR_CLAIM).stat().st_mode & 0o7777 == record['original']['mode']
for key, item in record['live'].items():
    assert c.unchanged(item['inputs'])
    if not key.startswith(c.PRIOR_CLAIM + '#'):
        assert c.read(key.rsplit('#', 1)[0]) == item['original']
c.write_new(c.PREFIX + 'freeze.json', dict(result='PASS', before=record['original'], after=c.read(c.PRIOR_CLAIM),
    preservation_sha256=c.sha((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()),
    baseline_sha256=c.sha((c.ROOT / (c.PREFIX + 'baseline.json')).read_bytes()),
    producer=c.read(c.PREFIX + 'freeze.py'),
    scope='Only mode/revision change to the real accepted1a8b20201. Original whole39111 bytes, '
          'actual readonly baseline and every208 input identity/mode remain retained; all native '
          'observations and the other two live input guards stay unchanged.'))
print('Accepted metadata frozen by mode/revision only at', c.BASE, ';all208 inputs unchanged')
