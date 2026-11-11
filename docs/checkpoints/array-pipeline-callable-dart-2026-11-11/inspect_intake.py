"""Report actual independent Dart routes; peer outcomes are not an oracle."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent


def records(tag, stream):
    raw = gzip.decompress((BASE / 'intake' / stream).read_bytes()).decode()
    rows = {}
    for key, body in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in rows
        rows[key] = json.loads(body)
    return rows


def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


observed = records('CALLABLE_PIPELINE_DART', 'native-stdout.log.gz')
fresh = records('CALLABLE_PIPELINE_DART_FRESH', 'fresh-stdout.log.gz')
inputs = records('CALLABLE_PIPELINE_DART_INPUT', 'native-stdout.log.gz')
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
assert len(cases) == len(observed) == 194
for key, row in observed.items():
    if 'preparation_error' not in row:
        row['fresh'] = fresh[key]
        assert key in inputs
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
differences, profiles, healthy = {}, {}, []
for case in shared:
    key = case['id']; actual = observed[key]
    if case.get('profile_only'):
        profiles[key] = actual
        continue
    if 'expected' in case:
        expected = {'value': case['expected']}
        ok = all(encoded(value) == encoded(expected) for value in actual.values())
    else:
        assert 'expected_error' in case
        ok = all(case['expected_error'] in value.get('error', '') for value in actual.values())
    (healthy.append(key) if ok else differences.update({key: actual}))
groups = {}
for case in cases[len(shared):]:
    question = case['question']
    groups.setdefault(question, {})[case['id']] = observed[case['id']]
print(json.dumps(dict(programs=len(cases), observed=len(observed), serialized_inputs=len(inputs),
    fresh=len(fresh), shared_healthy=healthy, shared_differences=differences,
    shared_profiles=profiles, own_groups=groups), indent=2))
