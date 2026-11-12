"""Readonly Julia evidence oracle; imports no SDK, capture producer or policy writer."""
import copy
import io
import difflib
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-callable-julia-2026-11-12')
ACTIVATION = '3767c87c7167bdcb29b0092be35bc139520e3509'
OWNER = 'julia/src/runtime/Interpreter.jl'
RUNNER = 'julia/test/runtests.jl'
NORMAL = 'julia/test/array_transform_callable_result_guard_composition_test.jl'
HELPER = 'julia/test/callable_array_transform_observation.jl'
CASE_FILE = 'tests/fixtures/array_transform_callable_result_guard_julia_cases.json'
PROFILE = 'tests/fixtures/array_transform_callable_result_guard_julia_profiles.json'
CONTROL = str(BASE / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')
COMPLETED_LAUNCHES = ('after', 'before', 'check-after', 'check-before', 'direct', 'direct-check', 'freeze-policy', 'inspect-intake', 'intake', 'prepare', 'prepare-epochs', 'prepare-review', 'prepare-trace', 'private-fixed', 'private-fixed-check', 'private-old', 'private-old-check', 'remaining', 'repair', 'trace')


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def digest(body):
    return hashlib.sha256(body).hexdigest()


def equal(actual, expected):
    assert actual == expected


def read(name):
    path = PurePosixPath(name)
    assert not path.is_absolute() and '..' not in path.parts
    target = ROOT / name
    assert target.is_file() and not target.is_symlink()
    return target.read_bytes()


def capsule(name, identities):
    result = {}
    with tarfile.open(ROOT / name) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in result
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    assert result.keys() == identities.keys()
    return result


def epoch(name):
    packets = json.loads(read(str(BASE / name / 'custody.json')))
    assert [packet['tag'] for packet in packets] == ['root', 'artifacts']
    return tuple(capsule(packet['archive'], packet['files']) for packet in packets)


def channel(phase, tag, name):
    return gzip.decompress(read(str(BASE / phase / (tag + '-' + name + '.log.gz'))))


def frames(body, prefix):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, raw = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(raw)
    return rows


def value_record(value):
    return {route: dict(value=copy.deepcopy(value)) for route in ROUTES}


def semantic_oracle(cases, cold):
    assert len(cases) == 312 and list(cold) == [row['id'] for row in cases]
    assert all(set(row) == set(ROUTES) for row in cold.values())
    expected = copy.deepcopy(cold)
    supported, compatibility = [], []
    for case in cases[:45]:
        key = case['id']
        if 'expected' in case:
            wanted = value_record(case['expected'])
            if canonical(cold[key]) != canonical(wanted):
                supported.append(key)
            expected[key] = wanted
        elif 'expected_error' in case:
            assert all(case['expected_error'] in cold[key][route].get('error', '') for route in ROUTES)
    assert len(supported) == 12
    for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
        prefix = 'own_optional_' + helper
        assert canonical(cold[prefix + '_free_composed']) == canonical(value_record([None, 'S']))
        assert canonical(cold[prefix + '_receiver']) == canonical(cold[prefix + '_free'])
        key = prefix + '_receiver_composed'
        supported.append(key); expected[key] = copy.deepcopy(cold[prefix + '_free_composed'])
    for prefix in ('own_signature_variadic_empty', 'own_signature_variadic_multi'):
        key = prefix + '_composed'; supported.append(key)
        expected[key] = {}
        for route in ROUTES:
            array, effects = cold[prefix + '_terminal'][route]['value']
            assert isinstance(array, list) and effects in ('', 'S')
            expected[key][route] = dict(value=[None, effects])
    supported.append('own_source_before_rejection')
    expected['own_source_before_rejection'] = value_record([None, 'S'])
    for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
        key = 'positive_' + helper + '_receiver_composed'; supported.append(key)
        expected[key] = {}
        for route in ROUTES:
            array, effects = cold['positive_' + helper + '_receiver_terminal'][route]['value']
            assert isinstance(array, list) and effects in ('S', 'SN', 'SNC', 'ST')
            expected[key][route] = dict(value=[None, effects])
    for kind in ('number', 'null', 'hash'):
        key = 'initial_' + kind + '_composed'
        assert next(row for row in cases if row['id'] == key)['profile_only'] is True
        assert canonical(cold['initial_' + kind + '_terminal']) == canonical(value_record([[], []]))
        assert canonical(cold['own_initial_' + kind + '_take_receiver_with']) == canonical(value_record([0, 'W']))
        assert canonical(cold[key]) == canonical(value_record(['ran', 'KVW']))
        compatibility.append(key); expected[key] = value_record([None, ''])
    assert len(supported) == 28 and len(compatibility) == 3
    assert {key for key in cold if canonical(cold[key]) != canonical(expected[key])} == set(supported + compatibility)
    assert canonical(cold['own_scalar_bool_receiver_with']) == canonical(value_record([None, '']))
    assert canonical(cold['own_scalar_bool_free_with']) == canonical(value_record([0, 'W']))
    for form in ('free', 'receiver'):
        for helper in ('sorted', 'reversed'):
            assert canonical(cold['own_extra_' + helper + '_' + form]) == canonical(value_record(['ran', 'SXKVW']))
    for case in cases:
        if case.get('question') in ('needed-source-error', 'needed-operand-error', 'signature-invalid-signature', 'function-arity-composed', 'function-arity-terminal'):
            for route in ROUTES:
                row = cold[case['id']][route]
                assert isinstance(row['error_json'], dict) and row['error']
                if route in ('native', 'restored'):
                    assert row['class'] == 'RuntimeInterpreterException'
                    assert row['error_json']['message'] == row['error']
                else:
                    assert row['class'] == 'GeneratedSourceException'
                    assert row['error_json']['source_identity'] == 'callable-array-transform/' + case['id'] + '.spec'
    return expected, supported, compatibility


def exact_records(actual, expected):
    assert list(actual) == list(expected)
    assert canonical(actual) == canonical(expected)


def source_oracle(before, after, runner_before, runner_after):
    old = b'''    if receiver isa ActionCallExpr
        has_user_function_name(engine.compiled_spec.function_registry, receiver.name) && return false
        if something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
'''
    new = b'''    # Invocation keeps its arity checks and caller effects. A canonical transform
    # prefix owns the produced result without becoming an unregistered free call.
    if receiver isa ActionCallExpr
        if !has_user_function_name(engine.compiled_spec.function_registry, receiver.name) &&
            something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
'''
    assert before.count(old) == 1 and after == before.replace(old, new)
    include = b'include("array_transform_result_guard_composition_test.jl")\n'
    added = b'include("array_transform_callable_result_guard_composition_test.jl")\n'
    assert runner_before.count(include) == 1 and runner_after == runner_before.replace(include, include + added)


def input_order(source, kind):
    if kind == 'observer':
        fragments = ('write(parsed_path, serialized)', 'retained = read(parsed_path, String)',
            'restored = from_json(SpecFile, JSON3.read(retained))', 'compiled = compile_spec(parsed)')
    elif kind == 'normal':
        fragments = ('write(path, serialized)', 'retained = read(path, String)',
            'restored = from_json(SpecFile, JSON3.read(serialized))', 'compiled = compile_spec(parsed)')
    else:
        fragments = ('write(path, serialized)', 'read(path, String) == serialized', 'compiled = compile_spec(parsed; trace=trace)')
    positions = [source.index(fragment.encode()) for fragment in fragments]
    assert positions == sorted(set(positions))


def loaded_owner(body, sdk):
    assert ('CALLABLE_TRANSFORM_JULIA_OWNER ' + sdk + '/src/LinkedSpecJulia.jl\n').encode() in body


def normal_channel_oracle(phase, body=None):
    body = channel(phase, 'normal', 'stderr') if body is None else body
    row = json.loads(read(str(BASE / (phase + '-check.json'))))['actual_stderr']
    assert len(body) == row['bytes'] and digest(body) == row['sha256']
    if phase in ('before', 'private-old'):
        assert b'Some tests did not pass: 1124 passed, 124 failed, 0 errored, 0 broken.' in body
    elif phase == 'after':
        assert body.startswith(b'Precompiling packages...\n') and b'1 dependency successfully precompiled' in body and b'ERROR' not in body
    else:
        assert body == b''


def main():
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
    cases = json.loads(read(str(BASE / 'cases.json')))
    epochs = {name: epoch(name) for name in ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct')}
    cold = frames(channel('intake', 'native', 'stdout'), 'CALLABLE_TRANSFORM_JULIA')
    expected, supported, compatibility = semantic_oracle(cases, cold)
    baseline = json.loads(read(str(BASE / 'baseline.json')))
    assert canonical(baseline['observed']) == canonical(cold)
    assert canonical(baseline['expected']) == canonical(expected)
    assert baseline['supported_targets'] == supported and baseline['separate_initial_compatibility'] == compatibility
    assert len(baseline['preserved']) == 281 and set(baseline['preserved']) == set(cold) - set(supported + compatibility)
    assert read(str(BASE / 'current/exit.txt')) == b'0\n'
    assert gzip.decompress(read(str(BASE / 'current/stderr.log.gz'))) == b''
    capsule(str(BASE / 'current/inputs-before-reader.tar.gz'), json.loads(read(str(BASE / 'current/identities.json'))))
    current = json.loads(read(str(BASE / 'current/result.json')))
    assert current['current_inputs'] == 'PASS'
    assert current['declared_inputs'] == len(epochs['direct'][0])
    assert gzip.decompress(read(str(BASE / 'current/stdout.log.gz'))) == read(str(BASE / 'current/result.json'))
    assert read(str(BASE / 'intake/native-exit.txt')) == b'0\n'
    assert channel('intake', 'native', 'stderr') == b''
    assert channel('intake', 'version', 'stdout') == b'julia version 1.12.7\n'
    old, new = epochs['before'][0][OWNER], epochs['after'][0][OWNER]
    runner_old, runner_new = epochs['before'][0][RUNNER], epochs['after'][0][RUNNER]
    assert old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert runner_old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + RUNNER], cwd=ROOT)
    source_oracle(old, new, runner_old, runner_new)
    for phase in ('rehearse', 'apply'):
        assert read(str(BASE / 'repair-run' / (phase + '-exit.txt'))) == b'0\n'
        assert gzip.decompress(read(str(BASE / 'repair-run' / (phase + '-stderr.log.gz')))) == b''
    capsule(str(BASE / 'repair-run/inputs-before-writer.tar.gz'), json.loads(read(str(BASE / 'repair-run/identities.json'))))
    for name, body in (('owner-before', old), ('owner-after', new), ('runner-before', runner_old), ('runner-after', runner_new)):
        assert gzip.decompress(read(str(BASE / (name + '.jl.gz')))) == body
    patch = ''.join(''.join(difflib.unified_diff(a.decode().splitlines(True), b.decode().splitlines(True),
        fromfile=name, tofile=name)) for name, a, b in ((OWNER, old, new), (RUNNER, runner_old, runner_new)))
    assert read(str(BASE / 'source.diff')) == patch.encode()
    image = subprocess.check_output(['git', 'archive', ACTIVATION, 'julia', 'tests/fixtures',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec',
        'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
        'tools/run_julia_project_data.sh'], cwd=ROOT)
    original_sdk = {}
    metadata = json.loads(read(str(BASE / 'intake/custody.json')))[0]['files']
    with tarfile.open(fileobj=io.BytesIO(image)) as archive:
        for member in archive:
            if member.isfile():
                original_sdk[member.name] = archive.extractfile(member).read()
                # Git records executable class, not complete filesystem mode.
                assert bool(member.mode & 0o111) == bool(metadata[member.name]['mode'] & 0o111)
    selected = {name for name in epochs['intake'][0] if name.startswith(('julia/', 'tests/fixtures/', 'specs/', 'tools/')) and name != HELPER}
    assert selected == original_sdk.keys(), 'complete declared Git-origin census'
    assert cases[:45] == json.loads(original_sdk['tests/fixtures/array_transform_callable_result_guard_cases.json'])
    own = json.loads(read(str(BASE / 'own-questions.json')))
    assert cases[45:] == own and len(own) == 267
    allowed = {'id', 'source', 'body', 'input', 'rule', 'question', 'profile_only', 'paired_with', 'form'}
    assert all(set(row) <= allowed for row in own), 'source-only peer intake'
    common_pairs = {}
    pair_count = 0
    for phase, (inputs, products) in epochs.items():
        public_old = phase in ('intake', 'before')
        for name, original in original_sdk.items():
            wanted = old if name == OWNER and public_old else new if name == OWNER else runner_old if name == RUNNER and public_old else runner_new if name == RUNNER else original
            assert inputs[name] == wanted, (phase, name)
            if phase.startswith('private-') and name.startswith(('julia/', 'tests/', 'specs/')):
                private_wanted = old if name == OWNER and phase == 'private-old' else wanted
                assert inputs[CONTROL + name] == private_wanted
        assert inputs[HELPER] == epochs['intake'][0][HELPER]
        input_order(inputs[str(BASE / 'observer.jl')], 'observer')
        if phase != 'intake':
            input_order(inputs[NORMAL], 'normal')
            assert inputs[NORMAL] == epochs['before'][0][NORMAL]
            actual = frames(channel(phase, 'normal', 'stdout'), 'CALLABLE_TRANSFORM_JULIA_NORMAL')
            prior = phase in ('before', 'private-old')
            exact_records(actual, cold if prior else expected)
            assert read(str(BASE / phase / 'normal-exit.txt')) == (b'1\n' if prior else b'0\n')
            body = channel(phase, 'normal', 'stdout')
            pattern = rb'Julia callable Array-transform result guards\s*\|\s*1124\s+124\s+1248\s' if prior else rb'Julia callable Array-transform result guards\s*\|\s*1248\s+1248\s'
            assert re.search(pattern, body)
            sdk = CONTROL + 'julia' if phase.startswith('private-') else 'julia'
            loaded_owner(body, sdk)
            command = json.loads(read(str(BASE / phase / 'normal-command.json')))
            assert command['cwd'] == '.' and '--project=' + sdk in command['argv']
            assert command['environment']['LINKEDSPEC_CALLABLE_TRANSFORM_JULIA_CAPTURE'] == str(BASE / phase)
            assert command['environment']['JULIA_NUM_THREADS'] == '1'
            if phase.startswith('private-'):
                assert '--compiled-modules=no' in command['argv']
                assert inputs[CONTROL + NORMAL] == inputs[NORMAL] and inputs[CONTROL + HELPER] == inputs[HELPER]
                assert inputs[CONTROL + 'specs/user_function_definition.spec'] == inputs['specs/user_function_definition.spec']
                metadata = json.loads(read(str(BASE / phase / 'custody.json')))[0]['files']
                for name in inputs:
                    if name.startswith(CONTROL):
                        original = name[len(CONTROL):]
                        wanted = old if original == OWNER and phase == 'private-old' else inputs[original]
                        assert inputs[name] == wanted
                        assert metadata[name]['mode'] == metadata[original]['mode']
            profiles = json.loads(inputs[PROFILE])
            assert canonical({row['id']: row['expected'] for row in profiles}) == canonical(expected)
            assert json.loads(inputs[CASE_FILE]) == cases
        own_prefix = str(BASE / phase) + '/'
        for case in cases:
            key = case['id']
            pair = (products[own_prefix + 'parsed/' + key + '.json'], products[own_prefix + 'emitted/' + key + '.jl'])
            if phase == 'intake':
                common_pairs[key] = pair
            else:
                assert pair == common_pairs[key], (phase, key, 'parsed/emitted format drift')
            pair_count += 1
        assert len(products) == 624
        normal_channel_oracle(phase) if phase != 'intake' else None
    previous, fixed = epochs['private-old'][0], epochs['private-fixed'][0]
    assert {name for name in previous if name.startswith(CONTROL)} == {name for name in fixed if name.startswith(CONTROL)}
    assert [name for name in previous if name.startswith(CONTROL) and previous[name] != fixed[name]] == [CONTROL + OWNER]
    trace_inputs, trace_products = epoch('trace')
    input_order(trace_inputs[str(BASE / 'trace.jl')], 'trace')
    traces = frames(channel('trace', 'native', 'stdout'), 'CALLABLE_TRANSFORM_JULIA_TRACE')
    trace_cases = json.loads(read(str(BASE / 'trace-sources.json')))
    assert list(traces) == [case['id'] for case in trace_cases] and len(traces) == 9
    assert len(trace_products) == 18 and read(str(BASE / 'trace/native-exit.txt')) == b'0\n'
    for key, row in traces.items():
        assert canonical(row) == canonical(cold[key]['native'])
        assert trace_products[str(BASE / 'trace' / (key + '.parsed.json'))] == common_pairs[key][0]
        log = trace_products[str(BASE / 'trace' / (key + '.trace.log'))]
        assert b'julia_frontend:' in log and b'julia_compiler:compile_spec' in log and b'julia_runtime:' in log
    assert pair_count == 1872
    assert len(baseline['initial_policies']) == 104
    assert all(canonical(expected[key]) == canonical(cold[key]) for key in baseline['initial_policies'])
    direct = channel('direct', 'normal', 'stdout')
    assert re.search(rb'Julia ordinary Array-transform result guards\s*\|\s*903\s+903\s', direct)
    assert re.search(rb'Julia callable Array-pipeline result guards\s*\|\s*776\s+776\s', direct)
    for name in ('julia/test/array_transform_result_guard_composition_test.jl',
        'julia/test/array_pipeline_callable_result_guard_composition_test.jl',
        'tests/fixtures/array_transform_result_guard_julia_cases.json',
        'tests/fixtures/array_transform_result_guard_julia_profiles.json',
        'tests/fixtures/array_pipeline_callable_result_guard_julia_cases.json',
        'tests/fixtures/array_pipeline_callable_result_guard_julia_profiles.json'):
        assert name in epochs['direct'][0], 'direct-dependent fixture closure'
    assert read(str(BASE / 'remaining/complete.txt'))
    for phase in ('private-old', 'private-fixed', 'direct'):
        for tag in (phase, phase + '-check'):
            assert read(str(BASE / 'remaining' / (tag + '-exit.txt'))) == b'0\n'
            assert gzip.decompress(read(str(BASE / 'remaining' / (tag + '-stderr.log.gz')))) == b''
    for phase in ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct'):
        assert read(str(BASE / phase / 'memory-exit.txt')) == b'0\n'
        record = json.loads(read(str(BASE / phase / 'memory-command.json')))
        assert record == dict(argv=['bash', 'tools/project_data_run.sh', 'memory_pressure'], cwd='.', environment={})
        assert int(re.search(rb'System-wide memory free percentage: (\d+)%', channel(phase, 'memory', 'stdout'))[1]) >= 30
        assert channel(phase, 'memory', 'stderr') == b''
        assert channel(phase, 'version', 'stdout') == channel('intake', 'version', 'stdout')
    assert channel('trace', 'native', 'stderr') == b''
    for tag in COMPLETED_LAUNCHES:
        folder = BASE / 'launches' / tag
        inputs = capsule(str(folder / 'inputs.tar.gz'), json.loads(read(str(folder / 'identities.json'))))
        command = json.loads(read(str(folder / 'command.json')))
        assert command['cwd'] == '.' and command['environment'] == {}
        producers = [name for name in command['argv'] if name.endswith('.py')]
        assert producers and all(inputs[name] == read(name) for name in producers)
        assert read(str(folder / 'exit.txt')) == b'0\n'
        assert gzip.decompress(read(str(folder / 'stderr.log.gz'))) == b''
    retired = json.loads(read(str(BASE / 'retired-live-copies.json')))
    assert len(retired) == 18
    trace_metadata = json.loads(read(str(BASE / 'trace/custody.json')))[1]
    for row in retired:
        assert not (ROOT / row['path']).exists()
        assert row['identity'] == trace_metadata['files'][row['path']]
        assert row['archive'] == trace_metadata['archive']
    controls = []
    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective evidence control: ' + name)
    def changed(key, route, operation):
        rows = copy.deepcopy(expected)
        operation(rows[key][route])
        exact_records(rows, expected)
    # Establish mutation preconditions outside reject(), so a misspelled case or
    # absent error field cannot masquerade as an effective negative control.
    control_keys = ('take_receiver_hash_guard', 'take_later_with',
        'own_source_before_rejection', 'positive_take_receiver_composed',
        'positive_slice_receiver_composed', 'positive_concat_arrays_receiver_composed',
        'own_initial_number_take_receiver_with', 'own_scalar_bool_receiver_with',
        'own_extra_sorted_free', 'own_prior_count', 'own_nested_scalar_kinds',
        'own_needed_source_take_receiver', 'own_signature_fixed_missing_composed', 'source_once')
    assert all(key in expected for key in control_keys)
    assert expected['own_nested_scalar_kinds']['native']['value'][1][0] is False
    error = expected['own_needed_source_take_receiver']
    assert 'stage' in error['native']['error_json']['diagnostic']
    assert 'source_identity' in error['fresh']['error_json'] and 'detail' in error['plan']['error_json']
    assert 'invented' not in error['native']['error_json']
    reject('actual original guard results are RED', lambda: exact_records(cold, expected))
    for label, key, value in (
        ('Hash operands run', 'take_receiver_hash_guard', [None, 'KV']),
        ('later with runs', 'take_later_with', ['ran', 'W']),
        ('source S lost', 'own_source_before_rejection', [None, '']),
        ('count N lost', 'positive_take_receiver_composed', [None, 'S']),
        ('slice C lost', 'positive_slice_receiver_composed', [None, 'SN']),
        ('concat T lost', 'positive_concat_arrays_receiver_composed', [None, 'S']),
        ('valid empty initial with skipped', 'own_initial_number_take_receiver_with', [None, '']),
        ('Boolean receiver adopts free policy', 'own_scalar_bool_receiver_with', [0, 'W']),
        ('Julia excess sorted X omitted', 'own_extra_sorted_free', ['ran', 'SKVW']),
        ('earlier count owner runs with', 'own_prior_count', [None, 'W']),
    ):
        reject(label, lambda key=key, value=value: changed(key, 'native', lambda row: row.update(value=value)))
    reject('Boolean coerced to Number', lambda: changed('own_nested_scalar_kinds', 'native', lambda row: row['value'][1].__setitem__(0, 0)))
    error_key = 'own_needed_source_take_receiver'
    reject('native diagnostic stage omitted', lambda: changed(error_key, 'native', lambda row: row['error_json']['diagnostic'].pop('stage')))
    reject('generated source attribution omitted', lambda: changed(error_key, 'fresh', lambda row: row['error_json'].pop('source_identity')))
    reject('generated detail omitted', lambda: changed(error_key, 'plan', lambda row: row['error_json'].pop('detail')))
    reject('absent error field invented', lambda: changed(error_key, 'native', lambda row: row['error_json'].update(invented=True)))
    reject('invalid signature masked', lambda: changed('own_signature_fixed_missing_composed', 'native', lambda row: (row.clear(), row.update(value=None))))
    missing = copy.deepcopy(expected); missing.pop('source_once')
    reject('case omitted', lambda: exact_records(missing, expected))
    reject('private SDK aliased to public', lambda: loaded_owner(b'CALLABLE_TRANSFORM_JULIA_OWNER julia/src/LinkedSpecJulia.jl\n', CONTROL + 'julia'))
    reject('unrelated source edit', lambda: source_oracle(old, new + b'\n', runner_old, runner_new))
    normal_source = epochs['before'][0][NORMAL]
    late = normal_source.replace(b'write(path, serialized)', b'# late snapshot', 1) + b'\nwrite(path, serialized)\n'
    reject('parsed persistence after restoration', lambda: input_order(late, 'normal'))
    key = next(iter(common_pairs)); parsed, emitted = common_pairs[key]
    reject('parsed bytes drift', lambda: equal(parsed + b'\n', parsed))
    reject('emitted bytes drift', lambda: equal(emitted + b'\n', emitted))
    reject('actual stderr hidden', lambda: normal_channel_oracle('after', channel('after', 'normal', 'stderr') + b'warning'))
    return dict(recovery='PASS', programs=312, routes=4, normal_assertions=1248,
        supported_targets=28, separate_initial_compatibility=3, complete_preserved_records=281,
        initial_policies_exact=104, private_old_failed_groups=31, private_current_passed_groups=312,
        all_retained_pairs=pair_count, public_traces=9, direct_assertions=2927,
        current_declared_inputs=current['declared_inputs'], effective_corruptions=controls,
        limits='Finite historical full-wire/source/artifact proof; fresh Modules share Julia runtime/process. Older direct normals are semantic proof, without new custody credit for transient generated strings. Successful precompile/old Test error channels stay exact. Complete native/cache/transitive/toolchain/OS4.2/SESSION5, historical4.24/source/context/isolation/registration/declared5.4/formatter/full23.4 remain open.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
