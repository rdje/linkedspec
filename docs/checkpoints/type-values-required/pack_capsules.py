"""Remove only measured duplicate capsules after proving exact byte reconstruction."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import capsules

P = capsules.P
names = ('controls-inputs.json.gz', 'controls-complete-inputs.json.gz')
originals = {name: c.read(P + name) for name in names}
rows = []
for name, original in originals.items():
    value = json.loads(gzip.decompress(c.decode(original['base64'])))
    inputs = value.pop('inputs')
    identities = {path: {key: item[key] for key in ('sha256', 'mode')} for path, item in inputs.items()}
    assert all(c.sha(c.decode(item['base64'])) == item['sha256'] for item in inputs.values())
    reference = dict(body=value, inputs=identities, original_sha256=original['sha256'],
                     original_mode=original['mode'])
    c.write_new(P + name + '.ref.gz', reference, packed=True)
    reconstructed = dict(value, inputs={path: capsules.read_version(path, item)
                                       for path, item in identities.items()})
    raw = gzip.compress((json.dumps(reconstructed, sort_keys=True) + '\n').encode(), mtime=0)
    assert raw == c.decode(original['base64'])
    rows.append(dict(path=P + name, sha256=original['sha256'], mode=original['mode'],
                     original_bytes=len(raw), inputs=len(inputs),
                     reference=P + name + '.ref.gz'))
assert all(c.read(P + name) == item for name, item in originals.items())
for name in names:
    (ROOT / (P + name)).unlink()
for row in rows:
    assert capsules.read_version(row['path'], row)['sha256'] == row['sha256']
    assert not (ROOT / row['path']).exists()
c.write_new(P + 'capsule-recovery.json', dict(result='PASS', rows=rows,
    producer=c.read(P + 'pack_capsules.py'), reader=c.read(P + 'capsules.py'),
    scope='Only the two newly generated duplicate full-input capsules are removed. '
          'Reference capsules recover their exact original gzip bytes, modes and SHA256 '
          'from existing retained inputs. Original measured producers/results stay exact; '
          'this is storage deduplication, not a new measurement or refreshed observation.'))
print('Exact recovery PASS; two duplicate capsules replaced by verified references')
