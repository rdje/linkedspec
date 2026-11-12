"""Admit only the frozen own Dart outcomes, then transfer four old continuations."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
ROUTES = ('native', 'restored', 'plan', 'fresh')


def frames(body, tag):
    rows = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows
        rows[key] = json.loads(value)
    return rows


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


assert (BASE / 'launches/after/exit.txt').read_text() == '0\n'
native = frames(gzip.decompress((BASE / 'after/native-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_DART')
fresh = frames(gzip.decompress((BASE / 'after/fresh-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_DART_FRESH')
profiles = json.loads((ROOT / 'tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json').read_bytes())
assert native.keys() == fresh.keys() == profiles.keys() and len(native) == 508
observed = {key: dict(row, fresh=fresh[key]) for key, row in native.items()}
assert wire(observed) == wire({key: {r: row[r] for r in ROUTES} for key, row in profiles.items()})
for phase in ('intake', 'after'):
    for tag in ('native', 'fresh'):
        assert (BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
        assert gzip.decompress((BASE / phase / (tag + '-stderr.log.gz')).read_bytes()) == b''
(BASE / 'after-assessment.json').write_text(json.dumps(dict(programs=508, routes=4, exact_frozen_outcomes=True,
    supported=20, separate_compatibility=4, preserved=484), indent=2) + '\n')

# These are the exact own controls acquired before any production change.
transfers = (
    ('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json',
     {'own_extra_concat_arrays_free': 'own_extra_concat_arrays_free',
      'own_extra_concat_arrays_receiver': 'own_extra_concat_arrays_receiver'}),
    ('tests/fixtures/array_transform_result_guard_dart_profiles.json',
     {'extra_concat_arrays_free': 'ordinary_legacy_extra_concat_arrays_free_composed',
      'extra_concat_arrays_receiver': 'ordinary_legacy_extra_concat_arrays_receiver_composed'}),
)
receipts = []
for index, (name, keys) in enumerate(transfers):
    path = ROOT / name
    before = path.read_bytes()
    assert before == subprocess.check_output(['git', 'show', 'HEAD:' + name], cwd=ROOT)
    image = BASE / ('legacy-profile-before-' + str(index) + '.json.gz')
    assert not image.exists()
    image.write_bytes(gzip.compress(before, mtime=0))
    rows = json.loads(before)
    originals = json.loads(before)
    for legacy, current in keys.items():
        for route in ROUTES:
            assert 'value' in rows[legacy][route] and 'value' in observed[current][route]
            rows[legacy][route] = observed[current][route]
        # Existing metadata and all source/initial/operand policy remain exact.
        assert wire({k: v for k, v in rows[legacy].items() if k not in ROUTES}) == wire({k: v for k, v in originals[legacy].items() if k not in ROUTES})
    assert all(wire(row) == wire(originals[key]) for key, row in rows.items() if key not in keys)
    path.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
    after = path.read_bytes()
    receipts.append(dict(path=name, keys=keys, before_sha256=hashlib.sha256(before).hexdigest(),
        after_sha256=hashlib.sha256(after).hexdigest(), fields_changed=list(ROUTES)))
(BASE / 'legacy-transfers.json').write_text(json.dumps(receipts, indent=2, sort_keys=True) + '\n')
print('Own508/four routes exact; transferred only four already-acquired old continuation values')
