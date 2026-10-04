"""Preserve the dated cleanup claim at the exact pre-overlay Git boundary."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('freeze.py')
BASE = '3fc589f8494fd55b4f0154d6c226797a4fa2f711'
path = 'docs/claims/REPO-HYGIENE.8.json'
original = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
record = json.loads(original)
current = json.loads((ROOT / path).read_bytes())
assert current == record, 'unexpected pre-freeze record changes'
checked = []
for claim in record['claims']:
    leg = claim['durability']
    assert leg['status'] == 'checked' and leg['mode'] == 'live'
    for entry in leg['inputs']:
        data = subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)
        assert hashlib.sha256(data).hexdigest() == entry['sha256'], entry['path']
        checked.append(entry['path'])
    leg.update(mode='historical', revision=BASE)
for old, new in zip(current['claims'], record['claims'], strict=True):
    assert old['durability']['inputs'] == new['durability']['inputs']
    assert {key: value for key, value in old.items() if key != 'durability'} == {
        key: value for key, value in new.items() if key != 'durability'}
(ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
result = {'record': path, 'revision': BASE, 'verified_original_inputs': checked,
          'manifest_preserved': True,
          'scope': 'Historical identity preservation only. All original claim/results, input hashes and dated cleanup scope remain unchanged; no cleanup or current artifact census ran.'}
Path(PREFIX + 'freeze.json').write_text(json.dumps(result, indent=2) + '\n')
print('PASS original dated cleanup input identities preserved at exact pre-overlay Git boundary')
