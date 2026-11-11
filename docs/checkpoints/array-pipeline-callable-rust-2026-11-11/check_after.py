"""Require repaired public routes and exact cold preservation before controls."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]


def rows(phase, file, tag):
    text = gzip.decompress((BASE / phase / file).read_bytes()).decode()
    result = {}
    for key, body in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', text, re.M):
        assert key not in result
        result[key] = json.loads(body)
    return result


def observed(phase):
    native = rows(phase, 'native-stdout.log.gz', 'CALLABLE_PIPELINE_RUST')
    fresh = rows(phase, 'fresh-stdout.log.gz', 'CALLABLE_PIPELINE_RUST_FRESH')
    assert native.keys() == fresh.keys()
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}


encoded = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
before, after = observed('intake'), observed('after')
profiles = json.loads((ROOT / 'tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json').read_bytes())
assert before.keys() == after.keys() == profiles.keys() and len(after) == 194
roles = {}
for key, profile in profiles.items():
    expected = {route: profile[route] for route in ('native', 'restored', 'plan', 'fresh')}
    assert encoded(after[key]) == encoded(expected), key
    roles[profile['role']] = roles.get(profile['role'], 0) + 1
    if profile['role'] == 'preservation':
        assert encoded(before[key]) == encoded(after[key]), key
    else:
        assert encoded(before[key]) != encoded(after[key]), key
assert roles == {'supported-target': 8, 'pattern-compatibility': 3, 'preservation': 183}
for phase in ('intake', 'after'):
    for tag in ('native', 'fresh'):
        assert (BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
for name in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
    assert gzip.decompress((BASE / 'intake' / name).read_bytes()) == gzip.decompress((BASE / 'after' / name).read_bytes())
print(json.dumps(dict(public_routes='PASS', programs=194, routes=4, roles=roles,
    raw_runtime_stderr='exact before/after; producer warnings preserved',
    limits='Three compatibility changes do not admit dynamic pattern sources; full admission remains separate.'), indent=2))
