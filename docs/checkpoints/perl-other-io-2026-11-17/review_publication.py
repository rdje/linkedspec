"""Readonly verification of publication before-images and historical bindings."""
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
identities = json.loads((BASE / 'publication-before-identities.json').read_bytes())
found = set()
with tarfile.open(BASE / 'publication-before.tar.gz') as packed:
    for member in packed:
        assert member.isfile() and member.name not in found
        assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
        body = packed.extractfile(member).read()
        row = identities[member.name]
        assert (len(body), hashlib.sha256(body).hexdigest(), stat.S_IMODE(member.mode)) == (row['bytes'], row['sha256'], row['mode'])
        if member.name.endswith(('.py', '.pl')) and member.name.startswith(str(BASE) + '/'):
            assert Path(member.name).read_bytes() == body, 'actual publisher source'
        found.add(member.name)
assert found == set(identities)
bindings = json.loads((BASE / 'publication-bindings.json').read_bytes())
for row in bindings:
    claims = json.loads(Path(row['record']).read_bytes())['claims']
    claim, = [c for c in claims if c['name'] == row['claim']]
    leg = claim['durability']
    assert leg['mode'] == row['mode'] == 'historical' and leg['revision'] == row['revision']
    assert row['input'] in leg['inputs'], 'historical claim input unchanged'
print(json.dumps(dict(result='PASS', before_images=len(found), historical_bindings=len(bindings),
    limits='Publication byte/mode and historical binding recovery only; full native/physical and independent semantic closure remain open.'), sort_keys=True))
