"""Read-only original installed-host callable preservation and effective corruptions."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/key-count-callable-lua-2026-11-06')
ACTIVATION = 'f1041c8e55fe6e03e67f8444241352ec99bd1c44'
GRAMMAR = 'specs/user_function_definition.spec'
FIXTURE = 'tests/fixtures/key_count_callable_result_cases.json'
PROFILE = 'tests/fixtures/key_count_callable_lua_profiles.json'
ROUTES = {'native', 'restored', 'plan', 'fresh'}


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


def recover(phase, host=None):
    directory = ROOT / BASE / phase
    if host:
        directory /= host
    name = 'actual-emitted-parsed' if host else 'inputs-before-first-run'
    expected = json.loads((directory / ('artifact-identities.json' if host else 'input-identities.json')).read_bytes())
    found = {}
    with tarfile.open(directory / (name + '.tar.gz')) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            raw = archive.extractfile(member).read()
            row = expected[member.name]
            assert hashlib.sha256(raw).hexdigest() == row['sha256']
            assert len(raw) == row['bytes'] and member.mode & 0o777 == row['mode']
            found[member.name] = raw
    assert found.keys() == expected.keys(), 'exact declared archive membership'
    return found


def frames(raw, prefix):
    result = {}
    for line in raw.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(body)
    return result


def validate(rows, cases, profiles):
    assert list(rows) == [case['id'] for case in cases], 'complete ordered source population'
    for case in cases:
        row = rows[case['id']]
        assert set(row) == ROUTES
        profile = profiles.get(case['id'])
        if profile:
            assert profile['source'] == case['source']
        for route, actual in row.items():
            assert same(actual, profile[route] if profile else {'value': case['expected']}), case['id']
    for name in ('boolean_receiver_profile', 'boolean_terminal_profile'):
        assert all(value == {'value': None} for value in rows[name].values())
    assert same(rows['function_controls']['native'], {'value': [False, 1, 'X']})
    error = rows['needed_argument_error']
    assert same(error['native'], error['restored']) and same(error['plan'], error['fresh'])
    assert error['native']['runtime'] is True and error['native']['generated'] is False
    assert error['native']['code'] == 'binding_kind_mismatch'
    assert error['native']['diagnostic_stage'] == 'runtime_execution'
    assert error['fresh']['runtime'] is False and error['fresh']['generated'] is True
    assert error['fresh']['error'] == 'Generated Lua parser execution failed: ' + error['native']['error']


def equal(a, b):
    assert a == b


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    initial, direct = recover('intake'), recover('direct')
    cases, profiles = json.loads(initial[FIXTURE]), json.loads(direct[PROFILE])
    assert set(profiles) == {'puc', 'luajit'}
    for values in profiles.values():
        assert set(values) == {'boolean_receiver_profile', 'boolean_terminal_profile',
                               'malformed_receiver_profile', 'needed_argument_error'}
    assert initial[FIXTURE] == direct[FIXTURE] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + FIXTURE])
    for path, raw in initial.items():
        if path.startswith('lua/') or path == GRAMMAR:
            assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + path])
            if path == 'lua/test/run.lua':
                old = b'test("CountKeys source and continuation guards", function()\n  dofile("lua/test/key_count_result_guard_composition_test.lua")\nend)'
                expected = raw.replace(old, old + b'\ntest("Callable CountKeys preservation", function()\n  dofile("lua/test/key_count_callable_result_guard_composition_test.lua")\nend)')
                assert raw.count(old) == 1 and direct[path] == expected
            else:
                assert direct[path] == raw, 'no Lua production repair'
    observed, versions = {}, {}
    for host in ('puc', 'luajit'):
        rows = {}
        for phase in ('intake', 'direct'):
            directory = ROOT / BASE / phase
            assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
            directory /= host
            for tag in ('normal', 'version'):
                assert (directory / (tag + '-exit.txt')).read_text() == '0\n'
            assert gzip.decompress((directory / 'normal-stderr.log.gz').read_bytes()) == b''
            version = b''.join(gzip.decompress((directory / ('version-' + channel + '.log.gz')).read_bytes())
                               for channel in ('stdout', 'stderr'))
            versions[host] = version.decode().strip()
            assert ('Lua 5.5.1' if host == 'puc' else 'LuaJIT 2.1.1788460057') in versions[host]
            raw = gzip.decompress((directory / 'normal-stdout.log.gz').read_bytes())
            prefix = 'CALLABLE_KEY_COUNT_LUA' + ('_NORMAL' if phase == 'direct' else '')
            grammar = [json.loads(line.split(' ', 1)[1]) for line in raw.decode().splitlines()
                       if line.startswith(prefix + '_GRAMMAR ')]
            assert grammar == [{'path': GRAMMAR, 'source': initial[GRAMMAR].decode()}]
            rows[phase] = frames(raw, prefix)
            validate(rows[phase], cases, profiles[host])
            if phase == 'direct':
                assert 'CALLABLE_KEY_COUNT_LUA_SUMMARY 84 checks 0 failures\n' in raw.decode()
                assert 'KEY_COUNT_GUARD_LUA_SUMMARY 126 checks 0 failures\n' in raw.decode()
            else:
                parsed = frames(raw, 'CALLABLE_KEY_COUNT_LUA_INPUT')
                assert list(parsed) == [c['id'] for c in cases]
        assert same(rows['intake'], rows['direct']), 'all original actual observations preserved'
        original, current = recover('intake', host), recover('direct', host)
        for case in cases:
            for directory, extension in (('emitted', 'lua'), ('parsed', 'json')):
                suffix = f"{directory}/{case['id']}.{extension}"
                before = original[str(BASE / 'intake' / host / suffix)]
                assert before == current[str(BASE / 'direct' / host / suffix)], 'actual artifact identity'
                if directory == 'parsed':
                    assert same(json.loads(before), parsed[case['id']])
        observed[host] = rows['intake']
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(host, identifier, route, value):
        damaged = copy.deepcopy(observed[host])
        damaged[identifier][route] = value
        validate(damaged, cases, profiles[host])

    for host in ('puc', 'luajit'):
        reject(host + ' compatible numeric regression', lambda h=host: mutate(h, 'compatible_counts', 'native', {'value': [1, None, 2, '1 KEYS']}))
        reject(host + ' Boolean peer normalization', lambda h=host: mutate(h, 'boolean_terminal_profile', 'native', {'value': 0}))
    reject('needed source error masked', lambda: mutate('puc', 'needed_argument_error', 'plan', {'value': None}))
    lost = copy.deepcopy(observed['luajit'])
    lost['wrong_array'].pop('fresh')
    reject('missing fresh route', lambda: validate(lost, cases, profiles['luajit']))
    changed = copy.deepcopy(profiles['puc'])
    changed['malformed_receiver_profile']['source'] += ' '
    reject('profile source drift', lambda: validate(observed['puc'], cases, changed))
    module = recover('intake', 'puc')[str(BASE / 'intake/puc/emitted/compatible_counts.lua')]
    reject('actual module drift', lambda: equal(module, module + b'\n'))
    return dict(groups_per_host=len(cases), compatible_targets_per_host=len(cases)-4,
                independent_profiles_per_host=4, versions=versions,
                routes=sorted(ROUTES), runtime_changes=0, direct_checks_per_host=84+126,
                original_observations_and_modules_preserved_per_host=len(cases),
                recovery_corruptions=rejected,
                scope='installed safe hosts only; declared direct grammar inputs; native/cache/transitive custody, isolation, declared Lua5.4 and full admission remain separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
