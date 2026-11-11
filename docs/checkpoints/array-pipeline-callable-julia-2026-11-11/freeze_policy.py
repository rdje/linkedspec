"""Freeze Julia's own complete before records and bounded authored guard targets."""
import copy
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'baseline.json').exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
observed = {}
for line in gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('CALLABLE_PIPELINE_JULIA '):
        _, key, body = line.split(' ', 2)
        assert key not in observed
        observed[key] = json.loads(body)
assert list(observed) == [row['id'] for row in cases]
routes = ('native', 'restored', 'plan', 'fresh')
assert all(set(row) == set(routes) for row in observed.values())


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def value_record(value):
    return {route: dict(value=copy.deepcopy(value)) for route in routes}


expected = copy.deepcopy(observed)
targets, compatibility = [], []
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
for case in shared:
    key = case['id']
    if 'expected' in case:
        wanted = value_record(case['expected'])
        if canonical(observed[key]) != canonical(wanted):
            assert all(canonical(observed[key][route]) != canonical(wanted[route]) for route in routes)
            targets.append(key)
        expected[key] = wanted
    elif 'expected_error' in case:
        assert all(case['expected_error'] in observed[key][route]['error'] for route in routes)
assert len(targets) == 13

own = cases[len(shared):174]
assert len(own) == 137
for case in own:
    key, question = case['id'], case['question']
    row = observed[key]
    if question == 'initial-source':
        assert canonical(row) == canonical(value_record([]))
    elif question == 'initial-source-with':
        assert canonical(row) == canonical(value_record([0, 'W']))
    elif question == 'excluded-extra-arity':
        assert canonical(row) == canonical(value_record(['ran', 'SXKW']))
    elif question == 'excluded-missing-arity':
        value = [['h', 'e', 'a', 'd'], 'W'] if key.startswith('missing_operand_split_each_') else [[], 'W']
        assert canonical(row) == canonical(value_record(value))
    elif question == 'earlier-owner':
        value = [['a'], 'W'] if key == 'prior_view' else [None, '']
        assert canonical(row) == canonical(value_record(value))
    elif question in ('needed-source-error', 'needed-delimiter-error'):
        assert all('binding_kind_mismatch' in row[route]['error'] and 'error_json' in row[route] for route in routes)
    elif question == 'regex-error-policy':
        value = None if key == 'invalid_range_free_composed' else []
        assert canonical(row) == canonical(value_record(value))
        if key == 'invalid_range_receiver_composed':
            targets.append(key)
            expected[key] = value_record(None)

for case in cases[174:184]:
    key = case['id']
    if case['question'] == 'function-signature-invalid':
        assert all('expects' in observed[key][route]['error'] and 'error_json' in observed[key][route] for route in routes)
    elif case['form'] == 'composed':
        terminal = key.removesuffix('_composed') + '_terminal'
        terminal_value = observed[terminal]['native']['value']
        assert all(canonical(observed[terminal][route]) == canonical(dict(value=terminal_value)) for route in routes)
        wanted = value_record([None, terminal_value[1]])
        assert canonical(observed[key]) != canonical(wanted)
        targets.append(key)
        expected[key] = wanted

for case in cases[184:]:
    key = case['id']
    if case['form'] != 'composed' or 'needed_error' in key:
        continue
    terminal = key.removesuffix('_composed') + '_terminal'
    value = observed[terminal]['native']['value']
    assert all(canonical(observed[terminal][route]) == canonical(dict(value=value)) for route in routes)
    wanted = value_record([None, value[1]])
    assert canonical(observed[key]) != canonical(wanted)
    (targets if case['question'] == 'canonical-pattern' else compatibility).append(key)
    expected[key] = wanted

assert len(targets) == 17 and len(compatibility) == 3
changed = [key for key in observed if canonical(observed[key]) != canonical(expected[key])]
assert set(changed) == set(targets + compatibility)
preserved = [key for key in observed if key not in changed]
assert len(preserved) == 174
baseline = dict(observed=observed, expected=expected, supported_targets=targets,
    separate_pattern_compatibility=compatibility, preserved=preserved,
    limits='Own Julia finite controls; noncanonical patterns gain no new regex/callback authority; old omitted fields/native custody remain unassessed.')
(BASE / 'baseline.json').write_text(json.dumps(baseline, indent=2, sort_keys=True) + '\n')
for name, rows in (
    ('array_pipeline_callable_result_guard_julia_cases.json', cases),
    ('array_pipeline_callable_result_guard_julia_profiles.json',
        [dict(id=case['id'], expected=expected[case['id']]) for case in cases]),
):
    target = Path('tests/fixtures') / name
    assert not target.exists()
    target.write_text(json.dumps(rows, indent=2) + '\n')
print(json.dumps(dict(programs=len(cases), supported_targets=targets,
    separate_pattern_compatibility=compatibility, preserved=len(preserved)), indent=2))
