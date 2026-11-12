"""Freeze Julia's independently observed producer/error fences before repair."""
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
CASES = ROOT / 'tests/fixtures/array_transform_callable_result_guard_julia_cases.json'
PROFILE = ROOT / 'tests/fixtures/array_transform_callable_result_guard_julia_profiles.json'
NORMAL = ROOT / 'julia/test/array_transform_callable_result_guard_composition_test.jl'
assert all(not path.exists() for path in (CASES, PROFILE, NORMAL, BASE / 'baseline.json'))
assert (BASE / 'launches/trace/exit.txt').read_text() == '0\n'

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def frames(phase, tag):
    rows = {}
    for line in gzip.decompress((BASE / phase / 'native-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, raw = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(raw)
    return rows

def value_record(value):
    return {route: dict(value=copy.deepcopy(value)) for route in ROUTES}

def artifacts(phase):
    packet = next(p for p in json.loads((BASE / phase / 'custody.json').read_bytes()) if p['tag'] == 'artifacts')
    rows = {}
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        for member in archive:
            body = archive.extractfile(member).read(); row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            rows[member.name] = body
    return rows

cases = json.loads((BASE / 'cases.json').read_bytes())
cold = frames('intake', 'CALLABLE_TRANSFORM_JULIA')
assert len(cases) == len(cold) == 312 and list(cold) == [row['id'] for row in cases]
assert all(set(row) == set(ROUTES) for row in cold.values())
traces = frames('trace', 'CALLABLE_TRANSFORM_JULIA_TRACE')
trace_cases = json.loads((BASE / 'trace-sources.json').read_bytes())
assert list(traces) == [row['id'] for row in trace_cases] and len(traces) == 9
original_inputs, traced_inputs = artifacts('intake'), artifacts('trace')
assert len(original_inputs) == 624 and len(traced_inputs) == 18
for key, row in traces.items():
    assert encoded(row) == encoded(cold[key]['native'])
    assert traced_inputs[str(REL / 'trace' / (key + '.parsed.json'))] == original_inputs[str(REL / 'intake/parsed' / (key + '.json'))]
    log = traced_inputs[str(REL / 'trace' / (key + '.trace.log'))]
    assert b'julia_frontend:' in log and b'julia_compiler:compile_spec' in log and b'julia_runtime:' in log

expected = copy.deepcopy(cold)
targets, compatibility = [], []
for case in cases[:45]:
    key = case['id']
    if 'expected' in case:
        wanted = value_record(case['expected'])
        if encoded(cold[key]) != encoded(wanted):
            assert all(encoded(cold[key][route]) != encoded(wanted[route]) for route in ROUTES)
            targets.append(key)
        expected[key] = wanted
    elif 'expected_error' in case:
        assert all(case['expected_error'] in cold[key][route].get('error', '') for route in ROUTES)
assert len(targets) == 12
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    prefix = 'own_optional_' + helper
    contrast = cold[prefix + '_free_composed']
    assert encoded(contrast) == encoded(value_record([None, 'S']))
    assert encoded(cold[prefix + '_receiver']) == encoded(cold[prefix + '_free'])
    key = prefix + '_receiver_composed'
    targets.append(key); expected[key] = copy.deepcopy(contrast)
for prefix in ('own_signature_variadic_empty', 'own_signature_variadic_multi'):
    key = prefix + '_composed'
    wanted = {}
    for route in ROUTES:
        array, effects = cold[prefix + '_terminal'][route]['value']
        assert isinstance(array, list) and effects in ('', 'S')
        wanted[route] = dict(value=[None, effects])
    targets.append(key); expected[key] = wanted
targets.append('own_source_before_rejection')
expected['own_source_before_rejection'] = value_record([None, 'S'])
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    key = 'positive_' + helper + '_receiver_composed'
    wanted = {}
    for route in ROUTES:
        array, effects = cold['positive_' + helper + '_receiver_terminal'][route]['value']
        assert isinstance(array, list) and effects in ('S', 'SN', 'SNC', 'ST')
        wanted[route] = dict(value=[None, effects])
    targets.append(key); expected[key] = wanted
assert len(targets) == len(set(targets)) == 28
for kind in ('number', 'null', 'hash'):
    key = 'initial_' + kind + '_composed'
    assert next(row for row in cases if row['id'] == key)['profile_only'] is True
    assert encoded(cold['initial_' + kind + '_terminal']) == encoded(value_record([[], []]))
    assert encoded(cold['own_initial_' + kind + '_take_receiver_with']) == encoded(value_record([0, 'W']))
    assert encoded(cold[key]) == encoded(value_record(['ran', 'KVW']))
    compatibility.append(key); expected[key] = value_record([None, ''])
changed = [key for key in cold if encoded(cold[key]) != encoded(expected[key])]
assert set(changed) == set(targets + compatibility)
preserved = [key for key in cold if key not in changed]
assert len(preserved) == 281
initial = [row['id'] for row in cases if row.get('question') in (
    'initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
assert len(initial) == 104 and set(initial) <= set(preserved)
assert encoded(cold['own_scalar_bool_receiver_with']) == encoded(value_record([None, '']))
assert encoded(cold['own_scalar_bool_free_with']) == encoded(value_record([0, 'W']))
for form in ('free', 'receiver'):
    for helper in ('sorted', 'reversed'):
        assert encoded(cold['own_extra_' + helper + '_' + form]) == encoded(value_record(['ran', 'SXKVW']))
for case in cases:
    if case.get('question') in ('needed-source-error', 'needed-operand-error', 'signature-invalid-signature', 'function-arity-composed', 'function-arity-terminal'):
        for route in ROUTES:
            assert 'error' in cold[case['id']][route] and isinstance(cold[case['id']][route]['error_json'], dict)

baseline = dict(programs=312, observed=cold, expected=expected, supported_targets=targets,
    separate_initial_compatibility=compatibility, preserved=preserved, initial_policies=initial,
    limits='Own Julia cold/terminal/traced contrasts precede production. Three initial-source continuations are separate compatibility, no portable invalid-input or product-RED credit. Full error wires/Boolean receiver-null/free-empty/excluded SXKVW remain preservation fences.')
(BASE / 'baseline.json').write_text(json.dumps(baseline, indent=2, sort_keys=True) + '\n')
CASES.write_text(json.dumps(cases, indent=2) + '\n')
PROFILE.write_text(json.dumps([dict(id=row['id'], expected=expected[row['id']],
    role='supported-target' if row['id'] in targets else 'initial-source-compatibility' if row['id'] in compatibility else 'preservation')
    for row in cases], indent=2) + '\n')
old = (ROOT / 'julia/test/array_pipeline_callable_result_guard_composition_test.jl').read_text()
normal = (old.replace('array-pipeline-callable-julia-2026-11-11', BASE.name)
    .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))
NORMAL.write_text(normal)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'julia/src', 'julia/test/runtests.jl'], cwd=ROOT) == b''
for name, path in (('owner', 'julia/src/runtime/Interpreter.jl'), ('runner', 'julia/test/runtests.jl')):
    body = (ROOT / path).read_bytes()
    assert body == subprocess.check_output(['git', 'show', '3767c87c7167bdcb29b0092be35bc139520e3509:' + path], cwd=ROOT)
    (BASE / (name + '-before.jl.gz')).write_bytes(gzip.compress(body, mtime=0))
print(json.dumps(dict(programs=312, supported_targets=targets, separate_initial_compatibility=compatibility,
    preserved=281, initial_policies=104, traced_inputs_exact=9, production='unchanged'), indent=2))
