"""Readonly finite installed-Lua proof from actual source/native/artifact epochs."""
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
BASE = Path('docs/checkpoints/array-transform-result-guard-lua-2026-11-10')
ACTIVATION = '2bc6b3c1eef81b666df43166ef0504f52e8da719'
OWNER = 'lua/src/linkedspec/interpreter.lua'
RUNNER = 'lua/test/run.lua'
NORMAL = 'lua/test/array_transform_result_guard_composition_test.lua'
COMMON = 'tests/fixtures/array_transform_result_guard_cases.json'
FIXTURE = 'tests/fixtures/array_transform_result_guard_lua_cases.json'
PROFILE = 'tests/fixtures/array_transform_result_guard_lua_profiles.json'
GRAMMAR = 'specs/user_function_definition.spec'
HOSTS = ('puc', 'luajit')
PHASES = ('intake', 'before', 'after', 'direct', 'inverse', 'restored')
RED = {helper + '_' + form + '_hash_guard'
       for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted',
                      'reversed', 'concat_arrays') for form in ('free', 'receiver')}
RED |= {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
DIRECT_INPUTS = (NORMAL, COMMON, FIXTURE, PROFILE, GRAMMAR,
    'tests/fixtures/with_hash_result_values.spec', 'tests/fixtures/with_hash_result_values.json',
    'tests/fixtures/hash_value_result_guard_lua_cases.json',
    'tests/fixtures/hash_value_result_guard_lua_profiles.json',
    'tests/fixtures/hash_view_result_guard_lua_cases.json',
    'tests/fixtures/hash_view_result_guard_lua_profiles.json')


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def raw(phase, host, tag='normal', channel='stdout'):
    return gzip.decompress((ROOT / BASE / phase / host / (tag + '-' + channel + '.log.gz')).read_bytes())


def frames(body, tag='ARRAY_TRANSFORM_LUA_NORMAL'):
    result = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(value)
    return result


def recover(directory, stem='input'):
    names = {'input': 'inputs-before-first-run.tar.gz', 'artifact': 'actual-emitted-parsed.tar.gz',
             'native': 'native-before-first-run.tar.gz'}
    rows = json.loads((ROOT / BASE / directory / (stem + '-identities.json')).read_bytes())
    files = {}
    with tarfile.open(ROOT / BASE / directory / names[stem]) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in files
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == rows.keys()
    return files


def historical(paths):
    result = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
        input=''.join(ACTIVATION + ':' + name + '\n' for name in paths).encode(),
        stdout=subprocess.PIPE, check=True)
    position, files = 0, {}
    for name in paths:
        end = result.stdout.index(b'\n', position)
        header = result.stdout[position:end].split()
        assert header[1] == b'blob'
        size = int(header[2])
        position = end + 1
        files[name] = result.stdout[position:position + size]
        position += size + 1
    assert position == len(result.stdout)
    return files


def section(body, start, end):
    return body[body.index(start):body.index(end, body.index(start))]


def validate(rows, cases, profiles, before=False):
    assert list(rows) == [case['id'] for case in cases]
    for case in cases:
        key = case['id']
        actual = rows[key]
        assert set(actual) == {'native', 'restored', 'plan', 'fresh'}
        for route, value in actual.items():
            if before and key in RED:
                if key in {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}:
                    expected = ['ran', 'KVDW' if key == 'sort_logical_later_with' else 'KVW']
                else:
                    helper = key.rsplit('_', 3)[0]
                    compatible = next(row for row in cases if row['id'] == helper + '_compatible')
                    expected = [compatible['expected'][0], 'KV']
                assert same(value, {'value': expected}) and not same(value, {'value': case['expected']})
            elif key in profiles:
                assert profiles[key]['source'] == case['source'] and profiles[key]['input'] == case['input']
                assert same(value, profiles[key][route])
            else:
                assert same(value, {'value': case['expected']})
        assert same(actual['native'], actual['restored']) and same(actual['plan'], actual['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in value['error'] for value in actual.values())
            for route in ('native', 'restored'):
                assert actual[route]['runtime'] is True and actual[route]['generated'] is False
                assert actual[route]['code'] == 'binding_kind_mismatch'
                assert actual[route]['diagnostic_stage'] == 'runtime_execution'
            for route in ('plan', 'fresh'):
                assert actual[route]['generated'] is True and actual[route]['runtime'] is False
                assert actual[route]['code'] == 'generated_execution_failed'


def direct_inputs(files):
    for name in DIRECT_INPUTS:
        assert name in files


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
        if name.endswith('.gz'):
            gzip.decompress(body)
    inputs = {phase: recover(phase) for phase in PHASES}
    cases = json.loads(inputs['intake'][FIXTURE])
    profiles = json.loads(inputs['before'][PROFILE])
    assert len(cases) == 156 and cases[:37] == json.loads(inputs['intake'][COMMON])
    assert cases[37:] == json.loads(inputs['intake'][str(BASE / 'profile-sources.json')])
    assert len(cases[37:]) == 119 and sum(bool(row.get('expected_error')) for row in cases) == 19
    assert set(profiles) == set(HOSTS) and all(len(profiles[host]) == 123 for host in HOSTS)
    assert all(sum(row['profile_only'] for row in profiles[host].values()) == 119 for host in HOSTS)
    paths = sorted(name for name in inputs['intake'] if name.startswith('lua/') and name != NORMAL)
    old = historical(paths + [GRAMMAR, COMMON])
    original, changed = inputs['intake'][OWNER], inputs['after'][OWNER]
    assert original == old[OWNER] and changed != original
    normal = inputs['intake'][NORMAL]
    needle = b'test("Pure Hash-helper result guards", function()\n  dofile("lua/test/hash_value_result_guard_composition_test.lua")\nend)'
    addition = b'\ntest("Ordinary Array-transform result guards", function()\n  dofile("lua/test/array_transform_result_guard_composition_test.lua")\nend)'
    runner = old[RUNNER].replace(needle, needle + addition, 1)
    assert inputs['after'][RUNNER] == runner
    assert runner.count(b'dofile("lua/test/array_transform_result_guard_composition_test.lua")') == 1
    for start, end in ((b'local function evaluate_array_helper', b'local function evaluate_hash_helper'),
                       (b'local function evaluate_hash_helper', b'local function evaluate_hash_values'),
                       (b'    if scalar_result and not (preserve_initial_count_source', b'function typed_source.receiver_mutation.failure')):
        assert section(original, start, end) == section(changed, start, end)
    assert [line for line in original.splitlines() if line.startswith(b'local ')] == [line for line in changed.splitlines() if line.startswith(b'local ')]
    assert [line for line in original.splitlines() if b'scalar_result =' in line] == [line for line in changed.splitlines() if b'scalar_result =' in line]
    observations, pairs, versions, native_counts = {}, {}, {}, {}
    for phase in PHASES:
        files = inputs[phase]
        before = phase in ('intake', 'before')
        assert files[GRAMMAR] == old[GRAMMAR] and files[COMMON] == old[COMMON]
        assert json.loads(files[FIXTURE]) == cases and files[NORMAL] == normal
        for name in paths:
            expected = (original if before else changed) if name == OWNER else (
                (old[RUNNER] if before else runner) if name == RUNNER else old[name])
            assert files[name] == expected
        if phase != 'intake':
            assert same(json.loads(files[PROFILE]), profiles)
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        assert (ROOT / BASE / phase / 'complete.txt').read_text() == 'Both installed host epochs complete; actual declared source inputs unchanged.\n'
        prefix = str(BASE / 'control-owner') + '/' if phase in ('inverse', 'restored') else ''
        if prefix:
            for name, body in files.items():
                if name.startswith(prefix):
                    logical = name[len(prefix):]
                    expected = original if phase == 'inverse' and logical == OWNER else files[logical]
                    assert body == expected
        if phase == 'direct':
            direct_inputs(files)
        observations[phase], pairs[phase], native_counts[phase] = {}, {}, {}
        for host in HOSTS:
            directory = phase + '/' + host
            body = raw(phase, host)
            tag = 'ARRAY_TRANSFORM_LUA' if phase == 'intake' else 'ARRAY_TRANSFORM_LUA_NORMAL'
            rows = frames(body, tag)
            validate(rows, cases, profiles[host], phase in ('intake', 'before', 'inverse'))
            observations[phase][host] = rows
            red = phase in ('before', 'inverse')
            assert (ROOT / BASE / directory / 'normal-exit.txt').read_text() == ('1\n' if red else '0\n')
            assert ('ARRAY_TRANSFORM_LUA_OWNER @' + prefix + OWNER + '\n').encode() in body
            if phase != 'intake':
                assert b'ARRAY_TRANSFORM_LUA_SUMMARY 903 checks ' + (b'76' if red else b'0') + b' failures\n' in body
            grammar_tag = 'ARRAY_TRANSFORM_LUA_GRAMMAR' if phase == 'intake' else 'ARRAY_TRANSFORM_LUA_NORMAL_GRAMMAR'
            grammars = [json.loads(line.split(' ', 1)[1]) for line in body.decode().splitlines() if line.startswith(grammar_tag + ' ')]
            assert grammars == [dict(path=GRAMMAR, source=old[GRAMMAR].decode())]
            assert body.index(grammar_tag.encode()) < body.index((tag + ' ').encode())
            command = json.loads((ROOT / BASE / directory / 'normal-command.json').read_bytes())
            assert command['argv'][:2] == ['bash', 'tools/project_data_run.sh'] and command['cwd'] == '.'
            environment = command['environment']
            assert environment['LUA_PATH'] == prefix + 'lua/src/?.lua;' + prefix + 'lua/src/?/init.lua;;'
            assert environment['LUA_CPATH'] == str(BASE / directory / 'native/?.so') + ';;'
            assert environment['LINKEDSPEC_ARRAY_TRANSFORM_INPUT_ROOT'] == prefix
            assert environment['LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE'] == str(BASE / directory)
            if prefix:
                golden = 'before' if phase == 'inverse' else 'after'
                assert same(rows, observations[golden][host])
            version = raw(phase, host, 'version') + raw(phase, host, 'version', 'stderr')
            assert (ROOT / BASE / directory / 'version-exit.txt').read_text() == '0\n'
            if phase == 'intake':
                versions[host] = version
            else:
                assert versions[host] == version
            assert version.strip() and version.startswith(b'Lua ' if host == 'puc' else b'LuaJIT ')
            native = recover(directory, 'native')
            assert native.keys() == {str(BASE / directory / 'native' / name) for name in (
                'linkedspec_regex_pcre2.so', 'linkedspec_filesystem_native.so', 'linkedspec_mcp_system.so')}
            native_counts[phase][host] = len(native)
            assert (ROOT / BASE / directory / 'build-exit.txt').read_text() == '0\n'
            build = json.loads((ROOT / BASE / directory / 'build-command.json').read_bytes())
            assert build['argv'] == ['bash', 'tools/build_lua_native.sh', host, str(BASE / directory / 'native')]
            assert raw(phase, host, 'build', 'stderr') == b''
            artifacts = recover(directory, 'artifact')
            assert len(artifacts) == 312
            supplied = frames(raw('intake', host), 'ARRAY_TRANSFORM_LUA_INPUT')
            assert list(supplied) == [case['id'] for case in cases]
            pairs[phase][host] = {}
            for case in cases:
                key = case['id']
                module = artifacts[str(BASE / directory / 'emitted' / (key + '.lua'))]
                parsed = artifacts[str(BASE / directory / 'parsed' / (key + '.json'))]
                assert same(json.loads(parsed), supplied[key])
                pairs[phase][host][key] = (module, parsed)
            if phase != 'intake':
                assert pairs[phase][host] == pairs['intake'][host]
            if not red:
                assert raw(phase, host, channel='stderr') == b''
            else:
                assert b'take_free_hash_guard native' in raw(phase, host, channel='stderr')
    for host in HOSTS:
        assert same(observations['intake'][host], observations['before'][host])
        assert same(observations['after'][host], observations['direct'][host])
        direct = raw('direct', host)
        for marker in (b'HASH_VALUE_LUA_SUMMARY 510 checks 0 failures', b'HASH_VIEW_LUA_SUMMARY 184 checks 0 failures',
                       b'CONSTRUCTOR_SUMMARY 116 checks 0 failures', b'ordinary with checks passed'):
            assert marker in direct
        assert len([line for line in direct.splitlines() if line.startswith(b'WITH_RESULT ')]) == 12
        assert len([line for line in direct.splitlines() if line.startswith(b'WITH_RESULT_FENCE ')]) == 3
        for case in cases:
            if case['id'] not in RED:
                assert same(observations['intake'][host][case['id']], observations['after'][host][case['id']])
        asts = frames(raw('intake', host), 'ARRAY_TRANSFORM_LUA_COMPILED_ACTION')
        assert set(asts) == {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
        for ast in asts.values():
            kinds = []
            def visit(value):
                if isinstance(value, dict):
                    if value.get('method') == 'with':
                        kinds.extend(arg['kind'] for arg in value['args'])
                    for child in value.values():
                        visit(child)
                elif isinstance(value, list):
                    for child in value:
                        visit(child)
            visit(ast)
            assert kinds == ['block_value']
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(host, key, route, value, before=False):
        rows = copy.deepcopy(observations['before' if before else 'after'][host])
        rows[key][route] = value
        validate(rows, cases, profiles[host], before)

    reject('hidden PUC original failure', lambda: mutate('puc', 'take_free_hash_guard', 'native', {'value': [None, '']}, True))
    reject('LuaJIT consumer effects', lambda: mutate('luajit', 'take_receiver_hash_guard', 'native', {'value': [None, 'KV']}))
    reject('PUC later body', lambda: mutate('puc', 'sort_logical_later_with', 'fresh', {'value': ['ran', 'KVDW']}))
    reject('LuaJIT needed error masked', lambda: mutate('luajit', 'needed_slice_count_free', 'plan', {'value': 'masked'}))
    reject('PUC initial source normalized', lambda: mutate('puc', 'initial_hash_concat_arrays_free', 'native', {'value': ['second']}))
    wrong = copy.deepcopy(observations['after']['luajit']['nested_kinds_and_source']['native'])
    wrong['value'][0][-1] = 0
    reject('LuaJIT Bool to Number', lambda: mutate('luajit', 'nested_kinds_and_source', 'native', wrong))
    missing = copy.deepcopy(observations['after']['puc']); del missing['extra_sorted_free']
    reject('PUC excluded profile omitted', lambda: validate(missing, cases, profiles['puc']))
    reject('actual LuaJIT module drift', lambda: equal(digest(pairs['intake']['luajit']['take_compatible'][0] + b'\n'), digest(pairs['after']['luajit']['take_compatible'][0])))
    missing = dict(inputs['direct']); del missing['tests/fixtures/with_hash_result_values.spec']
    reject('direct fixture binding omitted', lambda: direct_inputs(missing))
    print(json.dumps(dict(per_host={host: dict(version=versions[host].decode().strip(), programs=156,
        shared=37, own_controls=119, profiles=123, original_failures=19, preserved=137,
        needed_errors=19, normal_checks=903, before_failures=76, after_failures=0,
        direct_counted_checks=1713, with_observations=12, with_fences=3,
        private_inverse=19, private_restored=156, artifact_pairs=156) for host in HOSTS},
        actual_native_products=native_counts, recovery='PASS', effective_corruptions=controls,
        limits='Installed hosts only; fresh modules share runtime/process. Full native/cache/transitive/toolchain custody4.2/SESSION5, declared5.4, registration/context/isolation/full23.4 remain separate.'), indent=2))


if __name__ == '__main__':
    main()
