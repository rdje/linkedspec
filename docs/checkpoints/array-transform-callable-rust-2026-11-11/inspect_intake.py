"""Recover complete cold Rust observations without inheriting a peer verdict."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent

def frames(name, tag):
    raw = gzip.decompress((BASE / 'intake' / name).read_bytes()).decode()
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in result
        result[key] = json.loads(value)
    return result

def same(left, right):
    return json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))

cases = json.loads((BASE / 'intake/cases.json').read_bytes())
assert cases == json.loads((BASE / 'cases.json').read_bytes())
native = frames('native-stdout.log.gz', 'CALLABLE_TRANSFORM_RUST')
fresh = frames('fresh-stdout.log.gz', 'CALLABLE_TRANSFORM_RUST_FRESH')
inputs = frames('native-stdout.log.gz', 'CALLABLE_TRANSFORM_RUST_INPUT')
parsed = frames('native-stdout.log.gz', 'CALLABLE_TRANSFORM_RUST_PARSED_INPUT')
assert len(cases) == len(native) == len(fresh) == len(inputs) == len(parsed) == 312
observed = {}
for case in cases:
    key = case['id']
    assert set(native[key]) == {'native', 'restored', 'plan'}
    observed[key] = dict(native[key], fresh=fresh[key])
    for directory, field, rows in (('inputs', 'compiled', inputs), ('parsed-inputs', 'parsed', parsed)):
        assert (BASE / 'intake/fresh' / directory / (key + '.json')).read_bytes() == rows[key][field].encode()
healthy, differences, profiles = [], {}, {}
for case in cases[:45]:
    key = case['id']
    if case.get('profile_only'):
        profiles[key] = observed[key]
        continue
    if 'expected' in case:
        ok = all(same(row, {'value': case['expected']}) for row in observed[key].values())
    else:
        assert 'expected_error' in case
        ok = all(case['expected_error'] in row.get('error', '') for row in observed[key].values())
    if ok:
        healthy.append(key)
    else:
        differences[key] = observed[key]
groups = {}
for case in cases[45:]:
    groups.setdefault(case['question'], {})[case['id']] = observed[case['id']]
report = dict(programs=312, parsed_inputs=312, serialized_inputs=312, fresh=312,
    shared_healthy=healthy, shared_differences=differences, shared_profiles=profiles,
    own_groups=groups, observed=observed,
    limits='Own questions remain profiles until contract and actual terminal contrasts establish targets; no peer outcomes imported.')
target = BASE / 'intake-assessment.json'
assert not target.exists()
target.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(programs=312, shared_healthy=len(healthy), shared_differences=list(differences),
    shared_profiles=len(profiles), own_questions=sum(map(len, groups.values())),
    scope=report['limits']), indent=2))
