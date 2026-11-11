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
        assert profile['role'] in ('supported-target', 'initial-source-compatibility')
        changed.append(key)
    else:
        assert profile['role'] == 'preservation'
        preserved.append(key)
assert len(changed) == 23 and len(preserved) == 289
native_before = gzip.decompress((BASE / 'intake/native-stderr.log.gz').read_bytes())
native_after = gzip.decompress((BASE / 'after/native-stderr.log.gz').read_bytes())
fresh_before = gzip.decompress((BASE / 'intake/fresh-stderr.log.gz').read_bytes())
fresh_after = gzip.decompress((BASE / 'after/fresh-stderr.log.gz').read_bytes())
notice = b'tools/project_data_run.sh: child setpgid (43473 to 43473): Operation not permitted\n'
assert native_before == native_after == b''
assert fresh_before == notice and fresh_after == b''
assert (BASE / 'intake/fresh-exit.txt').read_text() == (BASE / 'after/fresh-exit.txt').read_text() == '0\n'

result = dict(repaired_public='PASS', programs=312, routes=4, exact_supported_changes=[key for key in changed if profiles[key]['role'] == 'supported-target'],
    separate_initial_compatibility=[key for key in changed if profiles[key]['role'] == 'initial-source-compatibility'], full_preservation_records=289, warning_channels=dict(native='both empty', fresh='original exact83-byte known wrapper setpgid notice; repaired empty; raw streams retained', repair_owner='SESSION-STARTUP-READING.7', original_final_pgid='uncaptured; no lifecycle claim'),
    limits='Focused four-route semantic comparison; original comparison1/first qualified comparison1 and original diagnostic1 retained; known launcher notice explicitly guarded without suppression; separate initial compatibility qualification retained; exact private old/current, direct dependents and independent custody recovery remain separate checks.')
target = BASE / 'after-check-qualified.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
