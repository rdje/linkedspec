"""Freeze each installed host's actual policy before any runtime correction."""
import copy
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'baseline.json').exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
routes = ('native', 'restored', 'plan', 'fresh')


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def value_record(value):
    return {route: dict(value=copy.deepcopy(value)) for route in routes}


hosts, profiles = {}, {}
for host in ('puc', 'luajit'):
    observed = {}
    for line in gzip.decompress((BASE / 'intake' / host / 'normal-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('CALLABLE_PIPELINE_LUA '):
            _, key, raw = line.split(' ', 2)
            assert key not in observed
            observed[key] = json.loads(raw)
    assert list(observed) == [row['id'] for row in cases]
    assert all(set(row) == set(routes) for row in observed.values())
    expected = copy.deepcopy(observed)
    targets, compatibility = [], []
    for index, case in enumerate(cases):
        key, question = case['id'], case.get('question')
        if index < 37:
            if 'expected' in case:
                wanted = value_record(case['expected'])
                if canonical(observed[key]) != canonical(wanted):
                    assert all(canonical(observed[key][route]) != canonical(wanted[route]) for route in routes)
                    targets.append(key)
                expected[key] = wanted
            elif 'expected_error' in case:
                assert all(case['expected_error'] in observed[key][route]['error'] for route in routes)
        if question == 'initial-source':
            assert canonical(observed[key]) == canonical(value_record([]))
        elif question == 'initial-source-with':
            assert canonical(observed[key]) == canonical(value_record([0, 'W']))
        elif question == 'excluded-extra-arity':
            assert canonical(observed[key]) == canonical(value_record(['ran', 'SXKW']))
        elif question == 'excluded-missing-arity':
            value = [['h', 'e', 'a', 'd'], 'W'] if key.startswith('missing_operand_split_each_') else [[], 'W']
            assert canonical(observed[key]) == canonical(value_record(value))
        elif question == 'earlier-owner':
            value = [['a'], 'W'] if key == 'prior_view' else [None, '']
            assert canonical(observed[key]) == canonical(value_record(value))
        elif question in ('needed-source-error', 'needed-delimiter-error', 'needed-pattern-error'):
            assert all('binding_kind_mismatch' in observed[key][route]['error'] and 'error_json' in observed[key][route] for route in routes)
        elif question == 'function-signature-invalid':
            assert all('expects arity' in observed[key][route]['error'] and 'error_json' in observed[key][route] for route in routes)
        elif question == 'function-signature-valid' and case['form'] == 'composed':
            terminal = key.removesuffix('_composed') + '_terminal'
            value = observed[terminal]['native']['value']
            assert canonical(observed[terminal]) == canonical(value_record(value))
            expected[key] = value_record([None, value[1]])
            targets.append(key)
        elif key.startswith('own_pattern_') and case['form'] == 'composed' and 'needed_error' not in key:
            terminal = key.removesuffix('_composed') + '_terminal'
            value = observed[terminal]['native']['value']
            assert canonical(observed[terminal]) == canonical(value_record(value))
            assert value[0] == (['head'] if case['question'] == 'canonical-pattern' else [])
            expected[key] = value_record([None, value[1]])
            (targets if case['question'] == 'canonical-pattern' else compatibility).append(key)
    assert len(targets) == 16 and len(compatibility) == 3
    changed = [key for key in observed if canonical(observed[key]) != canonical(expected[key])]
    assert set(changed) == set(targets + compatibility)
    preserved = [key for key in observed if key not in changed]
    assert len(preserved) == 175
    hosts[host] = dict(observed=observed, expected=expected, supported_targets=targets,
        separate_pattern_compatibility=compatibility, preserved=preserved)
    profiles[host] = {case['id']: dict(source=case['source'], **expected[case['id']]) for case in cases}
(BASE / 'baseline.json').write_text(json.dumps(hosts, indent=2, sort_keys=True) + '\n')
target = Path('tests/fixtures/array_pipeline_callable_result_guard_lua_profiles.json')
assert not target.exists()
target.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
print(json.dumps({host: dict(programs=len(cases), supported_targets=len(row['supported_targets']),
    separate_pattern_compatibility=len(row['separate_pattern_compatibility']), preserved=len(row['preserved']))
    for host, row in hosts.items()}, indent=2))
