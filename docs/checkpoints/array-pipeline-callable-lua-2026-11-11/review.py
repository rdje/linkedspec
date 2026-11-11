"""Independent readonly installed-Lua source/data oracle; no SDK or producer imports."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-callable-lua-2026-11-11')
ACTIVATION = '9a6b229ce3f944ef3822e71935b1c40c109f74b9'
OWNER = 'lua/src/linkedspec/interpreter.lua'
RUNNER = 'lua/test/run.lua'
NORMAL = 'lua/test/array_pipeline_callable_result_guard_composition_test.lua'
HELPER = 'lua/test/callable_array_pipeline_observation.lua'
CONTROL = str(BASE / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')
HOSTS = ('puc', 'luajit')


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
    files = {}
    with tarfile.open(ROOT / folder / archive) as source:
        for member in source:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in files
            body = source.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == rows.keys()
    return files, rows


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


def value_record(value):
    return {route: dict(value=copy.deepcopy(value)) for route in ROUTES}


def semantics(cases, cold):
    assert list(cold) == [case['id'] for case in cases]
    assert len(cases) == 194 and all(set(row) == set(ROUTES) for row in cold.values())
    expected = copy.deepcopy(cold)
    targets, compatibility = [], []
    for index, case in enumerate(cases):
        key, question = case['id'], case.get('question')
        assert '[z-a]' not in case['source'] and 'invalid_range' not in key
        if index < 37:
            if 'expected' in case:
                expected[key] = value_record(case['expected'])
                if canonical(expected[key]) != canonical(cold[key]):
                    targets.append(key)
            elif 'expected_error' in case:
                assert all(case['expected_error'] in cold[key][route]['error'] for route in ROUTES)
        elif question == 'function-signature-valid' and case['form'] == 'composed':
            terminal = key.removesuffix('_composed') + '_terminal'
            value = cold[terminal]['native']['value']
            assert canonical(cold[terminal]) == canonical(value_record(value))
            expected[key] = value_record([None, value[1]])
            targets.append(key)
        elif key.startswith('own_pattern_') and case['form'] == 'composed' and 'needed_error' not in key:
            terminal = key.removesuffix('_composed') + '_terminal'
            value = cold[terminal]['native']['value']
            assert canonical(cold[terminal]) == canonical(value_record(value))
            assert value[0] == (['head'] if question == 'canonical-pattern' else [])
            expected[key] = value_record([None, value[1]])
            (targets if question == 'canonical-pattern' else compatibility).append(key)
        policies = {'initial-source': [], 'initial-source-with': [0, 'W'], 'excluded-extra-arity': ['ran', 'SXKW']}
        if question in policies:
            assert canonical(cold[key]) == canonical(value_record(policies[question]))
        elif question == 'excluded-missing-arity':
            value = [['h', 'e', 'a', 'd'], 'W'] if key.startswith('missing_operand_split_each_') else [[], 'W']
            assert canonical(cold[key]) == canonical(value_record(value))
        elif question == 'earlier-owner':
            value = [['a'], 'W'] if key == 'prior_view' else [None, '']
            assert canonical(cold[key]) == canonical(value_record(value))
        if question in ('needed-source-error', 'needed-delimiter-error', 'needed-pattern-error', 'function-signature-invalid'):
            for route in ROUTES:
                row = cold[key][route]
                assert 'error_json' in row and isinstance(row['error_json'], dict)
                if route in ('native', 'restored'):
                    assert row['runtime'] is True and row['generated'] is False
                    stage = 'user_function_call' if question == 'function-signature-invalid' else 'runtime_execution'
                    assert row['error_json']['diagnostic']['stage'] == stage
                    assert row['code'] == ('user_function_arity_mismatch' if question == 'function-signature-invalid' else 'binding_kind_mismatch')
                else:
                    assert row['generated'] is True and row['runtime'] is False
                    assert row['error_json']['source_identity'] == 'callable-array-pipeline/' + key + '.spec'
                    assert 'code' in row['error_json'] and 'detail' in row['error_json']
    assert len(targets) == 16 and len(compatibility) == 3
    assert sum(canonical(cold[key]) != canonical(expected[key]) for key in cold) == 19
    return expected, targets, compatibility


def exact(actual, expected):
    assert list(actual) == list(expected)
    assert canonical(actual) == canonical(expected)


def source_scope(old, new, runner_old, runner_new):
    before = b'''  if expr ~= nil and expr.kind == "call" then
    if engine.compiled_spec.function_registry:has_name(expr.name) then return false end
    if (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_pipeline_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(expr.name, expr.args, false) then
'''
    after = b'''  -- Invocation keeps its arity checks and caller effects. A canonical pipeline
  -- prefix owns the produced result without becoming an unregistered free call.
  if expr ~= nil and expr.kind == "call" then
    if not engine.compiled_spec.function_registry:has_name(expr.name) and
      (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_pipeline_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_pipeline_arguments(expr.name, expr.args, false) then
'''
    assert old.count(before) == 1 and new == old.replace(before, after)
    anchor = b'''test("Ordinary Array-pipeline result guards", function()
  dofile("lua/test/array_pipeline_result_guard_composition_test.lua")
end)
'''
    added = b'''test("Callable Array-pipeline result guards", function()
  dofile("lua/test/array_pipeline_callable_result_guard_composition_test.lua")
end)
'''
    assert runner_old.count(anchor) == 1 and runner_new == runner_old.replace(anchor, anchor + added)
    assert after.count(b'local ') == before.count(b'local ') == 0


def order(source, normal=False):
    if normal:
        parts = (b'local serialized = retained_input(output, "parsed"', b'local restored_spec = l.spec_ast.from_json', b'local compiled = l.compile_spec(parsed)')
    else:
        parts = (b'local retained = persist("parsed"', b'local restored_spec = l.spec_ast.from_json', b'local compiled = l.compile_spec(parsed)')
    positions = [source.index(part) for part in parts]
    assert positions == sorted(set(positions))


def owner_route(body, prefix=''):
    assert ('CALLABLE_PIPELINE_LUA_OWNER @' + prefix + OWNER + '\n').encode() in body


def main():
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    cases = json.loads(read(str(BASE / 'cases.json')))
    baseline = json.loads(read(str(BASE / 'baseline.json')))
    assert read(str(BASE / 'current/exit.txt')) == b'0\n'
    assert gzip.decompress(read(str(BASE / 'current/stderr.log.gz'))) == b''
    current = json.loads(read(str(BASE / 'current/result.json')))
    assert current['current_inputs'] == 'PASS'
    phases = ('intake', 'before', 'after', 'inverse', 'restored', 'direct')
    roots = {phase: unpack(BASE / phase)[0] for phase in phases}
    old, new = roots['before'][OWNER], roots['after'][OWNER]
    runner_old, runner_new = roots['before'][RUNNER], roots['after'][RUNNER]
    assert old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert runner_old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + RUNNER], cwd=ROOT)
    source_scope(old, new, runner_old, runner_new)
    sdk_names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ACTIVATION, '--', 'lua'], cwd=ROOT, text=True).splitlines()
    sdk_original = {name: subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT) for name in sdk_names}
    for phase, inputs in roots.items():
        public_old = phase in ('intake', 'before')
        for name, source in sdk_original.items():
            wanted = (old if public_old else new) if name == OWNER else (runner_old if public_old else runner_new) if name == RUNNER else source
            assert inputs[name] == wanted, (phase, name)
        assert inputs[HELPER] == roots['intake'][HELPER]
        order(inputs[str(BASE / 'observer.lua')])
        if phase != 'intake':
            order(inputs[NORMAL], True)
            assert inputs[NORMAL] == roots['before'][NORMAL]
        if phase in ('inverse', 'restored'):
            metadata = json.loads(read(str(BASE / phase / 'input-identities.json')))
            for name in inputs:
                if name.startswith(CONTROL):
                    original = name[len(CONTROL):]
                    wanted = old if original == OWNER and phase == 'inverse' else inputs[original]
                    assert inputs[name] == wanted and metadata[name]['mode'] == metadata[original]['mode']
    private_old, private_new = roots['inverse'], roots['restored']
    assert {name for name in private_old if name.startswith(CONTROL)} == {name for name in private_new if name.startswith(CONTROL)}
    assert [name for name in private_old if name.startswith(CONTROL) and private_old[name] != private_new[name]] == [CONTROL + OWNER]
    common, native_original, totals = {}, {}, {}
    for host in HOSTS:
        cold_folder = BASE / 'intake' / host
        cold = frames(stream(cold_folder, 'normal', 'stdout'), 'CALLABLE_PIPELINE_LUA')
        expected, targets, compatibility = semantics(cases, cold)
        assert canonical(baseline[host]['observed']) == canonical(cold)
        assert canonical(baseline[host]['expected']) == canonical(expected)
        assert baseline[host]['supported_targets'] == targets and baseline[host]['separate_pattern_compatibility'] == compatibility
        assert len(baseline[host]['preserved']) == 175
        common[host] = {}
        pairs = 0
        for phase in phases:
            folder = BASE / phase / host
            body = stream(folder, 'normal', 'stdout')
            actual = frames(body, 'CALLABLE_PIPELINE_LUA' if phase == 'intake' else 'CALLABLE_PIPELINE_LUA_NORMAL')
            prior = phase in ('intake', 'before', 'inverse')
            exact(actual, cold if prior else expected)
            wanted_exit = b'1\n' if phase in ('before', 'inverse') else b'0\n'
            assert read(str(folder / 'normal-exit.txt')) == wanted_exit
            if phase != 'intake':
                assert re.search(rb'CALLABLE_PIPELINE_LUA_SUMMARY 1164 checks ' + (b'76' if prior else b'0') + rb' failures', body)
            prefix = CONTROL if phase in ('inverse', 'restored') else ''
            owner_route(body, prefix)
            command = json.loads(read(str(folder / 'normal-command.json')))
            assert command['cwd'] == '.' and command['environment']['LUA_PATH'].startswith(prefix + 'lua/src/?.lua;')
            products, product_rows = unpack(folder, 'native', 'native-before-first-run.tar.gz')
            by_name = {Path(name).name: value for name, value in products.items()}
            assert len(by_name) == 3
            if phase == 'intake':
                native_original[host] = by_name
                assert read(str(folder / 'build-exit.txt')) == b'0\n'
            else:
                assert by_name == native_original[host]
                reuse = json.loads(read(str(folder / 'native-reuse.json')))
                assert reuse['source_sha256'] == hashlib.sha256(read(str(BASE / 'intake' / host / 'native-before-first-run.tar.gz'))).hexdigest()
            artifacts, _ = unpack(folder, 'artifact', 'actual-emitted-parsed.tar.gz')
            assert len(artifacts) == 388
            for case in cases:
                key = case['id']
                pair = (artifacts[str(folder / 'parsed' / (key + '.json'))], artifacts[str(folder / 'emitted' / (key + '.lua'))])
                if phase == 'intake':
                    common[host][key] = pair
                else:
                    assert pair == common[host][key], (host, phase, key)
                pairs += 1
            if phase == 'direct':
                for tag, count in (('prior-pipeline', 173), ('prior-key-count', 16)):
                    prior_products, _ = unpack(folder, tag, tag + '-actual-inputs.tar.gz')
                    assert len(prior_products) == 2 * count
                    pairs += count
                assert stream(folder, 'normal', 'stderr') == b''
        totals[host] = dict(programs=194, supported_targets=16, separate_pattern_compatibility=3,
            complete_preserved_records=175, normal_checks=1164, private_old_failed_groups=19,
            private_current_passed_groups=194, retained_pairs=pairs)
    failure = json.loads(read(str(BASE / 'trace-failure/failure.json')))
    assert failure['outer_exit'] == failure['child_exit'] == 1 and failure['luajit'] == 'not attempted'
    assert read(str(BASE / 'trace/puc/trace-exit.txt')) == b'1\n'
    assert b'plain Lua tables are ambiguous' in stream(BASE / 'trace/puc', 'trace', 'stderr')
    partial, _ = unpack(BASE / 'trace-failure', 'partial', 'actual-partial-and-producers.tar.gz')
    assert partial[str(BASE / 'trace.lua')].count(b'local payloads = {}') == 1
    qualified = read(str(BASE / 'trace_qualified.lua'))
    assert qualified == partial[str(BASE / 'trace.lua')].replace(b'local payloads = {}', b'local payloads = json.array({})').replace(b'/trace/[a-z]+$', b'/traceq/[a-z]+$')
    trace_root, _ = unpack(BASE / 'traceq')
    for host in HOSTS:
        folder = BASE / 'traceq' / host
        assert read(str(folder / 'trace-exit.txt')) == b'0\n' and stream(folder, 'trace', 'stderr') == b''
        rows = frames(stream(folder, 'trace', 'stdout'), 'CALLABLE_PIPELINE_LUA_TRACE')
        assert len(rows) == 8
        artifacts, _ = unpack(folder, 'artifact', 'actual-trace-inputs.tar.gz')
        assert len(artifacts) == 24
        products, _ = unpack(folder, 'native', 'native-before-first-run.tar.gz')
        assert {Path(name).name: value for name, value in products.items()} == native_original[host]
        for key, row in rows.items():
            assert canonical(row) == canonical(baseline[host]['observed'][key]['native'])
            assert artifacts[str(folder / (key + '.parsed.json'))] == common[host][key][0]
            assert isinstance(json.loads(artifacts[str(folder / (key + '.compiled.json'))]), list)
            assert b'lua_runtime:' in artifacts[str(folder / (key + '.trace.log'))]
    for phase in ('rehearse', 'apply'):
        assert read(str(BASE / 'repair-run' / (phase + '-exit.txt'))) == b'0\n'
        assert gzip.decompress(read(str(BASE / 'repair-run' / (phase + '-stderr.log.gz')))) == b''
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective Lua evidence control: ' + name)

    expected = baseline['puc']['expected']

    def changed(key, route, operation):
        rows = copy.deepcopy(expected)
        operation(rows[key][route])
        exact(rows, expected)

    wrong = copy.deepcopy(expected); wrong['trim_each_receiver_hash_guard'] = baseline['puc']['observed']['trim_each_receiver_hash_guard']
    reject('original wrong consumer accepted as repaired', lambda: exact(wrong, expected))
    missing = copy.deepcopy(expected); missing.pop('trim_each_receiver_hash_guard')
    reject('case omitted', lambda: exact(missing, expected))
    reject('source effect lost', lambda: changed('own_signature_variadic_multi_composed', 'native', lambda row: row.update(value=[None, ''])))
    reject('pattern producer effect lost', lambda: changed('own_pattern_block_composed', 'native', lambda row: row.update(value=[None, ''])))
    reject('source fallback changed', lambda: changed('initial_number_trim_each_receiver', 'native', lambda row: row.update(value=None)))
    reject('excess free argument skipped', lambda: changed('extra_trim_each_free', 'native', lambda row: row.update(value=['ran', 'SKW'])))
    reject('split edge fields fabricated', lambda: changed('missing_operand_split_each_receiver', 'native', lambda row: row.update(value=[['', 'h', 'e', 'a', 'd', ''], 'W'])))
    reject('earlier owner runs with', lambda: changed('prior_count', 'native', lambda row: row.update(value=[None, 'W'])))
    reject('Boolean coerced to Number', lambda: changed('nested_scalar_kinds', 'native', lambda row: row['value'][1].__setitem__(0, 0)))
    key = 'needed_source_trim_each_receiver'
    reject('native diagnostic stage omitted', lambda: changed(key, 'native', lambda row: row['error_json']['diagnostic'].pop('stage')))
    reject('generated source identity omitted', lambda: changed(key, 'fresh', lambda row: row['error_json'].pop('source_identity')))
    reject('generated detail omitted', lambda: changed(key, 'plan', lambda row: row['error_json'].pop('detail')))
    reject('outer native arity code omitted', lambda: changed('own_signature_fixed_missing_composed', 'native', lambda row: row.pop('code')))
    reject('invalid signature masked as null', lambda: changed('own_signature_fixed_missing_composed', 'native', lambda row: (row.clear(), row.update(value=None))))
    reject('private owner replaced by alias', lambda: owner_route(b'CALLABLE_PIPELINE_LUA_OWNER @lua/src/linkedspec/interpreter.lua\n', CONTROL))
    reject('unrelated source edit admitted', lambda: source_scope(old, new + b'\n', runner_old, runner_new))
    reject('opaque native product changed', lambda: equal(next(iter(native_original['puc'].values())) + b'X', next(iter(native_original['puc'].values()))))
    reject('parsed product changed', lambda: equal(common['puc'][cases[0]['id']][0] + b'\n', common['puc'][cases[0]['id']][0]))
    assert len(controls) == 18
    return dict(recovery='PASS', hosts=totals, qualified_public_traces_per_host=8,
        current_declared_inputs=current['declared_inputs'], direct_checks_per_host=2254,
        first_trace='actual1 retained; no complete PASS credit', effective_corruptions=controls,
        limits='Finite historical source/native-product/data proof. Fresh modules share each Lua runtime/process. Complete native/transitive/toolchain/cache4.2/SESSION5, declared5.4, unsafe formatter2.3 and full source/context/portable admission remain separate.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
