"""Grade each installed host independently; freeze actual policies before repair."""
import gzip
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from proof_io import BASE, FIXTURE, PROFILE, HOSTS, frames


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


cases = json.loads(FIXTURE.read_bytes())
profiles = {}
summary = {}
for host in HOSTS:
    output = gzip.decompress((BASE / 'intake' / host / 'normal-stdout.log.gz').read_bytes())
    observed = frames(output, 'ARRAY_TRANSFORM_LUA')
    assert list(observed) == [row['id'] for row in cases]
    own, failures = {}, []
    for case in cases:
        key = case['id']
        rows = observed[key]
        assert set(rows) == {'native', 'restored', 'plan', 'fresh'}
        assert same(rows['native'], rows['restored']) and same(rows['plan'], rows['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in row.get('error', '') for row in rows.values()), (host, key)
            assert rows['native']['runtime'] is True and rows['plan']['generated'] is True
        elif not case.get('profile_only'):
            if not all(same(row, {'value': case['expected']}) for row in rows.values()):
                failures.append(key)
        if case.get('profile_only') or case.get('expected_error'):
            own[key] = dict(source=case['source'], input=case['input'],
                            profile_only=bool(case.get('profile_only')), **rows)
        if key in failures or case.get('profile_only'):
            print(host, key, json.dumps(rows['native'], separators=(',', ':')))
    assert len(own) == 123
    profiles[host] = own
    summary[host] = dict(original_failures=failures, profiles=len(own), actual_host_line=next(
        line for line in output.decode().splitlines() if line.startswith('HOST ')))
assert not PROFILE.exists() and not (BASE / 'baseline-summary.json').exists()
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'intake-profiles.json').write_bytes(PROFILE.read_bytes())
(BASE / 'baseline-summary.json').write_text(json.dumps(summary, indent=2, sort_keys=True) + '\n')
print(json.dumps(summary, indent=2))
