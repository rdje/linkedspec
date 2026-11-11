"""Compare repaired Dart full error wires, own policy fences and exact pairs."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)

def frames(phase, stream, tag):
    raw = gzip.decompress((BASE / phase / (stream + '.log.gz')).read_bytes()).decode()
    rows = {}
    for key, body in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in rows
        rows[key] = json.loads(body)
    return rows

def observations(phase):
    native = frames(phase, 'native-stdout', 'CALLABLE_TRANSFORM_DART')
    fresh = frames(phase, 'fresh-stdout', 'CALLABLE_TRANSFORM_DART_FRESH')
    assert native.keys() == fresh.keys()
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def artifacts(phase):
    packet = next(row for row in json.loads((BASE / phase / 'custody.json').read_bytes()) if row['tag'] == 'emitted')
    result = {}
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        for member in archive:
            raw = archive.extractfile(member).read()
            row = packet['files'][member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
            result[member.name] = raw
    return result

assert (BASE / 'launches/after/exit.txt').read_text() == '0\n'
before, after = observations('intake'), observations('after')
profiles = json.loads(Path('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(before) == len(after) == len(profiles) == 312 and before.keys() == after.keys() == profiles.keys()
roles = {role: [] for role in ('supported-target', 'initial-source-compatibility', 'preservation')}
for key, profile in profiles.items():
    assert encoded(after[key]) == encoded({route: profile[route] for route in ('native', 'restored', 'plan', 'fresh')}), key
    roles[profile['role']].append(key)
    assert (encoded(before[key]) != encoded(after[key])) == (profile['role'] != 'preservation'), key
assert {key: len(value) for key, value in roles.items()} == {'supported-target': 28, 'initial-source-compatibility': 3, 'preservation': 281}
initial = [case['id'] for case in cases if case.get('question') in ('initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
assert len(initial) == 104 and all(encoded(before[key]) == encoded(after[key]) for key in initial)
original, repaired = artifacts('intake'), artifacts('after')
for index, case in enumerate(cases):
    for tail in ('inputs/case_' + str(index) + '.json', 'lib/case_' + str(index) + '.dart'):
        assert original[str(REL / 'intake/fresh' / tail)] == repaired[str(REL / 'after/fresh' / tail)], case['id']
channels = {}
for phase in ('intake', 'after'):
    channels[phase] = {}
    for name in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        raw = gzip.decompress((BASE / phase / name).read_bytes())
        channels[phase][name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
        assert raw == b'', 'Unexpected stderr requires separate root-cause review; do not strip it'
result = dict(repaired='PASS', programs=312, routes=4, supported_targets=28,
    separate_initial_compatibility=3, preserved=281, initial_policies_exact=104,
    actual_parsed_module_pairs_exact=312, complete_native_fresh_stderr=channels,
    limits='Dart-only finite full-wire result/source proof. Private old/current/direct and independent historical recovery remain separate checks; no peer or portable initial-input policy follows.')
target = BASE / 'after-check.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
