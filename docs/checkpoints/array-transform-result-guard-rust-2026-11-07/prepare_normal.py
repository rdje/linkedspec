"""Freeze independently observed Rust policies; keep authored targets unchanged."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = Path.cwd()


def frames(name, prefix):
    rows = {}
    for line in gzip.decompress((BASE / 'intake' / (name + '-stdout.log.gz')).read_bytes()).decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


native = frames('native', 'ARRAY_TRANSFORM_RUST')
fresh = frames('fresh', 'ARRAY_TRANSFORM_RUST_FRESH')
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
assert list(native) == list(fresh) == [c['id'] for c in cases]
profiles = {}
red = []
for case in cases:
    key = case['id']
    assert set(native[key]) == {'native', 'restored', 'plan'}
    assert native[key]['native'] == native[key]['restored']
    routes = [*native[key].values(), fresh[key]]
    if 'error' in native[key]['native']:
        error = native[key]['native']['error']
        assert fresh[key] == native[key]['plan'] == {'error': 'Generated Rust parser execution failed: ' + error}
        if case.get('expected_error'):
            assert case['expected_error'] in error
        else:
            assert case.get('profile_only'), (key, error)
    else:
        assert all(row == native[key]['native'] for row in routes)
    if case.get('profile_only') or case.get('expected_error'):
        profiles[key] = dict(source=case['source'], input=case['input'],
                             profile_only=bool(case.get('profile_only')), **native[key], fresh=fresh[key])
    elif native[key]['native'] != {'value': case['expected']}:
        red.append(key)
assert len(profiles) == 152
fixture = ROOT / 'tests/fixtures/array_transform_result_guard_rust_profiles.json'
optional = ROOT / 'tests/fixtures/array_transform_optional_result_guard_cases.json'
normal = ROOT / 'rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs'
for path in (fixture, optional, normal):
    assert not path.exists()
fixture.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
optional.write_bytes((BASE / 'additional-targets.json').read_bytes())
source = (ROOT / 'rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs').read_text()
source = source.replace('TYPE-REFERENCE-BOOK.1.2.23.3.77.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.2')
source = source.replace('Hash-valued helper', 'Array-transform').replace('hash-value-result', 'array-transform-result')
source = source.replace('hash_value_result_guard', 'array_transform_result_guard')
source = source.replace('HASH_VALUE_RUST_NORMAL', 'ARRAY_TRANSFORM_RUST_NORMAL').replace('hash_value_cases', 'array_transform_cases')
needle = '    let profiles: Value = serde_json::from_str(include_str!('
assert source.count(needle) == 1
source = source.replace(needle,
    '    cases.extend(serde_json::from_str::<Vec<Value>>(include_str!(\n'
    '        "../../../tests/fixtures/array_transform_optional_result_guard_cases.json"\n'
    '    )).unwrap());\n' + needle)
start = source.index('array_transform_cases! {')
source = source[:start] + 'array_transform_cases! {\n' + ''.join('    ' + case['id'] + ',\n' for case in cases) + '}\n'
normal.write_text(source)
(BASE / 'baseline.json').write_text(json.dumps(dict(red=red, healthy=195-len(red),
    profiles=len(profiles), cases=195), indent=2) + '\n')
print(str(len(red)) + ' original RED, ' + str(195-len(red)) + ' healthy; unchanged195 normal prepared')
