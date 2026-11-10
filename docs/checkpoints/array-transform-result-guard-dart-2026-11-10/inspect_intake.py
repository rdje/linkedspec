"""Grade unchanged targets and freeze independent Dart observations before repair."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent


def frames(tag, prefix):
    result = {}
    for line in gzip.decompress((BASE / 'intake' / (tag + '-stdout.log.gz')).read_bytes()).decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, body = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(body)
    return result


def same(left, right):
    if type(left) is not type(right):
        return False
    if isinstance(left, list):
        return len(left) == len(right) and all(same(a, b) for a, b in zip(left, right))
    if isinstance(left, dict):
        return left.keys() == right.keys() and all(same(left[k], right[k]) for k in left)
    return left == right


cases = json.loads((BASE / 'cases.json').read_bytes())
native = frames('native', 'ARRAY_TRANSFORM_DART')
fresh = frames('fresh', 'ARRAY_TRANSFORM_DART_FRESH')
assert list(native) == list(fresh) == [row['id'] for row in cases]
profiles = {}
failures = []
for case in cases:
    key = case['id']
    rows = {**native[key], 'fresh': fresh[key]}
    assert set(rows) == {'native', 'restored', 'plan', 'fresh'}
    assert same(rows['native'], rows['restored']) and same(rows['plan'], rows['fresh'])
    if case.get('expected_error'):
        assert all(case['expected_error'] in row.get('error', '') for row in rows.values())
        assert rows['native']['class'] == 'RuntimeInterpreterException'
        assert rows['plan']['class'] == 'GeneratedSourceException'
    elif not case.get('profile_only'):
        if not all(same(row, {'value': case['expected']}) for row in rows.values()):
            failures.append(key)
    if case.get('profile_only') or case.get('expected_error'):
        profiles[key] = dict(source=case['source'], input=case['input'],
                             profile_only=bool(case.get('profile_only')), **rows)
    if key in failures or case.get('profile_only'):
        print(key, json.dumps(rows['native'], separators=(',', ':')))
for name, result in (('intake-failures.json', failures), ('intake-profiles.json', profiles)):
    target = BASE / name
    assert not target.exists()
    target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(original_failures=failures, own_profiles=len(profiles), all_routes_acquired=True)))
