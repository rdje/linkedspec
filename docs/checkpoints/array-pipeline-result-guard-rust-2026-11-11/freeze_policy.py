"""Freeze independently observed Rust policy; declare the one own guard target."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
PROFILE = Path('tests/fixtures/array_pipeline_result_guard_rust_profiles.json')
NORMAL = Path('rust/linkedspec-runtime/tests/array_pipeline_result_guard_composition.rs')
assert not PROFILE.exists() and not NORMAL.exists()


def frames(name, prefix):
    result = {}
    for line in gzip.open(BASE / 'intake' / name, 'rt'):
        if line.startswith(prefix + ' '):
            _, key, body = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(body)
    assert len(result) == 173
    return result


native = frames('native-stdout.log.gz', 'ARRAY_PIPELINE_RUST')
fresh = frames('fresh-stdout.log.gz', 'ARRAY_PIPELINE_RUST_FRESH')
shared = json.loads(Path('tests/fixtures/array_pipeline_result_guard_cases.json').read_bytes())
own = json.loads((BASE / 'profile-sources.json').read_bytes())
profiles, red = {}, []
for row in shared + own:
    key = row['id']
    observed = dict(native[key], fresh=fresh[key])
    assert set(observed) == {'native', 'restored', 'plan', 'fresh'}
    if row.get('profile_only') or row.get('expected_error'):
        profiles[key] = dict(row, **observed)
    if 'expected' in row and any(value != {'value': row['expected']} for value in observed.values()):
        red.append(key)
    if row.get('expected_error'):
        assert all(row['expected_error'] in value['error'] for value in observed.values())
assert len(red) == 10
# The producer's invalid-range fallback remains []; its Array result must reject
# set_key and retain rejection through coalesce, just like the receiver control.
key = 'invalid_range_free_composed'
assert all(value == {'value': []} for value in profiles[key].values() if isinstance(value, dict))
for route in ('native', 'restored', 'plan', 'fresh'):
    profiles[key][route] = {'value': None}
profiles[key]['guard_target'] = 'Actual Array result rejects Hash consumer before coalesce'
red.append(key)
assert len(profiles) == 141 and len(red) == 11
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(cases=173, shared=36, own=137,
    profiles=141, red=red, healthy=162, own_target=key,
    scope='Finite authored source/kind/error/arity controls; not a population measurement'), indent=2) + '\n')
prior = Path('rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs').read_text()
prefix = prior[:prior.index('array_transform_cases! {')]
prefix = prefix.replace('TYPE-REFERENCE-BOOK.1.2.23.3.78.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.79.2')
prefix = prefix.replace('Array-transform', 'Array-pipeline').replace('array-transform', 'array-pipeline')
prefix = prefix.replace('array_transform', 'array_pipeline').replace('ARRAY_TRANSFORM', 'ARRAY_PIPELINE')
start = prefix.index('    cases.extend(')
end = prefix.index('    let profiles:', start)
prefix = prefix[:start] + prefix[end:]
NORMAL.write_text(prefix + 'array_pipeline_cases! {\n' + ''.join('    ' + row['id'] + ',\n' for row in shared + own) + '}\n')
owner = Path('rust/linkedspec-runtime/src/engine.rs')
original = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == original
(BASE / 'owner-before.rs.gz').write_bytes(gzip.compress(original, mtime=0))
print('Frozen141 route profiles and173 normal cases;11 declared targets/162 preservation controls')
