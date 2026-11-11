"""Readonly Julia evidence oracle; imports no SDK, capture producer or policy writer."""
import copy
import difflib
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-callable-julia-2026-11-11')
ACTIVATION = '580fe233a7d0299d177ecbd442ad8ba027bbe6da'
OWNER = 'julia/src/runtime/Interpreter.jl'
RUNNER = 'julia/test/runtests.jl'
NORMAL = 'julia/test/array_pipeline_callable_result_guard_composition_test.jl'
HELPER = 'julia/test/callable_array_pipeline_observation.jl'
CASE_FILE = 'tests/fixtures/array_pipeline_callable_result_guard_julia_cases.json'
PROFILE = 'tests/fixtures/array_pipeline_callable_result_guard_julia_profiles.json'
CONTROL = str(BASE / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')


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
    assert list(cold) == [case['id'] for case in cases]
    assert len(cases) == 194 and all(set(row) == set(ROUTES) for row in cold.values())
    expected = copy.deepcopy(cold)
    supported, compatibility = [], []
    for index, case in enumerate(cases):
        key = case['id']
        if index < 37:
            if 'expected' in case:
                expected[key] = value_record(case['expected'])
                if canonical(expected[key]) != canonical(cold[key]):
                    supported.append(key)
            elif 'expected_error' in case:
                assert all(case['expected_error'] in cold[key][route]['error'] for route in ROUTES)
        elif case.get('question') == 'regex-error-policy' and key == 'invalid_range_receiver_composed':
            assert canonical(cold[key]) == canonical(value_record([]))
            expected[key] = value_record(None)
            supported.append(key)
        elif case.get('question') == 'function-signature-valid' and case['form'] == 'composed':
            terminal = key[:-len('_composed')] + '_terminal'
            terminal_value = cold[terminal]['native']['value']
            assert canonical(cold[terminal]) == canonical(value_record(terminal_value))
            expected[key] = value_record([None, terminal_value[1]])
            supported.append(key)
        elif case.get('form') == 'composed' and key.startswith('own_pattern_') and 'needed_error' not in key:
            terminal = key[:-len('_composed')] + '_terminal'
            terminal_value = cold[terminal]['native']['value']
            assert canonical(cold[terminal]) == canonical(value_record(terminal_value))
            expected[key] = value_record([None, terminal_value[1]])
            (supported if case['question'] == 'canonical-pattern' else compatibility).append(key)
        question = case.get('question')
        if question in ('initial-source', 'initial-source-with', 'excluded-extra-arity', 'excluded-missing-arity', 'earlier-owner'):
            if question == 'initial-source':
                wanted = []
            elif question == 'initial-source-with':
                wanted = [0, 'W']
            elif question == 'excluded-extra-arity':
                wanted = ['ran', 'SXKW']
            elif question == 'excluded-missing-arity':
                wanted = [['h', 'e', 'a', 'd'], 'W'] if key.startswith('missing_operand_split_each_') else [[], 'W']
            else:
                wanted = [['a'], 'W'] if key == 'prior_view' else [None, '']
            assert canonical(cold[key]) == canonical(value_record(wanted))
        if question in ('needed-source-error', 'needed-delimiter-error', 'function-signature-invalid'):
            for route in ROUTES:
                row = cold[key][route]
                assert 'error_json' in row and isinstance(row['error_json'], dict)
                if route in ('native', 'restored'):
                    assert row['class'] == 'RuntimeInterpreterException'
                    assert row['error_json']['message'] == row['error']
                    assert row['error_json']['diagnostic']['stage'] == 'runtime_execution'
                else:
                    assert row['class'] == 'GeneratedSourceException'
                    assert row['error_json']['source_identity'] == 'callable-array-pipeline/' + key + '.spec'
                    assert 'stage' in row['error_json'] and 'code' in row['error_json'] and 'detail' in row['error_json']
    assert len(supported) == 17 and len(compatibility) == 3
    changed = [key for key in cold if canonical(cold[key]) != canonical(expected[key])]
    assert set(changed) == set(supported + compatibility)
    return expected, supported, compatibility


def exact_records(actual, expected):
    assert list(actual) == list(expected)
    assert canonical(actual) == canonical(expected)


def source_oracle(before, after, runner_before, runner_after):
    old = b'''    if receiver isa ActionCallExpr
        has_user_function_name(engine.compiled_spec.function_registry, receiver.name) && return false
        if something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_ordinary_array_pipeline_arguments(receiver.name, receiver.args)
'''
    new = b'''    # Invocation keeps its arity checks and caller effects. A canonical pipeline
    # prefix owns the produced result without becoming an unregistered free call.
    if receiver isa ActionCallExpr
        if !has_user_function_name(engine.compiled_spec.function_registry, receiver.name) &&
            something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_ordinary_array_pipeline_arguments(receiver.name, receiver.args)
'''
    assert before.count(old) == 1 and after == before.replace(old, new)
    include = b'include("array_pipeline_result_guard_composition_test.jl")\n'
    added = b'include("array_pipeline_callable_result_guard_composition_test.jl")\n'
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
    assert ('CALLABLE_PIPELINE_JULIA_OWNER ' + sdk + '/src/LinkedSpecJulia.jl\n').encode() in body


def main():
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
    cases = json.loads(read(str(BASE / 'cases.json')))
    epochs = {name: epoch(name) for name in ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct')}
    cold = frames(channel('intake', 'native', 'stdout'), 'CALLABLE_PIPELINE_JULIA')
    expected, supported, compatibility = semantic_oracle(cases, cold)
    baseline = json.loads(read(str(BASE / 'baseline.json')))
    assert canonical(baseline['observed']) == canonical(cold)
    assert canonical(baseline['expected']) == canonical(expected)
    assert baseline['supported_targets'] == supported and baseline['separate_pattern_compatibility'] == compatibility
    assert len(baseline['preserved']) == 174 and set(baseline['preserved']) == set(cold) - set(supported + compatibility)
    for folder in ('inspection', 'freeze'):
        assert read(str(BASE / folder / 'exit.txt')) == b'0\n'
        assert gzip.decompress(read(str(BASE / folder / 'stderr.log.gz'))) == b''
        capsule(str(BASE / folder / 'inputs-before-read.tar.gz'), json.loads(read(str(BASE / folder / 'identities.json'))))
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
    tracked_sdk = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ACTIVATION, '--', 'julia'], cwd=ROOT, text=True).splitlines()
    original_sdk = {name: subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT) for name in tracked_sdk}
    common_pairs = {}
    pair_count = 0
    for phase, (inputs, products) in epochs.items():
        public_old = phase in ('intake', 'before')
        for name, original in original_sdk.items():
            wanted = old if name == OWNER and public_old else new if name == OWNER else runner_old if name == RUNNER and public_old else runner_new if name == RUNNER else original
            assert inputs[name] == wanted, (phase, name)
            if phase.startswith('private-'):
                private_wanted = old if name == OWNER and phase == 'private-old' else wanted
                assert inputs[CONTROL + name] == private_wanted
        assert inputs[HELPER] == epochs['intake'][0][HELPER]
        input_order(inputs[str(BASE / 'observer.jl')], 'observer')
        if phase != 'intake':
            input_order(inputs[NORMAL], 'normal')
            assert inputs[NORMAL] == epochs['before'][0][NORMAL]
            actual = frames(channel(phase, 'normal', 'stdout'), 'CALLABLE_PIPELINE_JULIA_NORMAL')
            prior = phase in ('before', 'private-old')
            exact_records(actual, cold if prior else expected)
            assert read(str(BASE / phase / 'normal-exit.txt')) == (b'1\n' if prior else b'0\n')
            body = channel(phase, 'normal', 'stdout')
            pattern = rb'Julia callable Array-pipeline result guards\s*\|\s*696\s+80\s+776\s' if prior else rb'Julia callable Array-pipeline result guards\s*\|\s*776\s+776\s'
            assert re.search(pattern, body)
            sdk = CONTROL + 'julia' if phase.startswith('private-') else 'julia'
            loaded_owner(body, sdk)
            command = json.loads(read(str(BASE / phase / 'normal-command.json')))
            assert command['cwd'] == '.' and '--project=' + sdk in command['argv']
            assert command['environment']['LINKEDSPEC_CALLABLE_PIPELINE_JULIA_CAPTURE'] == str(BASE / phase)
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
        assert len(products) == 2 * (194 + (189 if phase == 'direct' else 0))
    previous, fixed = epochs['private-old'][0], epochs['private-fixed'][0]
    assert {name for name in previous if name.startswith(CONTROL)} == {name for name in fixed if name.startswith(CONTROL)}
    assert [name for name in previous if name.startswith(CONTROL) and previous[name] != fixed[name]] == [CONTROL + OWNER]
    for name, count in (('prior-pipeline', 173), ('prior-key-count', 16)):
        prefix = str(BASE / 'direct' / name) + '/'
        products = epochs['direct'][1]
        assert sum(path.startswith(prefix + 'parsed/') for path in products) == count
        assert sum(path.startswith(prefix + 'emitted/') for path in products) == count
        pair_count += count
    trace_inputs, trace_products = epoch('trace')
    input_order(trace_inputs[str(BASE / 'trace.jl')], 'trace')
    traces = frames(channel('trace', 'native', 'stdout'), 'CALLABLE_PIPELINE_JULIA_TRACE')
    trace_cases = json.loads(read(str(BASE / 'trace-sources.json')))
    assert list(traces) == [case['id'] for case in trace_cases] and len(traces) == 8
    assert len(trace_products) == 16 and read(str(BASE / 'trace/native-exit.txt')) == b'0\n'
    for key, row in traces.items():
        assert canonical(row) == canonical(cold[key]['native'])
        assert trace_products[str(BASE / 'trace' / (key + '.parsed.json'))] == common_pairs[key][0]
        log = trace_products[str(BASE / 'trace' / (key + '.trace.log'))]
        assert b'julia_frontend:' in log and b'julia_compiler:compile_spec' in log and b'julia_runtime:' in log
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

    wrong = copy.deepcopy(expected); wrong['trim_each_receiver_hash_guard'] = cold['trim_each_receiver_hash_guard']
    reject('original wrong consumer accepted as repaired', lambda: exact_records(wrong, expected))
    missing = copy.deepcopy(expected); missing.pop('trim_each_receiver_hash_guard')
    reject('case omitted', lambda: exact_records(missing, expected))
    reject('source-once effect lost', lambda: changed('own_signature_variadic_multi_composed', 'native', lambda row: row.update(value=[None, ''])))
    reject('noncanonical block producer effect lost', lambda: changed('own_pattern_block_composed', 'native', lambda row: row.update(value=[None, ''])))
    reject('initial source fallback changed', lambda: changed('initial_number_trim_each_receiver', 'native', lambda row: row.update(value=None)))
    reject('excess free argument effect omitted', lambda: changed('extra_trim_each_free', 'native', lambda row: row.update(value=['ran', 'SKW'])))
    reject('missing split edge fields fabricated', lambda: changed('missing_operand_split_each_receiver', 'native', lambda row: row.update(value=[['', 'h', 'e', 'a', 'd', ''], 'W'])))
    reject('earlier owner runs with', lambda: changed('prior_count', 'native', lambda row: row.update(value=[None, 'W'])))
    reject('Boolean preservation coerced to Number', lambda: changed('nested_scalar_kinds', 'native', lambda row: row['value'][1].__setitem__(0, 0)))
    error_key = 'needed_source_trim_each_receiver'
    reject('native diagnostic stage omitted', lambda: changed(error_key, 'native', lambda row: row['error_json']['diagnostic'].pop('stage')))
    reject('generated source identity omitted', lambda: changed(error_key, 'fresh', lambda row: row['error_json'].pop('source_identity')))
    reject('generated detail omitted', lambda: changed(error_key, 'plan', lambda row: row['error_json'].pop('detail')))
    reject('invalid function signature masked as null', lambda: changed('own_signature_fixed_missing_composed', 'native', lambda row: (row.clear(), row.update(value=None))))
    reject('private SDK replaced by public alias', lambda: loaded_owner(b'CALLABLE_PIPELINE_JULIA_OWNER julia/src/LinkedSpecJulia.jl\n', CONTROL + 'julia'))
    reject('unrelated interpreter edit admitted', lambda: source_oracle(old, new + b'\n', runner_old, runner_new))
    normal_source = epochs['before'][0][NORMAL]
    wrong_order = normal_source.replace(b'write(path, serialized)', b'# no first-use persistence', 1) + b'\nwrite(path, serialized)\n'
    reject('parsed persistence moved after restoration', lambda: input_order(wrong_order, 'normal'))
    key = next(iter(common_pairs)); parsed, emitted = common_pairs[key]
    reject('parsed artifact drift', lambda: equal(parsed + b'\n', parsed))
    assert len(controls) == 17
    return dict(recovery='PASS', programs=194, routes=4, assertions=776,
        supported_targets=17, separate_pattern_compatibility=3, complete_preserved_records=174,
        private_old_failed_groups=20, private_current_passed_groups=194,
        retained_own_pairs=1164, retained_direct_prior_pairs=189, all_retained_pairs=pair_count,
        public_traces=8, current_declared_inputs=current['declared_inputs'], effective_corruptions=controls,
        limits='Finite historical source/data proof. Fresh modules share Julia runtime/process. Complete native/cache/transitive/toolchain custody4.2/SESSION5, historical4.24, broader source/context/admission and full23.4 remain separate; old omitted fields stay unknown.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
