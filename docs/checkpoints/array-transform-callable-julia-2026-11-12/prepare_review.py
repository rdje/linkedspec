"""Prepare an independent readonly Julia transform reader before its first run."""
from pathlib import Path
import json

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OLD = ROOT / 'docs/checkpoints/array-pipeline-callable-julia-2026-11-11'
assert (BASE / 'remaining/complete.txt').is_file()

def adapt(text):
    return (text.replace('array-pipeline-callable-julia-2026-11-11', BASE.name)
        .replace('580fe233a7d0299d177ecbd442ad8ba027bbe6da', '3767c87c7167bdcb29b0092be35bc139520e3509')
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))

source = adapt((OLD / 'review.py').read_text()).replace('import copy\n', 'import copy\nimport io\n', 1)
start = source.index('def semantic_oracle(')
end = source.index('\ndef exact_records(', start)
oracle = '''def semantic_oracle(cases, cold):
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

'''
source = source[:start] + oracle + source[end:]
old = '            _runtime_is_ordinary_array_transform_arguments(receiver.name, receiver.args)'
assert source.count(old) == 2
source = source.replace(old, '            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&\n            _runtime_is_ordinary_array_transform_arguments(receiver.args)')
source = source.replace("baseline['separate_pattern_compatibility']", "baseline['separate_initial_compatibility']").replace("== 174", "== 281")
start = source.index("    for folder in ('inspection', 'freeze'):")
end = source.index("    assert read(str(BASE / 'current/exit.txt'))", start)
source = source[:start] + source[end:]
start = source.index('    tracked_sdk = subprocess.check_output(')
end = source.index('    common_pairs = {}', start)
replacement = '''    image = subprocess.check_output(['git', 'archive', ACTIVATION, 'julia', 'tests/fixtures',
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
'''
source = source[:start] + replacement + source[end:]
source = source.replace("            if phase.startswith('private-'):\n                private_wanted", "            if phase.startswith('private-') and name.startswith(('julia/', 'tests/', 'specs/')):\n                private_wanted", 1)
source = source.replace(r'696\s+80\s+776\s', r'1124\s+124\s+1248\s').replace(r'776\s+776\s', r'1248\s+1248\s')
source = source.replace("        assert len(products) == 2 * (194 + (189 if phase == 'direct' else 0))", "        assert len(products) == 624\n        normal_channel_oracle(phase) if phase != 'intake' else None")
start = source.index("    for name, count in (('prior-transform', 173)")
end = source.index('    trace_inputs, trace_products', start)
source = source[:start] + source[end:]
source = source.replace('len(traces) == 8', 'len(traces) == 9').replace('len(trace_products) == 16', 'len(trace_products) == 18')
start = source.index('    controls = []')
end = source.index("\n\nif __name__", start)
controls = '''    assert pair_count == 1872
    assert len(baseline['initial_policies']) == 104
    assert all(canonical(expected[key]) == canonical(cold[key]) for key in baseline['initial_policies'])
    direct = channel('direct', 'normal', 'stdout')
    assert re.search(rb'Julia ordinary Array-transform result guards\\s*\\|\\s*903\\s+903\\s', direct)
    assert re.search(rb'Julia callable Array-pipeline result guards\\s*\\|\\s*776\\s+776\\s', direct)
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
            assert read(str(BASE / 'remaining' / (tag + '-exit.txt'))) == b'0\\n'
            assert gzip.decompress(read(str(BASE / 'remaining' / (tag + '-stderr.log.gz')))) == b''
    for phase in ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct'):
        assert read(str(BASE / phase / 'memory-exit.txt')) == b'0\\n'
        record = json.loads(read(str(BASE / phase / 'memory-command.json')))
        assert record == dict(argv=['bash', 'tools/project_data_run.sh', 'memory_pressure'], cwd='.', environment={})
        assert int(re.search(rb'System-wide memory free percentage: (\\d+)%', channel(phase, 'memory', 'stdout'))[1]) >= 30
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
        assert read(str(folder / 'exit.txt')) == b'0\\n'
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
    reject('private SDK aliased to public', lambda: loaded_owner(b'CALLABLE_TRANSFORM_JULIA_OWNER julia/src/LinkedSpecJulia.jl\\n', CONTROL + 'julia'))
    reject('unrelated source edit', lambda: source_oracle(old, new + b'\\n', runner_old, runner_new))
    normal_source = epochs['before'][0][NORMAL]
    late = normal_source.replace(b'write(path, serialized)', b'# late snapshot', 1) + b'\\nwrite(path, serialized)\\n'
    reject('parsed persistence after restoration', lambda: input_order(late, 'normal'))
    key = next(iter(common_pairs)); parsed, emitted = common_pairs[key]
    reject('parsed bytes drift', lambda: equal(parsed + b'\\n', parsed))
    reject('emitted bytes drift', lambda: equal(emitted + b'\\n', emitted))
    reject('actual stderr hidden', lambda: normal_channel_oracle('after', channel('after', 'normal', 'stderr') + b'warning'))
    return dict(recovery='PASS', programs=312, routes=4, normal_assertions=1248,
        supported_targets=28, separate_initial_compatibility=3, complete_preserved_records=281,
        initial_policies_exact=104, private_old_failed_groups=31, private_current_passed_groups=312,
        all_retained_pairs=pair_count, public_traces=9, direct_assertions=2927,
        current_declared_inputs=current['declared_inputs'], effective_corruptions=controls,
        limits='Finite historical full-wire/source/artifact proof; fresh Modules share Julia runtime/process. Older direct normals are semantic proof, without new custody credit for transient generated strings. Successful precompile/old Test error channels stay exact. Complete native/cache/transitive/toolchain/OS4.2/SESSION5, historical4.24/source/context/isolation/registration/declared5.4/formatter/full23.4 remain open.')
'''
source = source[:start] + controls + source[end:]
helper = '''
def normal_channel_oracle(phase, body=None):
    body = channel(phase, 'normal', 'stderr') if body is None else body
    row = json.loads(read(str(BASE / (phase + '-check.json'))))['actual_stderr']
    assert len(body) == row['bytes'] and digest(body) == row['sha256']
    if phase in ('before', 'private-old'):
        assert b'Some tests did not pass: 1124 passed, 124 failed, 0 errored, 0 broken.' in body
    elif phase == 'after':
        assert body.startswith(b'Precompiling packages...\\n') and b'1 dependency successfully precompiled' in body and b'ERROR' not in body
    else:
        assert body == b''

'''
source = source.replace('\ndef main():', helper + '\ndef main():', 1)
completed = sorted(path.name for path in (BASE / 'launches').iterdir())
source = source.replace("ROUTES = ('native', 'restored', 'plan', 'fresh')", "ROUTES = ('native', 'restored', 'plan', 'fresh')\nCOMPLETED_LAUNCHES = " + repr(tuple(completed)))
assert not (BASE / 'review.py').exists()
(BASE / 'review.py').write_text(source)
for name in ('check_current.py', 'capture_current.py', 'seal.py'):
    target = BASE / name
    assert not target.exists()
    target.write_text(adapt((OLD / name).read_text()))
print('Prepared independent historical reader and activation/current wrappers; no review or SDK replay executed')
