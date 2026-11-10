"""Grade actual independent Julia intake and freeze its source/error profiles."""
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from proof_io import BASE, frames
import gzip


def same(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


cases = json.loads((BASE / 'cases.json').read_bytes())
observed = frames(gzip.decompress((BASE / 'intake/normal-stdout.log.gz').read_bytes()), 'ARRAY_TRANSFORM_JULIA')
assert list(observed) == [case['id'] for case in cases]
profiles = {}
failures = []
for case in cases:
    key = case['id']
    rows = observed[key]
    assert set(rows) == {'native', 'restored', 'plan', 'fresh'}
    assert same(rows['native'], rows['restored']) and same(rows['plan'], rows['fresh'])
    if case.get('expected_error'):
        assert all(case['expected_error'] in row.get('error', '') for row in rows.values()), key
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
assert len(profiles) == 123
for name, value in (('intake-failures.json', failures), ('intake-profiles.json', profiles)):
    target = BASE / name
    assert not target.exists()
    target.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(original_failures=failures, own_profiles=len(profiles), four_routes='acquired')))
