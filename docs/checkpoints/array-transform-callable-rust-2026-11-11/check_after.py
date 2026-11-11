"""Compare all repaired public routes to frozen targets and cold preservation."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent

def frames(phase, stream, tag):
    raw = gzip.decompress((BASE / phase / (stream + '.log.gz')).read_bytes()).decode()
    rows = {}
    for key, body in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in rows
        rows[key] = json.loads(body)
    return rows

def observations(phase):
    native = frames(phase, 'native-stdout', 'CALLABLE_TRANSFORM_RUST')
    fresh = frames(phase, 'fresh-stdout', 'CALLABLE_TRANSFORM_RUST_FRESH')
    assert native.keys() == fresh.keys()
    return {key: dict(value, fresh=fresh[key]) for key, value in native.items()}

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

assert (BASE / 'launches/after/exit.txt').read_text() == '0\n'
before, after = observations('intake'), observations('after')
profiles = json.loads(Path('tests/fixtures/array_transform_callable_result_guard_rust_profiles.json').read_bytes())
assert len(before) == len(after) == len(profiles) == 312 and before.keys() == after.keys() == profiles.keys()
changed, preserved = [], []
for key, profile in profiles.items():
    assert encoded(after[key]) == encoded({route: profile[route] for route in ('native', 'restored', 'plan', 'fresh')}), key
    if encoded(before[key]) != encoded(after[key]):
        assert profile['role'] == 'supported-target'
        changed.append(key)
    else:
        assert profile['role'] == 'preservation'
        preserved.append(key)
assert len(changed) == 20 and len(preserved) == 292
for name in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
    assert gzip.decompress((BASE / 'intake' / name).read_bytes()) == gzip.decompress((BASE / 'after' / name).read_bytes())
result = dict(repaired_public='PASS', programs=312, routes=4, exact_supported_changes=changed,
    full_preservation_records=292, warning_channels='byte-exact',
    limits='Focused four-route semantic comparison; exact private old/current, direct dependents and independent custody recovery remain separate checks.')
target = BASE / 'after-check.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
