"""Readonly finite Array-result proof; historical inputs, no live SDK execution."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
ACTIVATION = 'b0376420ba6258420b146981b848d4646fb3ff55'
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs'
FIXTURE = 'tests/fixtures/array_transform_result_guard_cases.json'
PROFILE = 'tests/fixtures/array_transform_result_guard_rust_profiles.json'
OPTIONAL = 'tests/fixtures/array_transform_optional_result_guard_cases.json'
FIXED = 'repaired-after'


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
    return gzip.decompress((BASE / path).read_bytes())


def frames(body, prefix):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows, 'duplicate observation'
            rows[key] = json.loads(value)
    return rows


def custody(phase):
    result = {}
    manifest = json.loads((BASE / phase / 'custody.json').read_bytes())
    for record in manifest:
        path = PurePosixPath(record['archive'])
        assert not path.is_absolute() and '..' not in path.parts
        assert str(path).startswith(str(BASE.relative_to(ROOT) / phase) + '/')
        tag = path.name.split('-before-first-run')[0]
        assert tag not in result
        files = {}
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in files
                body = archive.extractfile(member).read()
                row = record['files'][member.name]
                assert hashlib.sha256(body).hexdigest() == row['sha256']
                assert len(body) == row['bytes'] and member.mode & 0o777 == row['mode']
                files[member.name] = body
        assert files.keys() == record['files'].keys()
        result[tag] = files
    return result


def target(case, actual, route, profiles):
    key = case['id']
    if key in profiles:
        profile = profiles[key]
        assert case['source'] == profile['source'] and case['input'] == profile['input'], 'profile inputs'
        assert same(actual, profile[route]), 'policy or required error changed'
        if case.get('expected_error'):
            assert case['expected_error'] in actual['error'], 'required error masked'
    else:
        assert same(actual, {'value': case['expected']}), 'result kind or skipped effects changed'


def validate(native, fresh, cases, profiles, red):
    assert list(native) == list(fresh) == [c['id'] for c in cases], 'case census'
    for case in cases:
        key = case['id']
        assert set(native[key]) == {'native', 'restored', 'plan'}, 'route census'
        assert same(native[key]['native'], native[key]['restored']), 'restored drift'
        if 'error' in native[key]['native']:
            assert native[key]['plan'] == fresh[key] == {
                'error': 'Generated Rust parser execution failed: ' + native[key]['native']['error']}, 'error wrapper'
        else:
            assert all(same(native[key]['native'], row) for row in [*native[key].values(), fresh[key]]), 'route drift'
        for route, actual in [*native[key].items(), ('fresh', fresh[key])]:
            if key in red:
                assert not same(actual, {'value': case['expected']}), 'hidden original RED'
            else:
                target(case, actual, route, profiles)


def normal(phase, expected, cases, red, direct=False):
    stdout = raw(phase + '/normal-stdout.log.gz')
    stderr = raw(phase + '/normal-stderr.log.gz')
    rows = frames(stderr, 'ARRAY_TRANSFORM_RUST_NORMAL')
    assert set(rows) == {c['id'] for c in cases}, 'normal did not execute all cases'
    assert same(rows, expected), 'normal observation drift'
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if red else '0\n'), 'normal exit'
    count = f'{195-len(red)} passed; {len(red)} failed; 0 ignored; 0 measured; 0 filtered out'.encode()
    assert count in stdout, 'normal semantic count'
    if direct:
        assert b'89 passed; 0 failed' in stdout and b'6 passed; 0 failed' in stdout, 'direct families'
    command = json.loads((BASE / phase / 'normal-command.json').read_bytes())
    assert command['cwd'] == '.' and '--locked' in command['argv'] and '--offline' in command['argv']
    assert command['environment'] == dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')


def artifact_pairs(old_files, new_files, cases, new_phase=FIXED):
    for key in (c['id'] for c in cases):
        for tail in ('inputs/' + key + '.json', 'src/generated/' + key + '.rs'):
            prefix = BASE.relative_to(ROOT)
            assert old_files[str(prefix / 'intake/fresh' / tail)] == new_files[str(prefix / new_phase / 'fresh' / tail)], 'artifact pair drift'


def main():
    phases = ('intake', 'before', 'qualified-before', 'after', FIXED, 'private-old', 'private-fixed', 'direct', 'format')
    inputs = {phase: custody(phase) for phase in phases}
    before = inputs['intake']['root']
    after = inputs[FIXED]['root']
    actual_git = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION,
        'rust', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec',
        'cli_conformance/cases/help/stdout.txt'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(actual_git)) as archive:
        for member in archive:
            if member.isfile():
                assert before[member.name] == archive.extractfile(member).read(), 'activation input drift'
    assert before[OWNER] == raw('owner-before.rs.gz')
    for name, body in before.items():
        if name.startswith(('rust/', 'specs/', 'tests/fixtures/', 'cli_conformance/')) and name != OWNER:
            assert after[name] == body, 'unrelated input changed'
    cases = json.loads((BASE / 'intake/cases.json').read_bytes())
    assert cases == json.loads((BASE / FIXED / 'cases.json').read_bytes())
    assert len(cases) == 195
    assert cases[:37] == json.loads(before[FIXTURE]), 'shared37 changed'
    profiles = json.loads(after[PROFILE])
    assert len(profiles) == 152
    assert after[OPTIONAL] == (BASE / 'additional-targets.json').read_bytes()
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    red = set(baseline['red'])
    assert baseline['cases'] == 195 and baseline['healthy'] == 195-len(red)
    assert baseline['profiles'] == 152
    old_native = frames(raw('intake/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST')
    old_fresh = frames(raw('intake/fresh-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_FRESH')
    new_native = frames(raw(FIXED + '/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST')
    new_fresh = frames(raw(FIXED + '/fresh-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_FRESH')
    validate(old_native, old_fresh, cases, profiles, red)
    validate(new_native, new_fresh, cases, profiles, set())
    for key in old_native.keys() - red:
        assert same(old_native[key], new_native[key]) and same(old_fresh[key], new_fresh[key]), 'healthy drift'
    for phase in ('intake', 'after', FIXED):
        serialized = frames(raw(phase + '/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_INPUT')
        emitted = inputs[phase]['fresh']
        assert set(serialized) == {c['id'] for c in cases}
        for key, row in serialized.items():
            name = str(BASE.relative_to(ROOT) / phase / 'fresh/inputs' / (key + '.json'))
            assert emitted[name] == row['compiled'].encode(), 'actual compiled input drift'
        assert (BASE / phase / 'native-exit.txt').read_text() == '0\n'
        assert (BASE / phase / 'fresh-exit.txt').read_text() == '0\n'
    old_files = inputs['intake']['fresh']
    new_files = inputs[FIXED]['fresh']
    artifact_pairs(old_files, new_files, cases)
    # The first writer failed before its first write. A missing fail-fast launch
    # then acquired the old runtime again; technical acquisition success is not GREEN.
    assert inputs['after']['root'][OWNER] == before[OWNER]
    assert frames(raw('after/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST') == old_native
    assert frames(raw('after/fresh-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_FRESH') == old_fresh
    artifact_pairs(old_files, inputs['after']['fresh'], cases, 'after')
    assert (BASE / 'repair-outer/exit.txt').read_text() == '1\n'
    assert b'AssertionError' in raw('repair-outer/stderr.log.gz')
    writer = json.loads((BASE / 'writer-qualification.json').read_bytes())
    for field, name in (('original_sha256', 'repair.py'), ('qualified_sha256', 'repair_qualified.py'), ('capture_sha256', 'capture_repaired.py')):
        assert hashlib.sha256((BASE / name).read_bytes()).hexdigest() == writer[field]
    assert raw('writer-construction.rs.gz') == raw('owner-unformatted.rs.gz')
    assert (BASE / 'repair-qualified-outer/exit.txt').read_text() == '0\n'
    assert raw('repair-qualified-outer/stderr.log.gz') == b''
    assert OPTIONAL not in inputs['before']['root'], 'original custody gap must stay explicit'
    qualification = json.loads((BASE / 'capture-qualification.json').read_bytes())
    for field, path in (('original_sha256', 'capture.py'), ('qualified_sha256', 'capture_qualified.py')):
        assert hashlib.sha256((BASE / path).read_bytes()).hexdigest() == qualification[field]
    assert inputs['qualified-before']['root'][OPTIONAL] == after[OPTIONAL]
    for phase, old in (('before', True), ('qualified-before', True), ('private-old', True), ('private-fixed', False), ('direct', False)):
        normal(phase, old_native if old else new_native, cases, red if old else set(), phase == 'direct')
        assert inputs[phase]['root'][NORMAL] == after[NORMAL]
        assert inputs[phase]['root'][PROFILE] == after[PROFILE]
        assert inputs[phase]['root'][OWNER] == (before[OWNER] if phase in ('before', 'qualified-before') else after[OWNER])
    private_prefix = str(BASE.relative_to(ROOT) / 'control-owner') + '/'
    for phase, owner in (('private-old', before[OWNER]), ('private-fixed', after[OWNER])):
        files = inputs[phase]['root']
        for path in (PROFILE, OPTIONAL, NORMAL, 'specs/spec.spec', 'specs/user_function_definition.spec',
                     'specs/pplugin.spec', 'cli_conformance/cases/help/stdout.txt'):
            assert files[private_prefix + path] == after[path], 'private input drift'
        assert files[private_prefix + OWNER] == owner, 'private owner image'
    patch = ''.join(difflib.unified_diff(before[OWNER].decode().splitlines(True), after[OWNER].decode().splitlines(True),
                                      fromfile=OWNER, tofile=OWNER)).encode()
    assert raw('source.patch.gz') == patch
    for channel in ('stdout', 'stderr'):
        assert raw('format/format-' + channel + '.log.gz') == b''
    assert (BASE / 'format/format-exit.txt').read_text() == '0\n'
    for name in (OWNER, NORMAL, PROFILE, OPTIONAL):
        assert inputs['direct']['root'][name] == inputs['format']['root'][name] == after[name]
    for phase in phases:
        assert (BASE / (phase + '-outer') / 'exit.txt').read_text() == '0\n'
        assert raw(phase + '-outer/stderr.log.gz') == b'', 'outer acquisition warning/failure'
    checks = 0

    def corrupt(mutator, reason):
        nonlocal checks
        a, b = copy.deepcopy(new_native), copy.deepcopy(new_fresh)
        mutator(a, b)
        try:
            validate(a, b, cases, profiles, set())
        except AssertionError as error:
            assert reason in str(error), (reason, str(error))
            checks += 1
        else:
            raise AssertionError('ineffective corruption')

    def replace(a, b, key, row):
        a[key] = {route: copy.deepcopy(row) for route in ('native', 'restored', 'plan')}
        b[key] = copy.deepcopy(row)

    corrupt(lambda a, b: replace(a, b, 'take_free_hash_guard', {'value': [None, 'KV']}), 'result kind')
    corrupt(lambda a, b: replace(a, b, 'optional_take_free_guard', {'value': [None, 'W']}), 'result kind')
    error_key = next(c['id'] for c in cases if c.get('expected_error'))
    corrupt(lambda a, b: replace(a, b, error_key, {'value': None}), 'policy or required error')
    corrupt(lambda a, b: replace(a, b, 'initial_number_take_free', {'value': None}), 'policy or required error')
    corrupt(lambda a, b: replace(a, b, 'take_compatible', {'value': [['tail'], ['head']]}), 'result kind')
    corrupt(lambda a, b: b.pop('take_compatible'), 'case census')
    bad = copy.deepcopy(old_native)
    bad_fresh = copy.deepcopy(old_fresh)
    hidden_key = sorted(red)[0]
    bad[hidden_key] = copy.deepcopy(new_native[hidden_key])
    bad_fresh[hidden_key] = copy.deepcopy(new_fresh[hidden_key])
    try:
        validate(bad, bad_fresh, cases, profiles, red)
    except AssertionError as error:
        assert str(error) == 'hidden original RED'
        checks += 1
    else:
        raise AssertionError('hidden original RED accepted')
    wrong_pair = dict(new_files)
    pair_name = next(p for p in new_files if p.endswith('/inputs/take_compatible.json'))
    wrong_pair[pair_name] += b' '
    try:
        artifact_pairs(old_files, wrong_pair, cases)
    except AssertionError as error:
        assert str(error) == 'artifact pair drift'
        checks += 1
    else:
        raise AssertionError('altered artifact pair accepted')
    print(f'finite195: {len(red)} original RED; all195/four routes and direct290 pass; '
          f'{195-len(red)} healthy,152 profiles,195 artifact pairs exact; {checks} corruptions rejected')


if __name__ == '__main__':
    main()
