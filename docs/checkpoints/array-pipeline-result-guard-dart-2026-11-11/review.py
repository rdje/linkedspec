"""Readonly historical Dart pipeline proof; no current SDK execution."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile
from urllib.parse import unquote, urljoin, urlparse

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OWNER = 'dart/lib/src/runtime/interpreter.dart'
PROBE = 'dart/tool/probe_array_pipeline_results.dart'
NORMAL = 'dart/test/array_pipeline_result_guard_composition_test.dart'
PROFILE = 'tests/fixtures/array_pipeline_result_guard_dart_profiles.json'
SHARED = 'tests/fixtures/array_pipeline_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
ACTIVATION = '52cc3fa8073106154e8a3646ae27ee8e77d5d401'
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
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows, 'duplicate frame'
            rows[key] = json.loads(value)
    return rows


def inputs(phase):
    data = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL / phase) + '/')
        tag = packet['tag']
        assert tag not in data
        rows = {}
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in rows
                body = archive.extractfile(member).read()
                expected = packet['files'][member.name]
                assert len(body) == expected['bytes'] and hashlib.sha256(body).hexdigest() == expected['sha256'] and member.mode & 0o777 == expected['mode'], 'input archive identity'
                rows[member.name] = body
        assert rows.keys() == packet['files'].keys(), 'input census'
        data[tag] = rows
    return data


def routed(path, body, expected):
    packages = json.loads(body)['packages']
    own = [p for p in packages if p['name'] == 'linkedspec_dart']
    assert len(own) == 1 and not urlparse(own[0]['rootUri']).scheme, 'own routing must be relative'
    uri = urlparse(urljoin((ROOT / path).as_uri(), own[0]['rootUri']))
    assert uri.scheme == 'file' and not uri.netloc and Path(unquote(uri.path)).resolve() == (ROOT / expected).resolve(), 'actual SDK routing'


def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'ARRAY_PIPELINE_DART')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'ARRAY_PIPELINE_DART_FRESH')
    assert list(native) == list(fresh), 'fresh census'
    return {key: dict(value, fresh=fresh[key]) for key, value in native.items()}


def validate(rows, cases, profiles, red):
    assert list(rows) == [row['id'] for row in cases], 'route census'
    actual_red = set()
    for case in cases:
        key = case['id']
        observed = rows[key]
        assert set(observed) == set(ROUTES), 'route shape'
        assert same(observed['native'], observed['restored']), 'restored drift'
        assert same(observed['plan'], observed['fresh']), 'fresh framing drift'
        if 'error' in observed['native']:
            assert observed['native']['class'] == 'RuntimeInterpreterException'
            assert observed['native']['diagnostic']['stage'] == 'runtime_execution'
            assert observed['plan'] == dict(error='Generated Dart parser execution failed: ' + observed['native']['error'], **{'class': 'GeneratedSourceException'}), 'error framing'
        else:
            assert all(same(observed['native'], value) for value in observed.values()), 'value route drift'
        for route, value in observed.items():
            if case.get('profile_only') or case.get('expected_error'):
                expected = profiles[key][route]
                assert profiles[key]['source'] == case['source'] and profiles[key]['input'] == case['input'], 'profile source identity'
            else:
                expected = {'value': case['expected']}
            if not same(value, expected):
                actual_red.add(key)
            if key in red:
                assert not same(value, expected), 'hidden original RED'
            else:
                assert same(value, expected), 'target or preservation policy'
            if case.get('expected_error'):
                assert case['expected_error'] in value['error'], 'masked required error'
    assert actual_red == red, 'semantic RED census'


def normal(phase, expected, red, direct=False):
    body = raw(phase + '/normal-stdout.log.gz')
    rows = frames(body, 'ARRAY_PIPELINE_DART_NORMAL')
    selected = {key: {route: value for route, value in row.items() if route != 'fresh'} for key, row in expected.items()}
    assert same(rows, selected), 'normal observations'
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if red else '0\n'), 'normal exit'
    suffix = b'+154 -19: Some tests failed.' if red else (b'+318: All tests passed!' if direct else b'+173: All tests passed!')
    assert suffix in body, 'normal semantic count'
    assert raw(phase + '/normal-stderr.log.gz') == b'', 'normal stderr'


def pairs(before, after, cases):
    for index, _case in enumerate(cases):
        for tail in (f'inputs/case_{index}.json', f'lib/case_{index}.dart'):
            assert before[str(REL / 'intake/fresh' / tail)] == after[str(REL / 'after/fresh' / tail)], 'parsed/module pair drift'


def main():
    sealed = json.loads((BASE / 'readonly-review/input-identities.json').read_bytes())
    for name, row in sealed.items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL) + '/')
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and (ROOT / path).stat().st_mode & 0o777 == row['mode'], 'readonly input identity'
    with tarfile.open(BASE / 'readonly-review/instruments-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == {str(REL / name) for name in ('review.py', 'check_current.py', 'record_review.py')}
        for member in archive:
            assert archive.extractfile(member).read() == (ROOT / member.name).read_bytes(), 'readonly producer identity'
    phases = ('intake', 'before', 'after', 'direct', 'private-old', 'private-fixed', 'format')
    data = {phase: inputs(phase) for phase in phases}
    original, candidate = data['intake']['root'], data['after']['root']
    old_owner = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert original[OWNER] == raw('owner-before.dart.gz') == old_owner
    assert candidate[OWNER] == raw('repair-run/owner-after.dart.gz') != old_owner
    assert candidate[NORMAL] == raw('repair-run/normal-after.dart.gz') and candidate[PROBE] == raw('repair-run/probe-after.dart.gz') == original[PROBE]
    image = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'dart', 'tests/fixtures', 'specs/spec.spec', GRAMMAR, 'specs/pplugin.spec'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(image)) as archive:
        for member in archive:
            if member.isfile():
                assert original[member.name] == archive.extractfile(member).read(), 'activation source bytes'
    for name, body in original.items():
        if name.startswith(('dart/', 'tests/fixtures/', 'specs/')) and name not in (OWNER, 'dart/.dart_tool/package_config.json'):
            assert candidate[name] == body, 'unrelated original input changed'
    cases = json.loads((BASE / 'cases.json').read_bytes())
    assert len(cases) == 173 and cases[:36] == json.loads(original[SHARED])
    assert same(cases, json.loads((BASE / 'intake/cases.json').read_bytes())) and same(cases, json.loads((BASE / 'after/cases.json').read_bytes()))
    profiles = json.loads(candidate[PROFILE])
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    red = set(baseline['red'])
    assert baseline['cases'] == 173 and baseline['shared'] == 36 and baseline['own'] == 137 and baseline['healthy'] == 154
    assert len(profiles) == baseline['profiles'] == 141 and len(red) == 19
    before, after = routes('intake'), routes('after')
    assert all(value == {'value': [None, '']} for value in before['constructor_array_guard'].values()), 'independent constructor guard'
    for key in ('invalid_range_free_terminal', 'invalid_range_receiver_terminal'):
        assert all(value == {'value': []} for value in before[key].values()), 'original regex fallback'
    validate(before, cases, profiles, red)
    validate(after, cases, profiles, set())
    for key in before.keys() - red:
        assert same(before[key], after[key]), 'healthy observation drift'
    normal('before', before, red)
    normal('private-old', before, red)
    normal('private-fixed', after, set())
    normal('direct', after, set(), direct=True)
    pairs(data['intake']['emitted'], data['after']['emitted'], cases)
    for phase in phases:
        assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        for path in (BASE / phase).glob('*-exit.txt'):
            expected = '1\n' if phase in ('before', 'private-old') and path.name == 'normal-exit.txt' else '0\n'
            assert path.read_text() == expected, 'actual command failure'
        for path in (BASE / phase).glob('*-command.json'):
            command = json.loads(path.read_bytes())
            assert command['environment'] == dict(TERM='dumb', NO_COLOR='1')
            tag = path.name.removesuffix('-command.json')
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file() and (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if tag == 'normal':
                assert '--concurrency=1' in command['argv']
        sdk = str(REL / 'control-owner/dart') if phase.startswith('private-') else 'dart'
        config = sdk + '/.dart_tool/package_config.json'
        routed(config, data[phase]['resolved'][config], sdk)
        if phase != 'intake' and not phase.startswith('private-'):
            assert data[phase]['root'][NORMAL] == candidate[NORMAL] and data[phase]['root'][PROFILE] == candidate[PROFILE], 'new explicit fixtures'
    for phase in ('intake', 'after'):
        config = str(REL / phase / 'fresh/.dart_tool/package_config.json')
        routed(config, data[phase]['fresh'][config], 'dart')
        assert raw(phase + '/native-stderr.log.gz') == raw(phase + '/fresh-stderr.log.gz') == b''
        prefix = 'ARRAY_PIPELINE_DART_GRAMMAR '
        grammar = [json.loads(line[len(prefix):]) for line in raw(phase + '/native-stdout.log.gz').decode().splitlines() if line.startswith(prefix)]
        assert grammar == [dict(path=GRAMMAR, source=original[GRAMMAR].decode())], 'actual explicit grammar'
    required = [NORMAL, PROFILE, GRAMMAR, str(REL / 'cases.json'),
        'dart/test/array_transform_result_guard_composition_test.dart',
        'docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json',
        'tests/fixtures/array_transform_result_guard_dart_profiles.json',
        'dart/test/value_copy_test.dart', 'tests/fixtures/value_copy_values.spec', 'tests/fixtures/value_copy_values.json']
    for name in required:
        assert name in data['direct']['root'], 'selected external direct input missing'
    default = json.loads((BASE / 'direct/default-grammar-resolution.json').read_bytes())
    assert default['selected'] == GRAMMAR and default['nearer_candidate_exists'] is False
    assert default['selected_sha256'] == hashlib.sha256(original[GRAMMAR]).hexdigest()
    control = str(REL / 'control-owner') + '/'
    old_private = {k: v for k, v in data['private-old']['root'].items() if k.startswith(control)}
    fixed_private = {k: v for k, v in data['private-fixed']['root'].items() if k.startswith(control)}
    assert old_private.keys() == fixed_private.keys()
    assert old_private[control + OWNER] == old_owner and fixed_private[control + OWNER] == candidate[OWNER]
    for name in old_private.keys() - {control + OWNER}:
        assert old_private[name] == fixed_private[name], 'private image drift'
    for tag in ('writer', 'formatter'):
        assert (BASE / 'repair-run' / (tag + '-exit.txt')).read_text() == '0\n'
    assert b'(0 changed)' in raw('format/format-stdout.log.gz') and raw('format/format-stderr.log.gz') == b'', 'scoped format'
    writer_inputs = json.loads((BASE / 'repair-run/inputs.json').read_bytes())
    with tarfile.open(BASE / 'repair-run/inputs.tar.gz') as archive:
        assert set(archive.getnames()) == set(writer_inputs)
        for member in archive:
            row = writer_inputs[member.name]
            body = archive.extractfile(member).read()
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
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
        ('receiver Hash effects', 'trim_each_receiver_hash_guard', {'value': [None, 'KV']}),
        ('late with effects', 'uniq_copy_later_with', {'value': ['ran', 'W']}),
        ('initial fallback', 'initial_number_trim_each_receiver_with', {'value': [None, '']}),
        ('excluded free X evaluated', 'extra_trim_each_free', {'value': ['ran', 'SXKW']}),
        ('needed error masked', 'needed_source_trim_each_receiver', {'value': 'masked'}),
        ('regex producer changed', 'invalid_range_free_terminal', {'value': None}),
        ('Boolean becomes Number', 'nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ]:
        changed = copy.deepcopy(after)
        changed[key] = {route: value for route in ROUTES}
        reject(label, lambda: validate(changed, cases, profiles, set()), 'target or preservation policy')
    changed = copy.deepcopy(before)
    changed['trim_each_receiver_hash_guard'] = copy.deepcopy(after['trim_each_receiver_hash_guard'])
    reject('hidden original RED', lambda: validate(changed, cases, profiles, red), 'hidden original RED')
    changed = copy.deepcopy(after)
    changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, cases, profiles, set()), 'route census')
    changed = dict(data['after']['emitted'])
    changed[str(REL / 'after/fresh/lib/case_0.dart')] += b'\n// corruption\n'
    reject('altered emitted input', lambda: pairs(data['intake']['emitted'], changed, cases), 'parsed/module pair drift')
    config = 'dart/.dart_tool/package_config.json'
    changed = json.loads(data['direct']['resolved'][config])
    next(p for p in changed['packages'] if p['name'] == 'linkedspec_dart')['rootUri'] = '../../'
    reject('wrong SDK routing', lambda: routed(config, json.dumps(changed).encode(), 'dart'), 'actual SDK routing')
    print('PASS:173 cases/shared36+own137;19 original targets/154 exact preservation;four routes;direct318;173 artifact pairs')
    print('PASS:actual own/new/external fixtures, grammar and relative resolved routing before use;private old/current same-path semantic controls;scoped analysis/format')
    print('PASS:' + str(len(controls)) + ' reason-sensitive corruptions: ' + '; '.join(controls))
    print('LIMIT:finite observed rows;generated errors retain class/text projection;native/VM/cache/transitive/toolchain/OS custody4.2/SESSION5 and full23.4 admission separate')


if __name__ == '__main__':
    main()
