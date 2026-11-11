"""Freeze Dart's observed policies and two additional Array-result targets."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
PROFILE = Path('tests/fixtures/array_pipeline_result_guard_dart_profiles.json')
NORMAL = Path('dart/test/array_pipeline_result_guard_composition_test.dart')
assert not PROFILE.exists() and not NORMAL.exists()


def frames(name, tag):
    rows = {}
    for line in gzip.open(BASE / 'intake' / name, 'rt'):
        if line.startswith(tag + ' '):
            _, key, body = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(body)
    assert len(rows) == 173
    return rows


native = frames('native-stdout.log.gz', 'ARRAY_PIPELINE_DART')
fresh = frames('fresh-stdout.log.gz', 'ARRAY_PIPELINE_DART_FRESH')
cases = json.loads((BASE / 'cases.json').read_bytes())
profiles, red = {}, []
for row in cases:
    key = row['id']
    observed = dict(native[key], fresh=fresh[key])
    assert set(observed) == {'native', 'restored', 'plan', 'fresh'}
    if row.get('profile_only') or row.get('expected_error'):
        profiles[key] = dict(row, **observed)
    if 'expected' in row and any(value != {'value': row['expected']} for value in observed.values()):
        red.append(key)
    if row.get('expected_error'):
        assert all(row['expected_error'] in value['error'] for value in observed.values())
assert len(red) == 17
for key in ('invalid_range_free_composed', 'invalid_range_receiver_composed'):
    assert all(profiles[key][route] == {'value': []} for route in ('native', 'restored', 'plan', 'fresh'))
    for route in ('native', 'restored', 'plan', 'fresh'):
        profiles[key][route] = {'value': None}
    profiles[key]['guard_target'] = 'Actual Array rejects Hash consumer before coalesce; terminal fallback remains[]'
    red.append(key)
assert len(profiles) == 141 and len(red) == 19
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(cases=173, shared=36, own=137, profiles=141,
    red=red, healthy=154, own_targets=['invalid_range_free_composed', 'invalid_range_receiver_composed'],
    scope='Finite independently acquired Dart source/arity/error/kind controls, not population/performance measurement'), indent=2) + '\n')
prior = Path('dart/test/array_transform_result_guard_composition_test.dart').read_text()
source = prior.replace('TYPE-REFERENCE-BOOK.1.2.23.3.78.3', 'TYPE-REFERENCE-BOOK.1.2.23.3.79.3')
source = source.replace('Array-transform', 'Array-pipeline').replace('array-transform', 'array-pipeline')
source = source.replace('array_transform', 'array_pipeline').replace('ARRAY_TRANSFORM', 'ARRAY_PIPELINE')
source = source.replace('2026-11-10/cases.json', '2026-11-11/cases.json')
NORMAL.write_text(source)
owner = Path('dart/lib/src/runtime/interpreter.dart')
original = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == original
(BASE / 'owner-before.dart.gz').write_bytes(gzip.compress(original, mtime=0))
print('Frozen141 independent profiles,173 normal cases and19 targets/154 preservation controls')
