"""Readonly recovery of finite Rust pipeline proof; no current SDK execution."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/array_pipeline_result_guard_composition.rs'
PROFILE = 'tests/fixtures/array_pipeline_result_guard_rust_profiles.json'
SHARED = 'tests/fixtures/array_pipeline_result_guard_cases.json'
ACTIVATION = '74f3a4a1a21ba3cd1bf29579e3fcdb28cf3bd889'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def same(left, right):
    if isinstance(left, bool) or isinstance(right, bool):
        return type(left) is type(right) and left == right
    if isinstance(left, (int, float)) and isinstance(right, (int, float)):
        return left == right
    if type(left) is not type(right):
        return False
    if isinstance(left, dict):
        return left.keys() == right.keys() and all(same(left[k], right[k]) for k in left)
    if isinstance(left, list):
        return len(left) == len(right) and all(same(a, b) for a, b in zip(left, right))
    return left == right


def raw(name):
    return gzip.decompress((BASE / name).read_bytes())


def frames(body, tag):
    result = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in result, 'duplicate frame'
            result[key] = json.loads(value)
    return result


def inputs(phase):
    result = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL / phase) + '/')
        tag = path.name.removesuffix('-inputs.tar.gz')
        assert tag not in result
        files = {}
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in files
                body = archive.extractfile(member).read()
                row = packet['files'][member.name]
                assert hashlib.sha256(body).hexdigest() == row['sha256'] and len(body) == row['bytes']
                assert member.mode & 0o777 == row['mode'], 'archive mode'
                files[member.name] = body
        assert files.keys() == packet['files'].keys(), 'archive census'
        result[tag] = files
    return result


def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'ARRAY_PIPELINE_RUST')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'ARRAY_PIPELINE_RUST_FRESH')
    assert list(native) == list(fresh), 'fresh census'
    return {key: dict(value, fresh=fresh[key]) for key, value in native.items()}


def validate(rows, cases, profiles, red):
    assert list(rows) == [c['id'] for c in cases], 'route census'
    actual_red = set()
    for case in cases:
        key = case['id']
        observed = rows[key]
        assert set(observed) == set(ROUTES), 'route shape'
        assert same(observed['native'], observed['restored']), 'restored drift'
        if 'error' in observed['native']:
            assert same(observed['plan'], observed['fresh']) and observed['plan'] == {
                'error': 'Generated Rust parser execution failed: ' + observed['native']['error']}, 'error wrapper'
        else:
            assert all(same(observed['native'], value) for value in observed.values()), 'route agreement'
        for route, value in observed.items():
            if case.get('profile_only') or case.get('expected_error'):
                expected = profiles[key][route]
                assert same(profiles[key]['source'], case['source']) and profiles[key]['input'] == case['input'], 'profile identity'
            else:
                expected = {'value': case['expected']}
            if not same(value, expected):
                actual_red.add(key)
            if key not in red:
                assert same(value, expected), 'target or preservation policy'
            else:
                assert not same(value, expected), 'hidden original RED'
            if case.get('expected_error'):
                assert case['expected_error'] in value['error'], 'masked required error'
    assert actual_red == red, 'semantic RED census'


def normal(phase, expected, red):
    stdout = raw(phase + '/normal-stdout.log.gz')
    observed = frames(raw(phase + '/normal-stderr.log.gz'), 'ARRAY_PIPELINE_RUST_NORMAL')
    selected = {key: {route: value for route, value in row.items() if route != 'fresh'} for key, row in expected.items()}
    assert same(observed, selected), 'normal observations'
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if red else '0\n'), 'normal exit'
    count = f'{173 - len(red)} passed; {len(red)} failed; 0 ignored; 0 measured; 0 filtered out'.encode()
    assert count in stdout, 'normal semantic count'


def check_pairs(before, after, cases):
    for case in cases:
        for tail in ('inputs/' + case['id'] + '.json', 'src/generated/' + case['id'] + '.rs'):
            assert before[str(REL / 'intake/fresh' / tail)] == after[str(REL / 'after/fresh' / tail)], 'compiled/module pair drift'


def main():
    sealed = json.loads((BASE / 'readonly-review/input-identities.json').read_bytes())
    for name, row in sealed.items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL) + '/'), 'readonly input path'
        file = ROOT / path
        body = file.read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and file.stat().st_mode & 0o777 == row['mode'], 'readonly input identity'
    with tarfile.open(BASE / 'readonly-review/instruments-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == {str(REL / name) for name in ('review.py', 'check_current.py', 'record_review.py')}
        for member in archive:
            assert archive.extractfile(member).read() == (ROOT / member.name).read_bytes(), 'readonly producer identity'
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct', 'format')
    data = {phase: inputs(phase) for phase in phases}
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    assert baseline['cases'] == 173 and baseline['shared'] == 36 and baseline['own'] == 137
    assert baseline['healthy'] == 162 and baseline['profiles'] == 141
    red = set(baseline['red'])
    assert len(red) == 11
    original = data['intake']['root']
    candidate = data['after']['root']
    old_owner = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert original[OWNER] == raw('owner-before.rs.gz') == old_owner
    git_image = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION,
        'rust', 'tests/fixtures', 'specs/spec.spec', 'specs/user_function_definition.spec',
        'specs/pplugin.spec', 'cli_conformance/cases/help/stdout.txt'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(git_image)) as archive:
        for member in archive:
            if member.isfile():
                assert original[member.name] == archive.extractfile(member).read(), 'activation SDK bytes'
    assert candidate[OWNER] == raw('repair-run/owner-after.rs.gz') != old_owner
    assert candidate[NORMAL] == raw('repair-run/normal-after.rs.gz')
    for name, body in original.items():
        if name.startswith(('rust/', 'specs/', 'tests/fixtures/', 'cli_conformance/')) and name != OWNER:
            assert candidate[name] == body, 'unrelated original input changed'
    for phase in phases:
        assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        root = data[phase]['root']
        assert root['cli_conformance/cases/help/stdout.txt'] == original['cli_conformance/cases/help/stdout.txt'], 'embedded help input'
        for name in (NORMAL, PROFILE):
            if phase != 'intake':
                assert root[name] == candidate[name], 'new untracked include input'
        for path in (BASE / phase).glob('*-exit.txt'):
            expected = '101\n' if phase in ('before', 'private-old') and path.name == 'normal-exit.txt' else '0\n'
            assert path.read_text() == expected, 'actual command failure'
        for path in (BASE / phase).glob('*-command.json'):
            command = json.loads(path.read_bytes())
            assert command['cwd'] == '.' and command['environment'] == dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
            tag = path.name.removesuffix('-command.json')
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file() and (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if tag in ('native', 'fresh', 'normal', 'array_transform_result_guard_composition', 'value_copy'):
                executable = str(REL / phase / (tag + '-exec'))
                assert executable in data[phase][tag + '-product'] and executable in command['argv'], 'executed product not retained'
    cases = json.loads((BASE / 'intake/cases.json').read_bytes())
    assert same(cases, json.loads((BASE / 'after/cases.json').read_bytes())) and len(cases) == 173
    assert cases[:36] == json.loads(original[SHARED])
    profiles = json.loads(candidate[PROFILE])
    assert len(profiles) == 141
    before, after = routes('intake'), routes('after')
    assert all(value == {'value': [None, '']} for value in before['constructor_array_guard'].values()), 'independent constructor guard'
    assert all(value == {'value': None} for value in before['invalid_range_receiver_composed'].values()), 'independent receiver guard'
    for key in ('invalid_range_free_terminal', 'invalid_range_receiver_terminal'):
        assert all(value == {'value': []} for value in before[key].values()), 'original regex producer policy'
    validate(before, cases, profiles, red)
    validate(after, cases, profiles, set())
    for channel in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        assert raw('intake/' + channel) == raw('after/' + channel), 'warning drift'
    for key in before.keys() - red:
        assert same(before[key], after[key]), 'healthy observation drift'
    normal('before', before, red)
    normal('private-old', before, red)
    normal('private-fixed', after, set())
    normal('direct', after, set())
    for name, count in [('array_transform_result_guard_composition', 195), ('value_copy', 6)]:
        assert f'{count} passed; 0 failed'.encode() in raw('direct/' + name + '-stdout.log.gz'), 'direct compatibility'
    assert raw('format/format-stdout.log.gz') == raw('format/format-stderr.log.gz') == b''
    check_pairs(data['intake']['fresh-source'], data['after']['fresh-source'], cases)
    control = str(REL / 'control-owner') + '/'
    old_private = {k: v for k, v in data['private-old']['root'].items() if k.startswith(control)}
    fixed_private = {k: v for k, v in data['private-fixed']['root'].items() if k.startswith(control)}
    assert old_private.keys() == fixed_private.keys()
    assert old_private[control + OWNER] == old_owner and fixed_private[control + OWNER] == candidate[OWNER]
    for name in old_private.keys() - {control + OWNER}:
        assert old_private[name] == fixed_private[name], 'private image drift'
    assert old_private[control + 'cli_conformance/cases/help/stdout.txt'] == original['cli_conformance/cases/help/stdout.txt']
    for tag in ('writer', 'formatter'):
        assert (BASE / 'repair-run' / (tag + '-exit.txt')).read_text() == '0\n'
    writer_inputs = json.loads((BASE / 'repair-run/inputs.json').read_bytes())
    with tarfile.open(BASE / 'repair-run/inputs.tar.gz') as archive:
        assert set(archive.getnames()) == set(writer_inputs)
        for member in archive:
            body = archive.extractfile(member).read()
            row = writer_inputs[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    # Independent old observations distinguish the guard repair from merely
    # copying a new expected value. Each mutation must trip its named reason.
    controls = []

    def reject(label, operation, reason):
        try:
            operation()
        except AssertionError as error:
            assert reason in str(error), (label, str(error))
            controls.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)

    for label, key, value in [
        ('hash operand effect', 'trim_each_free_hash_guard', {'value': [None, 'KV']}),
        ('late with effect', 'uniq_copy_later_with', {'value': ['ran', 'W']}),
        ('initial fallback', 'initial_number_trim_each_receiver_with', {'value': [None, '']}),
        ('required source masked', 'needed_source_trim_each_receiver', {'value': 'masked'}),
        ('regex result bypass', 'invalid_range_free_composed', {'value': []}),
        ('Boolean becomes Number', 'nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ]:
        changed = copy.deepcopy(after)
        changed[key] = {route: value for route in ROUTES}
        reject(label, lambda: validate(changed, cases, profiles, set()), 'target or preservation policy')
    changed = copy.deepcopy(before)
    changed['trim_each_free_hash_guard'] = copy.deepcopy(after['trim_each_free_hash_guard'])
    reject('hidden original RED', lambda: validate(changed, cases, profiles, red), 'hidden original RED')
    changed = copy.deepcopy(after)
    changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, cases, profiles, set()), 'route census')
    changed = dict(data['after']['fresh-source'])
    path = str(REL / 'after/fresh/src/generated/source_once.rs')
    changed[path] += b'\n// corruption\n'
    reject('altered emitted input', lambda: check_pairs(data['intake']['fresh-source'], changed, cases), 'compiled/module pair drift')
    print('PASS:173 cases;11 original guard gaps/162 exact preservation;four routes;374 direct;173 artifact pairs')
    print('PASS:first-use own SDK/help/new fixtures and executed product custody;private old/current same-path controls;scoped format')
    print('PASS:' + str(len(controls)) + ' reason-sensitive corruption controls: ' + '; '.join(controls))
    print('LIMIT:finite authored coverage only;unstripped/native-cache/transitive/toolchain/OS custody4.2/SESSION5 and full23.4 admission separate')


if __name__ == '__main__':
    main()
