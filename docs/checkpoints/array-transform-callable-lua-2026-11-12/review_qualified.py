"""Independent finite historical Lua oracle. No SDK, capture or policy-writer imports."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-callable-lua-2026-11-12')
ACTIVATION = 'fff959ef7e8896b5b97f311a276cabc4f5034551'
OWNER = 'lua/src/linkedspec/interpreter.lua'
RUNNER = 'lua/test/run.lua'
NORMAL = 'lua/test/array_transform_callable_result_guard_composition_test.lua'
HELPER = 'lua/test/callable_array_transform_observation.lua'
FIXTURE = 'tests/fixtures/array_transform_callable_result_guard_lua_cases.json'
PROFILE = 'tests/fixtures/array_transform_callable_result_guard_lua_profiles.json'
CONTROL = str(BASE / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')
HOSTS = ('puc', 'luajit')
WRAPPERS = ['tools/' + name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_lua_project_data.sh', 'build_lua_native.sh')]
GRAMMARS = ['specs/' + name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def equal(actual, expected):
    assert actual == expected


def read(name):
    path = PurePosixPath(name)
    assert not path.is_absolute() and '..' not in path.parts
    target = ROOT / name
    assert target.is_file() and not target.is_symlink()
    return target.read_bytes()


def unpack(folder, stem='input', archive='inputs-before-first-run.tar.gz'):
    rows = json.loads(read(str(folder / (stem + '-identities.json'))))
    return unpack_rows(folder / archive, rows), rows


def unpack_rows(path, rows):
    files = {}
    with tarfile.open(ROOT / path) as source:
        for member in source:
            key = PurePosixPath(member.name)
            assert member.isfile() and not key.is_absolute() and '..' not in key.parts and member.name not in files
            body = source.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == rows.keys()
    return files


def stream(folder, tag, channel):
    return gzip.decompress(read(str(folder / (tag + '-' + channel + '.log.gz'))))


def frames(body, prefix):
    result = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, raw = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(raw)
    return result


def values(value):
    return {route: dict(value=copy.deepcopy(value)) for route in ROUTES}


def exact(actual, expected):
    assert ((set(actual) == set(ROUTES) and set(expected) == set(ROUTES)) or list(actual) == list(expected)) and canonical(actual) == canonical(expected)


def semantics(cases, cold):
    assert list(cold) == [case['id'] for case in cases]
    assert len(cases) == 312 and all(set(row) == set(ROUTES) for row in cold.values())
    expected = copy.deepcopy(cold)
    targets, compatibility = [], []
    healthy = profiles = 0
    for case in cases[:45]:
        key = case['id']
        if 'expected' in case:
            wanted = values(case['expected'])
            if canonical(cold[key]) != canonical(wanted):
                targets.append(key)
            else:
                healthy += 1
            expected[key] = wanted
        elif 'expected_error' in case:
            assert all(case['expected_error'] in cold[key][route]['error'] for route in ROUTES)
            healthy += 1
        else:
            profiles += 1
    assert len(targets) == 12 and healthy == 26 and profiles == 7
    # Receiver defaults contrast with each host's own healthy free composition.
    for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
        prefix = 'own_optional_' + helper
        exact(cold[prefix + '_free_composed'], values([None, 'S']))
        exact(cold[prefix + '_receiver'], cold[prefix + '_free'])
        key = prefix + '_receiver_composed'
        expected[key] = copy.deepcopy(cold[prefix + '_free_composed'])
        targets.append(key)
    # Valid function/positive producers retain their actually observed S/N/C/T.
    terminal_keys = ['own_signature_variadic_' + form for form in ('empty', 'multi')]
    terminal_keys += ['positive_' + helper + '_receiver' for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')]
    for prefix in terminal_keys:
        key = prefix + '_composed'
        expected[key] = {}
        for route in ROUTES:
            array, effects = cold[prefix + '_terminal'][route]['value']
            assert isinstance(array, list) and effects in ('', 'S', 'SN', 'SNC', 'ST')
            expected[key][route] = dict(value=[None, effects])
        targets.append(key)
    targets.insert(19, 'own_source_before_rejection')
    expected['own_source_before_rejection'] = values([None, 'S'])
    for kind in ('number', 'null', 'hash'):
        key = 'initial_' + kind + '_composed'
        exact(cold['initial_' + kind + '_terminal'], values([[], []]))
        exact(cold['own_initial_' + kind + '_take_receiver_with'], values([0, 'W']))
        exact(cold[key], values(['ran', 'KVW']))
        expected[key] = values([None, ''])
        compatibility.append(key)
    changed = [row['id'] for row in cases if canonical(cold[row['id']]) != canonical(expected[row['id']])]
    assert len(targets) == 28 and len(compatibility) == 3 and set(changed) == set(targets + compatibility)
    assert all(canonical(cold[key][route]) != canonical(expected[key][route]) for key in changed for route in ROUTES)
    preserved = [row['id'] for row in cases if row['id'] not in changed]
    initial = [row['id'] for row in cases if row.get('question') in ('initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
    assert len(preserved) == 281 and len(initial) == 104 and set(initial) <= set(preserved)
    exact(cold['own_scalar_bool_receiver_with'], values([None, '']))
    exact(cold['own_scalar_bool_free_with'], values([0, 'W']))
    for form in ('free', 'receiver'):
        for helper in ('sorted', 'reversed'):
            exact(cold['own_extra_' + helper + '_' + form], values(['ran', 'SXKVW']))
    for case in cases:
        if case.get('question') in ('needed-source-error', 'needed-operand-error', 'signature-invalid-signature', 'function-arity-composed', 'function-arity-terminal'):
            for route in ROUTES:
                row = cold[case['id']][route]
                assert isinstance(row['error_json'], dict) and isinstance(row['error'], str)
                assert row['runtime'] is (route in ('native', 'restored'))
                assert row['generated'] is (route in ('plan', 'fresh'))
                if row['runtime']:
                    assert 'diagnostic' in row['error_json'] and 'code' in row
                else:
                    assert row['error_json']['source_identity'] == 'callable-array-transform/' + case['id'] + '.spec'
                    assert 'code' in row['error_json'] and 'detail' in row['error_json']
    return expected, targets, compatibility, preserved, initial


def source_scope(old, new, runner_old, runner_new):
    before = b'''  if expr ~= nil and expr.kind == "call" then
    if engine.compiled_spec.function_registry:has_name(expr.name) then return false end
    if (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_transform_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.args) then
'''
    after = b'''  -- Invocation keeps its arity checks and caller effects. A canonical transform
  -- prefix owns the produced result without becoming an unregistered free call.
  if expr ~= nil and expr.kind == "call" then
    if not engine.compiled_spec.function_registry:has_name(expr.name) and
      (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_transform_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.args) then
'''
    assert old.count(before) == 1 and new == old.replace(before, after)
    anchor = b'''test("Ordinary Array-transform result guards", function()
  dofile("lua/test/array_transform_result_guard_composition_test.lua")
end)
'''
    added = b'''test("Callable Array-transform result guards", function()
  dofile("lua/test/array_transform_callable_result_guard_composition_test.lua")
end)
'''
    assert runner_old.count(anchor) == 1 and runner_new == runner_old.replace(anchor, anchor + added)
    assert before.count(b'local ') == after.count(b'local ') == 0


def order(source, normal=False):
    first = b'local serialized = retained_input(output, "parsed"' if normal else b'local retained = persist("parsed"'
    parts = (first, b'local restored_spec = l.spec_ast.from_json', b'local compiled = l.compile_spec(parsed)')
    positions = [source.index(part) for part in parts]
    assert positions == sorted(set(positions))


def owner_route(body, prefix=''):
    assert ('CALLABLE_TRANSFORM_LUA_OWNER @' + prefix + OWNER + '\n').encode() in body


def field_boundary(rows):
    assert set(rows) == {'own_needed_source_take_receiver', 'own_signature_fixed_missing_composed'}
    binding = rows['own_needed_source_take_receiver']
    raw, public = binding['outer_values'], binding['published_json']
    assert set(binding['outer_field_names']) == set(raw) == {'message', 'diagnostic', 'code', 'identifier', 'expected_kind', 'actual_kind'}
    assert raw['identifier'] == 'items' and raw['expected_kind'] == 'array' and raw['actual_kind'] == 'scalar'
    assert public == {name: raw[name] for name in ('message', 'diagnostic')}
    assert binding['outer_change_is_not_serialized'] is True and binding['message_change_is_serialized'] is True
    arity = rows['own_signature_fixed_missing_composed']
    assert set(arity['outer_field_names']) == set(arity['outer_values']) == {'message', 'code', 'diagnostic', 'stage', 'helper_name', 'rule_label', 'handler_source_label'}
    assert arity['outer_values']['code'] == 'user_function_arity_mismatch'
    assert arity['published_json'] == {name: arity['outer_values'][name] for name in ('message', 'diagnostic')}
    assert arity['arity_fields_absent'] is True


def main():
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    assert not (ROOT / CONTROL).exists()
    cases = json.loads(read(str(BASE / 'cases.json')))
    baseline = json.loads(read(str(BASE / 'baseline.json')))
    current = json.loads(read(str(BASE / 'current/result.json')))
    assert current['current_inputs'] == 'PASS' and read(str(BASE / 'current/exit.txt')) == b'0\n'
    assert gzip.decompress(read(str(BASE / 'current/stderr.log.gz'))) == b''
    current_rows = json.loads(read(str(BASE / 'current/identities.json')))
    unpack_rows(BASE / 'current/inputs-before-reader.tar.gz', current_rows)
    phases = ('intake', 'before', 'after', 'inverse', 'restored', 'direct')
    roots, metadata = {}, {}
    for phase in phases:
        roots[phase], metadata[phase] = unpack(BASE / phase)
    origin = {}
    git_tar = subprocess.check_output(['git', 'archive', ACTIVATION, '--', 'lua', 'tests/fixtures', *GRAMMARS, *WRAPPERS], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(git_tar)) as archive:
        for member in archive:
            if member.isfile():
                origin[member.name] = (archive.extractfile(member).read(), bool(member.mode & 0o111))
    old, new = roots['before'][OWNER], roots['after'][OWNER]
    runner_old, runner_new = roots['before'][RUNNER], roots['after'][RUNNER]
    equal(old, origin[OWNER][0]); equal(runner_old, origin[RUNNER][0])
    source_scope(old, new, runner_old, runner_new)
    shared = json.loads(origin['tests/fixtures/array_transform_callable_result_guard_cases.json'][0])
    assert len(shared) == 45 and cases[:45] == shared
    own = json.loads(read(str(BASE / 'own-questions.json')))
    allowed = {'id', 'source', 'body', 'input', 'rule', 'question', 'profile_only', 'paired_with', 'form'}
    assert len(own) == 267 and cases[45:] == own and all(set(row) <= allowed and row['profile_only'] is True for row in own)
    assert roots['intake'][FIXTURE] == roots['direct'][FIXTURE] == read(str(BASE / 'cases.json'))
    for phase, inputs in roots.items():
        public_old = phase in ('intake', 'before')
        for name, (source, executable) in origin.items():
            wanted = (old if public_old else new) if name == OWNER else (runner_old if public_old else runner_new) if name == RUNNER else source
            assert inputs[name] == wanted, (phase, name)
            assert bool(metadata[phase][name]['mode'] & 0o111) == executable, (phase, name)
        equal(inputs[HELPER], roots['intake'][HELPER])
        order(inputs[str(BASE / 'observer.lua')])
        if phase != 'intake':
            order(inputs[NORMAL], True)
            equal(inputs[NORMAL], roots['before'][NORMAL])
            equal(inputs[PROFILE], roots['before'][PROFILE])
        if phase in ('inverse', 'restored'):
            for name in inputs:
                if name.startswith(CONTROL):
                    original = name[len(CONTROL):]
                    wanted = old if original == OWNER and phase == 'inverse' else inputs[original]
                    assert inputs[name] == wanted and metadata[phase][name]['mode'] == metadata[phase][original]['mode']
    private_old, private_new = roots['inverse'], roots['restored']
    assert {name for name in private_old if name.startswith(CONTROL)} == {name for name in private_new if name.startswith(CONTROL)}
    assert [name for name in private_old if name.startswith(CONTROL) and private_old[name] != private_new[name]] == [CONTROL + OWNER]
    profiles = json.loads(roots['before'][PROFILE])
    native_original, native_modes, common, totals, all_expected = {}, {}, {}, {}, {}
    for host in HOSTS:
        cold = frames(stream(BASE / 'intake' / host, 'normal', 'stdout'), 'CALLABLE_TRANSFORM_LUA')
        expected, targets, compatibility, preserved, initial = semantics(cases, cold)
        all_expected[host] = expected
        assert canonical(baseline[host]['observed']) == canonical(cold)
        assert canonical(baseline[host]['expected']) == canonical(expected)
        assert baseline[host]['supported_targets'] == targets and baseline[host]['separate_initial_compatibility'] == compatibility
        assert baseline[host]['preserved'] == preserved and baseline[host]['initial_policies'] == initial
        assert set(profiles[host]) == set(expected)
        for case in cases:
            row = profiles[host][case['id']]
            assert row['source'] == case['source']
            role = 'supported-target' if case['id'] in targets else 'initial-source-compatibility' if case['id'] in compatibility else 'preservation'
            assert row['role'] == role
            assert canonical({route: row[route] for route in ROUTES}) == canonical(expected[case['id']])
        common[host] = {}
        cold_folder = BASE / 'intake' / host
        for tag in ('memory', 'version', 'headers', 'build', 'normal'):
            assert read(str(cold_folder / (tag + '-exit.txt'))) == b'0\n'
            assert stream(cold_folder, tag, 'stderr') == b''
        versions = stream(cold_folder, 'headers', 'stdout').decode().splitlines()
        assert versions == (['5.5.1', '10.48'] if host == 'puc' else ['2.1.1788460057', '10.48'])
        assert versions[0].encode() in stream(cold_folder, 'version', 'stdout')
        pairs = 0
        for phase in phases:
            folder = BASE / phase / host
            body = stream(folder, 'normal', 'stdout')
            actual = frames(body, 'CALLABLE_TRANSFORM_LUA' if phase == 'intake' else 'CALLABLE_TRANSFORM_LUA_NORMAL')
            prior = phase in ('intake', 'before', 'inverse')
            exact(actual, cold if prior else expected)
            assert read(str(folder / 'normal-exit.txt')) == (b'1\n' if phase in ('before', 'inverse') else b'0\n')
            if phase != 'intake':
                assert re.search(rb'CALLABLE_TRANSFORM_LUA_SUMMARY 1872 checks ' + (b'124' if prior else b'0') + rb' failures', body)
                result = json.loads(read(str(BASE / (phase + '-check.json'))))[host]
                assert result['actual_parsed_module_pairs_exact'] == 312 and result['full_wire_records'] == 'PASS'
            prefix = CONTROL if phase in ('inverse', 'restored') else ''
            owner_route(body, prefix)
            command = json.loads(read(str(folder / 'normal-command.json')))
            assert command['cwd'] == '.' and command['environment']['LUA_PATH'].startswith(prefix + 'lua/src/?.lua;')
            products, product_rows = unpack(folder, 'native', 'native-before-first-run.tar.gz')
            by_name = {Path(name).name: value for name, value in products.items()}
            modes = {Path(name).name: product_rows[name]['mode'] for name in products}
            assert len(by_name) == 3
            if phase == 'intake':
                native_original[host], native_modes[host] = by_name, modes
                assert read(str(folder / 'build-exit.txt')) == b'0\n'
            else:
                assert by_name == native_original[host] and modes == native_modes[host]
                reuse = json.loads(read(str(folder / 'native-reuse.json')))
                assert reuse['source_sha256'] == hashlib.sha256(read(str(BASE / 'intake' / host / 'native-before-first-run.tar.gz'))).hexdigest()
            artifacts, _ = unpack(folder, 'artifact', 'actual-emitted-parsed.tar.gz')
            assert len(artifacts) == 624
            for case in cases:
                key = case['id']
                pair = (artifacts[str(folder / 'parsed' / (key + '.json'))], artifacts[str(folder / 'emitted' / (key + '.lua'))])
                if phase == 'intake':
                    common[host][key] = pair
                else:
                    equal(pair, common[host][key])
                pairs += 1
            stderr = stream(folder, 'normal', 'stderr')
            if phase in ('before', 'inverse'):
                assert b'take_receiver_hash_guard' in stderr
            else:
                equal(stderr, b'')
            if phase == 'direct':
                assert b'ARRAY_TRANSFORM_LUA_SUMMARY 903 checks 0 failures' in body
                assert b'CALLABLE_PIPELINE_LUA_SUMMARY 1164 checks 0 failures' in body
        totals[host] = dict(programs=312, supported_targets=28, separate_initial_compatibility=3, complete_preserved_records=281,
            initial_policies=104, normal_checks=1872, old_failed_groups=31, current_passed_groups=312, actual_retained_pairs=pairs)
    trace_inputs, _ = unpack(BASE / 'trace')
    probe_inputs, _ = unpack(BASE / 'fieldprobe')
    for name, (body, _) in origin.items():
        equal(trace_inputs[name], body)
        expected_body = new if name == OWNER else runner_new if name == RUNNER else body
        equal(probe_inputs[name], expected_body)
    probes = {}
    for host in HOSTS:
        for phase, tag, archive, count in (('trace', 'trace', 'actual-trace-inputs.tar.gz', 27), ('fieldprobe', 'probe', 'actual-parsed-inputs.tar.gz', 2)):
            folder = BASE / phase / host
            assert read(str(folder / (tag + '-exit.txt'))) == b'0\n' and stream(folder, tag, 'stderr') == b''
            products, product_rows = unpack(folder, 'native', 'native-before-first-run.tar.gz')
            assert {Path(name).name: body for name, body in products.items()} == native_original[host]
            assert {Path(name).name: product_rows[name]['mode'] for name in products} == native_modes[host]
            artifacts, _ = unpack(folder, 'artifact', archive)
            assert len(artifacts) == count
            if phase == 'trace':
                rows = frames(stream(folder, tag, 'stdout'), 'CALLABLE_TRANSFORM_LUA_TRACE')
                assert list(rows) == [row['id'] for row in json.loads(read(str(BASE / 'trace-sources.json')))] and len(rows) == 9
                for key, row in rows.items():
                    assert canonical(row) == canonical(baseline[host]['observed'][key]['native'])
                    equal(artifacts[str(folder / (key + '.parsed.json'))], common[host][key][0])
                    assert isinstance(json.loads(artifacts[str(folder / (key + '.compiled.json'))]), list)
                    assert b'lua_' in artifacts[str(folder / (key + '.trace.log'))]
            else:
                probes[host] = frames(stream(folder, tag, 'stdout'), 'LUA_FIELD_PROBE')
                field_boundary(probes[host])
                assert b'LUA_FIELD_OWNER @lua/src/linkedspec/interpreter.lua\n' in stream(folder, tag, 'stdout')
                for key in probes[host]:
                    equal(artifacts[str(folder / (key + '.parsed.json'))], common[host][key][0])
    for phase in ('rehearse', 'apply'):
        assert read(str(BASE / 'repair-run' / (phase + '-exit.txt'))) == b'0\n'
        assert gzip.decompress(read(str(BASE / 'repair-run' / (phase + '-stderr.log.gz')))) == b''
    retired = json.loads(read(str(BASE / 'retired-live-copies.json')))
    assert len(retired) == 58 and all(not (ROOT / name).exists() for name in retired)
    for name, row in retired.items():
        archive_rows = json.loads(read(str(Path(row['archive']).parent / 'artifact-identities.json')))
        assert all(row[field] == archive_rows[name][field] for field in ('bytes', 'sha256', 'mode'))
    completed_launches = json.loads(read(str(BASE / 'completed-launches.json')))
    completed_launches += [dict(name=name, actual_exit=0, stderr_bytes=0, stderr_sha256=hashlib.sha256(b'').hexdigest())
        for name in ('qualify-recovery-setup', 'current', 'retire-trace')]
    for launch in completed_launches:
        folder = BASE / 'launches' / launch['name']
        rows = json.loads(read(str(folder / 'identities.json')))
        unpack_rows(folder / 'inputs.tar.gz', rows)
        assert str(BASE / 'run_stage.py') in rows
        stderr = gzip.decompress(read(str(folder / 'stderr.log.gz')))
        assert read(str(folder / 'exit.txt')) == (str(launch['actual_exit']) + '\n').encode()
        assert len(stderr) == launch['stderr_bytes'] and hashlib.sha256(stderr).hexdigest() == launch['stderr_sha256']
        if launch['name'] == 'prepare-recovery':
            assert launch['actual_exit'] == 1 and b'FileNotFoundError' in stderr and b'launches/prepare-recovery/exit.txt' in stderr
        else:
            assert launch['actual_exit'] == 0 and stderr == b''
        command = json.loads(read(str(folder / 'command.json')))
        assert command['cwd'] == '.' and command['argv'] and command['environment'] == {}
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective evidence control: ' + name)

    expected = all_expected['puc']

    def changed(key, route, operation):
        row = copy.deepcopy(expected)
        operation(row[key][route])
        exact(row, expected)

    # Preconditions outside reject: absent keys cannot counterfeit effective RED.
    needed = 'own_needed_source_take_receiver'
    signature = 'own_signature_fixed_missing_composed'
    assert expected['take_receiver_hash_guard']['native']['value'] == [None, '']
    assert expected['positive_take_receiver_composed']['native']['value'] == [None, 'SN']
    assert expected['positive_slice_receiver_composed']['native']['value'] == [None, 'SNC']
    assert expected['positive_concat_arrays_receiver_composed']['native']['value'] == [None, 'ST']
    assert 'stage' in expected[needed]['native']['error_json']['diagnostic']
    assert 'source_identity' in expected[needed]['fresh']['error_json'] and 'detail' in expected[needed]['plan']['error_json']
    assert 'code' in expected[signature]['native'] and 'actual_arity' not in expected[signature]['native']
    wrong = copy.deepcopy(expected)
    wrong['take_receiver_hash_guard'] = baseline['puc']['observed']['take_receiver_hash_guard']
    reject('old Hash consumer admitted', lambda: exact(wrong, expected))
    missing = copy.deepcopy(expected); missing.pop('take_receiver_hash_guard')
    reject('case omitted', lambda: exact(missing, expected))
    reject('Hash and later with effects run', lambda: changed('take_later_with', 'native', lambda row: row.update(value=['ran', 'KVW'])))
    reject('source S omitted', lambda: changed('own_source_before_rejection', 'native', lambda row: row.update(value=[None, ''])))
    reject('count N omitted', lambda: changed('positive_take_receiver_composed', 'native', lambda row: row.update(value=[None, 'S'])))
    reject('slice C reordered', lambda: changed('positive_slice_receiver_composed', 'native', lambda row: row.update(value=[None, 'SCN'])))
    reject('concat T omitted', lambda: changed('positive_concat_arrays_receiver_composed', 'native', lambda row: row.update(value=[None, 'S'])))
    reject('initial with fallback changed', lambda: changed('own_initial_number_take_receiver_with', 'native', lambda row: row.update(value=[None, ''])))
    reject('Boolean receiver normalized to free', lambda: changed('own_scalar_bool_receiver_with', 'native', lambda row: row.update(value=[0, 'W'])))
    reject('excluded free X skipped', lambda: changed('own_extra_sorted_free', 'native', lambda row: row.update(value=['ran', 'SKVW'])))
    assert expected['own_prior_count']['native']['value'] == [None, '']
    reject('earlier owner runs with', lambda: changed('own_prior_count', 'native', lambda row: row.update(value=[None, 'W'])))
    nested = 'own_nested_scalar_kinds'
    assert expected[nested]['native']['value'][1][0] is False
    reject('Bool coerced to Number', lambda: changed(nested, 'native', lambda row: row['value'][1].__setitem__(0, 0)))
    reject('native diagnostic stage omitted', lambda: changed(needed, 'native', lambda row: row['error_json']['diagnostic'].pop('stage')))
    reject('generated source identity omitted', lambda: changed(needed, 'fresh', lambda row: row['error_json'].pop('source_identity')))
    reject('generated detail omitted', lambda: changed(needed, 'plan', lambda row: row['error_json'].pop('detail')))
    reject('outer native arity code omitted', lambda: changed(signature, 'native', lambda row: row.pop('code')))
    reject('absent numeric arity fabricated', lambda: changed(signature, 'native', lambda row: row.update(actual_arity=1)))
    reject('invalid signature masked as null', lambda: changed(signature, 'native', lambda row: (row.clear(), row.update(value=None))))
    reject('private owner replaced by alias', lambda: owner_route(b'CALLABLE_TRANSFORM_LUA_OWNER @lua/src/linkedspec/interpreter.lua\n', CONTROL))
    reject('unrelated source edit admitted', lambda: source_scope(old, new + b'\n', runner_old, runner_new))
    reject('opaque native product changed', lambda: equal(next(iter(native_original['puc'].values())) + b'X', next(iter(native_original['puc'].values()))))
    pair = common['puc'][cases[0]['id']]
    reject('parsed bytes changed', lambda: equal(pair[0] + b'\n', pair[0]))
    reject('emitted bytes changed', lambda: equal(pair[1] + b'\n', pair[1]))
    reject('successful stderr hidden', lambda: equal(b'unexpected stderr', b''))
    order(roots['after'][NORMAL], True)
    late = b'local restored_spec = l.spec_ast.from_json\nlocal compiled = l.compile_spec(parsed)\nlocal serialized = retained_input(output, "parsed"'
    reject('normal parsed snapshot moved after compilation', lambda: order(late, True))
    probe = copy.deepcopy(probes['puc'])
    assert probe[needed]['outer_change_is_not_serialized'] is True
    probe[needed]['outer_change_is_not_serialized'] = False
    reject('raw/public projection boundary erased', lambda: field_boundary(probe))
    assert len(controls) == 26
    return dict(recovery='PASS', hosts=totals, public_traces_per_host=9, native_field_probes_per_host=2,
        current_declared_inputs=current['declared_inputs'], direct_checks_per_host=3939, retired_plain_duplicates=58,
        effective_corruptions=controls, error_scope='Full published error JSON/text and named observer flags; not all raw native fields. Two native probes establish the projection boundary, not full312 raw-field closure;4.28 owns broader audit.',
        limits='Finite historical own-source/native-product/data proof. Fresh modules share each runtime/process. Older direct transient strings have no new custody credit. Full native/cache/transitive/toolchain/OS4.2/SESSION5, source/context/isolation/registration, declared5.4/formatter and full23.4 stay separate.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
