"""Freeze each Lua host's own cold/terminal/traced result and error policies."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ROUTES = ('native', 'restored', 'plan', 'fresh')
PROFILE = ROOT / 'tests/fixtures/array_transform_callable_result_guard_lua_profiles.json'
NORMAL = ROOT / 'lua/test/array_transform_callable_result_guard_composition_test.lua'
assert all(not path.exists() for path in (PROFILE, NORMAL, BASE / 'baseline.json'))
assert (BASE / 'trace/complete.txt').is_file()
cases = json.loads((BASE / 'cases.json').read_bytes())
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
trace_cases = json.loads((BASE / 'trace-sources.json').read_bytes())

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def values(value):
    return {route: dict(value=copy.deepcopy(value)) for route in ROUTES}

def recover(phase, host, kind):
    out = BASE / phase / host
    name = 'actual-emitted-parsed.tar.gz' if phase == 'intake' else 'actual-trace-inputs.tar.gz'
    rows = json.loads((out / 'artifact-identities.json').read_bytes())
    result = {}
    with tarfile.open(out / name) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    return result

baseline, profiles, summary = {}, {}, {}
for host in ('puc', 'luajit'):
    cold = assessment[host]['observed']
    assert len(cold) == 312 and all(set(row) == set(ROUTES) for row in cold.values())
    trace = {}
    trace_out = BASE / 'trace' / host
    for line in gzip.decompress((trace_out / 'trace-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('CALLABLE_TRANSFORM_LUA_TRACE '):
            _, key, raw = line.split(' ', 2)
            assert key not in trace
            trace[key] = json.loads(raw)
    assert list(trace) == [row['id'] for row in trace_cases] and len(trace) == 9
    assert (trace_out / 'trace-exit.txt').read_text() == '0\n'
    assert gzip.decompress((trace_out / 'trace-stderr.log.gz').read_bytes()) == b''
    original, traced = recover('intake', host, 'artifacts'), recover('trace', host, 'artifacts')
    assert len(original) == 624 and len(traced) == 27
    for key, row in trace.items():
        assert encoded(row) == encoded(cold[key]['native'])
        assert traced[str(REL / 'trace' / host / (key + '.parsed.json'))] == original[str(REL / 'intake' / host / 'parsed' / (key + '.json'))]
        payload = json.loads(traced[str(REL / 'trace' / host / (key + '.compiled.json'))])
        assert isinstance(payload, list), 'actual tagged public payload projection'
        log = traced[str(REL / 'trace' / host / (key + '.trace.log'))]
        assert b'lua_' in log and log
    expected = copy.deepcopy(cold)
    targets, compatibility = [], []
    for case in cases[:45]:
        key = case['id']
        if 'expected' in case:
            wanted = values(case['expected'])
            if encoded(cold[key]) != encoded(wanted):
                targets.append(key)
            expected[key] = wanted
        elif 'expected_error' in case:
            assert all(case['expected_error'] in cold[key][route].get('error', '') for route in ROUTES)
    assert targets == assessment[host]['shared_targets'] and len(targets) == 12
    for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
        prefix = 'own_optional_' + helper
        assert encoded(cold[prefix + '_free_composed']) == encoded(values([None, 'S']))
        assert encoded(cold[prefix + '_receiver']) == encoded(cold[prefix + '_free'])
        key = prefix + '_receiver_composed'; targets.append(key)
        expected[key] = copy.deepcopy(cold[prefix + '_free_composed'])
    for prefix in ('own_signature_variadic_empty', 'own_signature_variadic_multi'):
        key = prefix + '_composed'; targets.append(key); expected[key] = {}
        for route in ROUTES:
            array, effects = cold[prefix + '_terminal'][route]['value']
            assert isinstance(array, list) and effects in ('', 'S')
            expected[key][route] = dict(value=[None, effects])
    targets.append('own_source_before_rejection')
    expected['own_source_before_rejection'] = values([None, 'S'])
    for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
        key = 'positive_' + helper + '_receiver_composed'; targets.append(key); expected[key] = {}
        for route in ROUTES:
            array, effects = cold['positive_' + helper + '_receiver_terminal'][route]['value']
            assert isinstance(array, list) and effects in ('S', 'SN', 'SNC', 'ST')
            expected[key][route] = dict(value=[None, effects])
    for kind in ('number', 'null', 'hash'):
        key = 'initial_' + kind + '_composed'
        assert next(row for row in cases if row['id'] == key)['profile_only'] is True
        assert encoded(cold['initial_' + kind + '_terminal']) == encoded(values([[], []]))
        assert encoded(cold['own_initial_' + kind + '_take_receiver_with']) == encoded(values([0, 'W']))
        assert encoded(cold[key]) == encoded(values(['ran', 'KVW']))
        compatibility.append(key); expected[key] = values([None, ''])
    assert len(targets) == 28 and len(compatibility) == 3
    changed = [row['id'] for row in cases if encoded(cold[row['id']]) != encoded(expected[row['id']])]
    assert set(changed) == set(targets + compatibility)
    assert all(encoded(cold[key][route]) != encoded(expected[key][route]) for key in changed for route in ROUTES)
    preserved = [row['id'] for row in cases if row['id'] not in changed]
    initial = [row['id'] for row in cases if row.get('question') in (
        'initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
    assert len(preserved) == 281 and len(initial) == 104 and set(initial) <= set(preserved)
    assert encoded(cold['own_scalar_bool_receiver_with']) == encoded(values([None, '']))
    assert encoded(cold['own_scalar_bool_free_with']) == encoded(values([0, 'W']))
    for form in ('free', 'receiver'):
        for helper in ('sorted', 'reversed'):
            assert encoded(cold['own_extra_' + helper + '_' + form]) == encoded(values(['ran', 'SXKVW']))
    for case in cases:
        if case.get('question') in ('needed-source-error', 'needed-operand-error', 'signature-invalid-signature', 'function-arity-composed', 'function-arity-terminal'):
            for route in ROUTES:
                row = cold[case['id']][route]
                assert isinstance(row['error_json'], dict) and 'error' in row and 'runtime' in row and 'generated' in row
    baseline[host] = dict(observed=cold, expected=expected, supported_targets=targets,
        separate_initial_compatibility=compatibility, preserved=preserved, initial_policies=initial,
        limits='Own cold/terminal/traced observations precede production. Three initial-source continuations are separate compatibility, no product-RED or portable input credit. Full public errors/outer native fields and all own initial/arity policies remain fences.')
    profiles[host] = {row['id']: dict(source=row['source'],
        role='supported-target' if row['id'] in targets else 'initial-source-compatibility' if row['id'] in compatibility else 'preservation',
        **expected[row['id']]) for row in cases}
    summary[host] = dict(programs=312, supported_targets=28, separate_initial_compatibility=3,
        preserved=281, initial_policies=104, public_traces=9, actual_parsed_module_pairs=312)
for name, value in (('baseline.json', baseline), ('baseline-summary.json', summary)):
    (BASE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
normal = (ROOT / 'lua/test/array_pipeline_callable_result_guard_composition_test.lua').read_text()
normal = (normal.replace('2026%-11%-11', '2026%-11%-12').replace('pipeline', 'transform')
    .replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform')
    .replace('TYPE-REFERENCE-BOOK.1.2.23.3.79.6.5', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.6.5'))
NORMAL.write_text(normal)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'lua/src', 'lua/test/run.lua'], cwd=ROOT) == b''
for name, path in (('owner', 'lua/src/linkedspec/interpreter.lua'), ('runner', 'lua/test/run.lua')):
    body = (ROOT / path).read_bytes()
    assert body == subprocess.check_output(['git', 'show', 'fff959ef7e8896b5b97f311a276cabc4f5034551:' + path], cwd=ROOT)
    (BASE / (name + '-before.lua.gz')).write_bytes(gzip.compress(body, mtime=0))
print(json.dumps(summary, indent=2, sort_keys=True))
