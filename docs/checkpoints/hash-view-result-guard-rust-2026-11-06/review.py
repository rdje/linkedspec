"""Readonly finite Rust Hash-view RED/GREEN and exact declared-input recovery."""
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
BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
ACTIVATION = '55d7d7aa55aaffb01e8fbcde7ea901de3cd3a30f'
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/hash_view_result_guard_composition.rs'
FIXTURE = 'tests/fixtures/hash_view_result_guard_cases.json'
PROFILE = 'tests/fixtures/hash_view_result_guard_rust_profiles.json'
RED = {'free_sorted_keys_hash_guard', 'receiver_sorted_keys_hash_guard',
       'free_sorted_values_hash_guard', 'receiver_sorted_values_hash_guard',
       'later_with', 'copy_guard', 'logical_guard'}


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


def raw(path):
    return gzip.decompress((ROOT / Path(str(path) + '.gz')).read_bytes())


def recover(path, expected):
    assert not PurePosixPath(path).is_absolute() and '..' not in PurePosixPath(path).parts
    found = {}
    with tarfile.open(ROOT / path) as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in found
            body = archive.extractfile(member).read()
            row = expected[member.name]
            assert digest(body) == row['sha256'] and len(body) == row['bytes']
            assert member.mode & 0o777 == row['mode']
            found[member.name] = body
    assert found.keys() == expected.keys()
    return found


def custody(phase):
    records = json.loads((ROOT / BASE / phase / 'custody.json').read_bytes())
    result = {}
    for row in records:
        assert row['archive'].startswith(str(BASE / phase) + '/')
        tag = Path(row['archive']).name.split('-before-first-run')[0]
        assert tag not in result
        result[tag] = recover(row['archive'], row['files'])
    return result


def tagged(body, prefix):
    result = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, value = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(value)
    return result


def frames(phase, tag, prefix):
    assert (ROOT / BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
    return tagged(raw(BASE / phase / (tag + '-stdout.log')), prefix)


def target(case, actual, route, profiles):
    profile = profiles.get(case['id'])
    if profile:
        assert profile['source'] == case['source']
        assert same(actual, profile[route])
    else:
        assert same(actual, {'value': case['expected']})


def validate(native, fresh, cases, profiles, before=False):
    assert list(native) == list(fresh) == [case['id'] for case in cases]
    for case in cases:
        identifier = case['id']
        assert set(native[identifier]) == {'native', 'restored', 'plan'}
        routes = {**native[identifier], 'fresh': fresh[identifier]}
        for route, actual in routes.items():
            if before and identifier in RED:
                if identifier.startswith('receiver_'):
                    expected = [None, 'KV']
                elif identifier == 'free_sorted_keys_hash_guard':
                    expected = [['a'], 'KV']
                elif identifier == 'free_sorted_values_hash_guard':
                    expected = [[1], 'KV']
                else:
                    expected = ['ran', 'KVDW' if identifier == 'logical_guard' else 'KVW']
                assert same(actual, {'value': expected})
            else:
                target(case, actual, route, profiles)
        if case.get('expected_error'):
            assert all(case['expected_error'] in row['error'] for row in routes.values())
            assert native[identifier]['native'] == native[identifier]['restored']
            assert native[identifier]['plan'] == fresh[identifier]
            assert fresh[identifier]['error'] == 'Generated Rust parser execution failed: ' + native[identifier]['native']['error']
        else:
            assert all(same(native[identifier]['native'], row) for row in routes.values())


def artifacts(phase, recovered, cases):
    native = recovered['native']
    fresh = recovered['fresh']
    assert json.loads(native[str(BASE / phase / 'cases.json')]) == cases
    assert native[str(BASE / phase / 'native/src/main.rs')] == recovered['root'][str(BASE / 'observer.rs')]
    supplied = frames(phase, 'native', 'HASH_VIEW_RUST_INPUT')
    assert list(supplied) == [case['id'] for case in cases]
    modules = {path: body for path, body in fresh.items() if '/src/generated/' in path}
    assert {Path(path).name for path in modules} == {case['id'] + '.rs' for case in cases}
    result = {}
    for case in cases:
        identifier = case['id']
        serialized = fresh[str(BASE / phase / 'fresh/inputs' / (identifier + '.json'))]
        assert serialized.decode() == supplied[identifier]['compiled']
        module = fresh[str(BASE / phase / 'fresh/src/generated' / (identifier + '.rs'))]
        assert identifier + '.rs' in fresh[str(BASE / phase / 'fresh/src/lib.rs')].decode()
        result[identifier] = dict(serialized=serialized, module=module)
    return result


def equal(a, b):
    assert a == b


def main():
    sealed = json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes())
    for path, expected in sealed.items():
        assert not PurePosixPath(path).is_absolute() and '..' not in PurePosixPath(path).parts
        body = (ROOT / path).read_bytes()
        assert digest(body) == expected['sha256'] and len(body) == expected['bytes']
    for path, expected in json.loads((ROOT / BASE / 'raw-identities.json').read_bytes()).items():
        body = raw(Path(path))
        assert digest(body) == expected['sha256'] and len(body) == expected['bytes']
    phases = ('intake', 'receiver-intake', 'normal-before', 'normal-after', 'after-intake', 'direct')
    recovered = {phase: custody(phase) for phase in phases}
    roots = {phase: recovered[phase]['root'] for phase in phases}
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'rust']))) as archive:
        owned = {member.name: archive.extractfile(member).read() for member in archive if member.isfile()}
    for phase in ('intake', 'receiver-intake', 'normal-before'):
        assert all(roots[phase][path] == body for path, body in owned.items())
    for phase in ('normal-after', 'after-intake', 'direct'):
        assert {path for path in owned if roots[phase][path] != owned[path]} == {OWNER}
        assert roots[phase][OWNER] == roots['normal-after'][OWNER]
    for phase in ('normal-before', 'normal-after', 'direct'):
        assert roots[phase][NORMAL] == roots['normal-before'][NORMAL]
        assert roots[phase][PROFILE] == roots['normal-before'][PROFILE]
    grammar = 'specs/user_function_definition.spec'
    for phase in phases:
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        assert roots[phase][FIXTURE] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + FIXTURE])
        assert roots[phase][grammar] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + grammar])
        assert roots[phase][str(BASE / 'observer.rs')] == roots['intake'][str(BASE / 'observer.rs')]
    shared = json.loads(roots['intake'][FIXTURE])
    authored_profiles = json.loads(roots['intake'][str(BASE / 'profile-sources.json')])
    receiver_profiles = json.loads(roots['receiver-intake'][str(BASE / 'receiver-profile-sources.json')])
    assert len(shared) == 15 and len(authored_profiles) == 5 and len(receiver_profiles) == 2
    cases = shared + authored_profiles + receiver_profiles
    profiles = json.loads(roots['normal-before'][PROFILE])
    expected_profiles = {case['id'] for case in cases if case.get('profile_only') or case.get('expected_error')}
    assert set(profiles) == expected_profiles and len(profiles) == 8
    observations, emitted = {}, {}
    for phase, selection in (('intake', shared + authored_profiles), ('receiver-intake', receiver_profiles), ('after-intake', cases)):
        native = frames(phase, 'native', 'HASH_VIEW_RUST')
        fresh = frames(phase, 'fresh', 'HASH_VIEW_RUST_FRESH')
        validate(native, fresh, selection, profiles, phase != 'after-intake')
        observations[phase] = dict(native=native, fresh=fresh)
        emitted[phase] = artifacts(phase, recovered[phase], selection)
    before_native = {**observations['intake']['native'], **observations['receiver-intake']['native']}
    before_fresh = {**observations['intake']['fresh'], **observations['receiver-intake']['fresh']}
    validate(before_native, before_fresh, cases, profiles, True)
    final = observations['after-intake']
    for case in cases:
        identifier = case['id']
        initial_phase = 'intake' if identifier in observations['intake']['native'] else 'receiver-intake'
        assert emitted[initial_phase][identifier] == emitted['after-intake'][identifier], 'actual serialized/module identity'
        if identifier not in RED:
            assert same(before_native[identifier], final['native'][identifier])
            assert same(before_fresh[identifier], final['fresh'][identifier])
        if identifier in profiles:
            assert profiles[identifier]['source'] == case['source']
            assert all(same(value, profiles[identifier][route]) for route, value in {**before_native[identifier], 'fresh': before_fresh[identifier]}.items())
    for phase, baseline in (('normal-before', before_native), ('normal-after', final['native'])):
        rows = tagged(raw(BASE / phase / 'normal-stderr.log'), 'HASH_VIEW_RUST_NORMAL')
        assert set(rows) == set(baseline)
        assert all(same(rows[identifier], baseline[identifier]) for identifier in baseline)
        states = re.findall(r'^test (\w+) \.\.\. (ok|FAILED)$', raw(BASE / phase / 'normal-stdout.log').decode(), re.M)
        assert len(states) == 22
        assert {identifier for identifier, state in states if state == 'FAILED'} == (RED if phase == 'normal-before' else set())
        assert (ROOT / BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if phase == 'normal-before' else '0\n')
    assert (ROOT / BASE / 'direct/normal-exit.txt').read_text() == '0\n'
    command = json.loads((ROOT / BASE / 'direct/normal-command.json').read_bytes())['argv']
    assert [command[index + 1] for index, value in enumerate(command) if value == '--test'] == ['value_copy', 'constructor_result_composition']
    assert command[command.index('-j') + 1] == '1' and '--test-threads=1' in command
    assert re.findall(r'test result: ok\. (\d+) passed; 0 failed;', raw(BASE / 'direct/normal-stdout.log').decode()) == ['24', '6']
    for path, expected in json.loads((ROOT / BASE / 'format/input-identities.json').read_bytes()).items():
        body = roots['normal-after'][path]
        assert digest(body) == expected['sha256'] and len(body) == expected['bytes']
    assert (ROOT / BASE / 'format/exit.txt').read_text() == '0\n'
    assert raw(BASE / 'format/stdout.log') == raw(BASE / 'format/stderr.log') == b''
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(identifier, route, value):
        native, fresh = copy.deepcopy(final['native']), copy.deepcopy(final['fresh'])
        if route == 'fresh':
            fresh[identifier] = value
        else:
            native[identifier][route] = value
        validate(native, fresh, cases, profiles)

    reject('Hash operand runs', lambda: mutate('free_sorted_keys_hash_guard', 'native', {'value': [None, 'KV']}))
    reject('copy recovers rejection', lambda: mutate('copy_guard', 'fresh', {'value': ['ran', 'W']}))
    reject('initial null body suppressed', lambda: mutate('receiver_null_with_profile', 'restored', {'value': [None, '']}))
    reject('malformed arity profile imported', lambda: mutate('arity_profile', 'plan', {'value': ['ran', 'W']}))
    reject('Boolean becomes numeric', lambda: mutate('nested_kinds', 'native', {'value': [0, 8]}))
    reject('needed error masked', lambda: mutate('needed_source_error', 'plan', {'value': None}))
    lost = copy.deepcopy(final['fresh'])
    lost.pop('source_once_snapshot')
    reject('missing fresh source', lambda: validate(final['native'], lost, cases, profiles))
    body = emitted['after-intake']['copy_guard']['module']
    reject('module drift', lambda: equal(body, body + b'\n'))
    return dict(shared_groups=15, original_shared_healthy=8, original_red=7, own_profile_sources=7,
                normal_before_healthy=15, normal_final_pass=22, four_route_final_pass=22,
                direct_files=2, direct_pass=30, focused_total=52, actual_modules_and_serialized_inputs_unchanged=22,
                recovery_corruptions=rejected,
                scope='Focused Rust canonical Hash-view source/prefix repair. Initial source policy and produced-owner precedence retained. Full native/cache/transitive custody4.2, isolation, registered-function contexts, discovery and full23.4 remain separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
