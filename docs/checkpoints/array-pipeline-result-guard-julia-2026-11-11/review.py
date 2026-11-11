"""Readonly finite Julia pipeline recovery; no live SDK execution."""
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
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
ACTIVATION = '00a56ed62acbde73f066c7e00cb79ea23a720728'
OWNER = 'julia/src/runtime/Interpreter.jl'
RUNNER = 'julia/test/runtests.jl'
NORMAL = 'julia/test/array_pipeline_result_guard_composition_test.jl'
CASES = 'tests/fixtures/array_pipeline_result_guard_julia_cases.json'
PROFILE = 'tests/fixtures/array_pipeline_result_guard_julia_profiles.json'
SHARED = 'tests/fixtures/array_pipeline_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
ROUTES = {'native', 'restored', 'plan', 'fresh'}


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


def frames(body, tag='ARRAY_PIPELINE_JULIA_NORMAL'):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows, 'duplicate frame'
            rows[key] = json.loads(value)
    return rows


def inputs(phase):
    result = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL / phase) + '/')
        assert packet['tag'] not in result
        files = {}
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in files
                body = archive.extractfile(member).read()
                row = packet['files'][member.name]
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode'], 'archive identity'
                files[member.name] = body
        assert files.keys() == packet['files'].keys(), 'archive census'
        result[packet['tag']] = files
    return result


def validate(rows, cases, profiles, red):
    assert set(rows) == {row['id'] for row in cases}, 'case census'
    failures = set()
    for case in cases:
        key = case['id']
        observed = rows[key]
        assert set(observed) == ROUTES, 'route census'
        assert same(observed['native'], observed['restored']), 'restored drift'
        assert same(observed['plan'], observed['fresh']), 'generated framing drift'
        if 'error' in observed['native']:
            assert observed['native']['class'] == 'RuntimeInterpreterException'
            assert set(observed['native']['diagnostic']) == {'code', 'stage', 'helper_name', 'actual_arity', 'expected_arity'}
            assert observed['plan'] == {'class': 'GeneratedSourceException', 'error': 'Generated Julia parser execution failed: ' + observed['native']['error']}, 'required error framing'
        else:
            assert all(same(observed['native'], value) for value in observed.values()), 'value route drift'
        for route, value in observed.items():
            if case.get('profile_only') or case.get('expected_error'):
                assert profiles[key]['source'] == case['source'] and profiles[key]['input'] == case['input'], 'profile identity'
                expected = profiles[key][route]
            else:
                expected = {'value': case['expected']}
            if not same(value, expected):
                failures.add(key)
            if key in red:
                assert not same(value, expected), 'hidden original RED'
            else:
                assert same(value, expected), 'target or preservation policy'
            if case.get('expected_error'):
                assert case['expected_error'] in value['error'], 'required error masked'
    assert failures == red, 'semantic target census'


def normal(phase, expected, red):
    stdout = raw(phase + '/normal-stdout.log.gz')
    rows = frames(stdout)
    assert same(rows, expected), 'normal observation drift'
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if red else '0\n'), 'normal exit'
    pattern = rb'Julia ordinary Array-pipeline result guards\s*\|\s*930\s+76\s+1006\s' if red else rb'Julia ordinary Array-pipeline result guards\s*\|\s*1006\s+1006\s'
    assert re.search(pattern, stdout), 'actual semantic counts'
    sdk = str(REL / 'control-owner/julia') if phase.startswith('private-') else 'julia'
    assert ('ARRAY_PIPELINE_JULIA_OWNER ' + sdk + '/src/LinkedSpecJulia.jl\n').encode() in stdout, 'actual SDK path'
    prefix = 'ARRAY_PIPELINE_JULIA_NORMAL_GRAMMAR '
    grammar = [json.loads(line[len(prefix):]) for line in stdout.decode().splitlines() if line.startswith(prefix)]
    assert len(grammar) == 1 and grammar[0]['path'] == GRAMMAR
    return grammar[0]['source'].encode()


def pairs(old, current, cases, phase):
    for case in cases:
        for directory, suffix in [('parsed', '.json'), ('emitted', '.jl')]:
            assert old[str(REL / 'intake' / directory / (case['id'] + suffix))] == current[str(REL / phase / directory / (case['id'] + suffix))], 'parsed/emitted pair drift'


def source_scope(old, candidate):
    text = candidate.decode()
    start = text.index('    array_pipeline_chain = _runtime_is_ordinary_array_pipeline_result_chain(')
    end = text.index('    array_transform_chain = _runtime_is_ordinary_array_transform_result_chain(', start)
    text = text[:start] + text[end:]
    line = '        initial_array_pipeline_source = preserve_initial_array_pipeline_source && call_index == 1\n'
    assert text.count(line) == 1
    text = text.replace(line, '')
    text = text.replace('            !initial_array_transform_source && !initial_array_pipeline_source &&\n', '            !initial_array_transform_source &&\n')
    start = text.index('function _runtime_is_ordinary_array_pipeline_operand(')
    end = text.index('function _runtime_is_ordinary_array_transform_operand(', start)
    text = text[:start] + text[end:]
    assert text.encode() == old, 'producer/scalar/index source scope'


def main():
    seal = json.loads((BASE / 'readonly-review/input-identities.json').read_bytes())
    for name, row in seal.items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL) + '/')
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and (ROOT / path).stat().st_mode & 0o777 == row['mode'], 'readonly input identity'
    with tarfile.open(BASE / 'readonly-review/instruments-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == {str(REL / name) for name in ('review.py', 'check_current.py', 'record_review.py')}
        for member in archive:
            assert archive.extractfile(member).read() == (ROOT / member.name).read_bytes(), 'readonly producer identity'
    phases = ('intake', 'before', 'after', 'direct', 'private-old', 'private-fixed')
    data = {phase: inputs(phase) for phase in phases}
    original, candidate = data['intake']['root'], data['after']['root']
    old_owner = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert original[OWNER] == raw('owner-before.jl.gz') == old_owner
    assert candidate[OWNER] == raw('repair-run/owner-after.jl.gz') != old_owner
    source_scope(old_owner, candidate[OWNER])
    assert candidate[RUNNER] == original[RUNNER].replace(b'include("array_transform_result_guard_composition_test.jl")', b'include("array_transform_result_guard_composition_test.jl")\ninclude("array_pipeline_result_guard_composition_test.jl")'), 'normal registration'
    image = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'julia', 'tests/fixtures', 'specs/spec.spec', GRAMMAR, 'specs/pplugin.spec'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(image)) as archive:
        for member in archive:
            if member.isfile():
                assert original[member.name] == archive.extractfile(member).read(), 'activation source bytes'
    for name, body in original.items():
        if name.startswith(('julia/', 'tests/fixtures/', 'specs/')) and name not in (OWNER, RUNNER):
            assert candidate[name] == body, 'unrelated input changed'
    cases = json.loads(candidate[CASES])
    profiles = json.loads(candidate[PROFILE])
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    red = set(baseline['red'])
    assert len(cases) == baseline['cases'] == 173 and len(profiles) == baseline['profiles'] == 141
    assert baseline['shared'] == 36 and baseline['own'] == 137 and baseline['healthy'] == 154 and len(red) == 19
    assert cases[:36] == json.loads(original[SHARED]) and cases == json.loads((BASE / 'cases.json').read_bytes())
    before = frames(raw('intake/native-stdout.log.gz'), 'ARRAY_PIPELINE_JULIA')
    after = frames(raw('after/normal-stdout.log.gz'))
    assert all(value == {'value': [None, '']} for value in before['constructor_array_guard'].values()), 'independent constructor guard'
    validate(before, cases, profiles, red)
    validate(after, cases, profiles, set())
    for key in before.keys() - red:
        assert same(before[key], after[key]), 'healthy record drift'
    version = raw('intake/version-stdout.log.gz')
    assert re.fullmatch(rb'julia version [0-9.]+\n', version), 'actual executable version'
    for phase in phases:
        assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        assert raw(phase + '/version-stdout.log.gz') == version, 'executable-version drift'
        for path in (BASE / phase).glob('*-exit.txt'):
            expected = '1\n' if phase in ('before', 'private-old') and path.name == 'normal-exit.txt' else '0\n'
            assert path.read_text() == expected, 'actual command failure'
        for path in (BASE / phase).glob('*-command.json'):
            command = json.loads(path.read_bytes())
            assert command['cwd'] == '.' and command['environment']['JULIA_NUM_THREADS'] == command['environment']['OPENBLAS_NUM_THREADS'] == '1'
            assert command['environment']['JULIA_PKG_PRECOMPILE_AUTO'] == '0'
            tag = path.name.removesuffix('-command.json')
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file() and (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if phase.startswith('private-'):
                assert '--compiled-modules=no' in command['argv'], 'private source cache bypass'
        if phase != 'intake':
            expected = before if phase in ('before', 'private-old') else after
            assert normal(phase, expected, red if phase in ('before', 'private-old') else set()) == original[GRAMMAR], 'actual explicit grammar'
            pairs(data['intake']['artifacts'], data[phase]['artifacts'], cases, phase)
            assert data[phase]['root'][NORMAL] == candidate[NORMAL] and data[phase]['root'][CASES] == candidate[CASES] and data[phase]['root'][PROFILE] == candidate[PROFILE], 'new explicit fixture input'
    direct = raw('direct/normal-stdout.log.gz')
    assert re.search(rb'Julia ordinary Array-transform result guards\s*\|\s*903\s+903\s', direct)
    assert re.search(rb'Julia value-copy contract\s*\|\s*12\s+12\s', direct)
    assert raw('direct/normal-stderr.log.gz') == b''
    required = ['julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/value_copy_test.jl',
        'tests/fixtures/array_transform_result_guard_julia_cases.json', 'tests/fixtures/array_transform_result_guard_julia_profiles.json',
        'tests/fixtures/value_copy_values.spec', 'tests/fixtures/value_copy_values.json', GRAMMAR]
    for name in required:
        assert name in data['direct']['root'], 'direct input binding missing'
    old_cases = json.loads(data['direct']['root']['tests/fixtures/array_transform_result_guard_julia_cases.json'])
    old_profiles = json.loads(data['direct']['root']['tests/fixtures/array_transform_result_guard_julia_profiles.json'])
    old_frames = frames(direct, 'ARRAY_TRANSFORM_JULIA_NORMAL')
    validate(old_frames, old_cases, old_profiles, set())
    assert len(old_frames) == 156
    assert sum('/direct/prior-transform/emitted/' in key for key in data['direct']['artifacts']) == 156
    selected = json.loads((BASE / 'direct-preflight/default-grammar-resolution.json').read_bytes())
    assert selected['selected'] == GRAMMAR and selected['selected_sha256'] == hashlib.sha256(original[GRAMMAR]).hexdigest()
    assert all(row['exists'] is False for row in selected['nearer']) and len(selected['nearer']) == 3
    assert selected['search_owner_sha256'] == hashlib.sha256(candidate[selected['search_owner']]).hexdigest()
    assert (BASE / 'direct-preflight/exit.txt').read_text() == '0\n'
    control = str(REL / 'control-owner') + '/'
    old_private = {k: v for k, v in data['private-old']['root'].items() if k.startswith(control)}
    fixed_private = {k: v for k, v in data['private-fixed']['root'].items() if k.startswith(control)}
    assert old_private.keys() == fixed_private.keys()
    assert old_private[control + OWNER] == old_owner and fixed_private[control + OWNER] == candidate[OWNER]
    for name in old_private.keys() - {control + OWNER}:
        assert old_private[name] == fixed_private[name], 'private image drift'
    for directory in ('repair-run', 'direct-preflight'):
        records = json.loads((BASE / directory / 'inputs.json').read_bytes())
        with tarfile.open(BASE / directory / 'inputs.tar.gz') as archive:
            assert set(archive.getnames()) == set(records)
            for member in archive:
                body = archive.extractfile(member).read()
                row = records[member.name]
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    assert (BASE / 'repair-run/writer-exit.txt').read_text() == '0\n'
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
        ('extra X skipped', 'extra_trim_each_free', {'value': ['ran', 'SKW']}),
        ('required error masked', 'needed_source_trim_each_receiver', {'value': 'masked'}),
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
    reject('missing route case', lambda: validate(changed, cases, profiles, set()), 'case census')
    changed = dict(data['after']['artifacts'])
    changed[str(REL / 'after/emitted/source_once.jl')] += b'\n# corruption\n'
    reject('altered emitted input', lambda: pairs(data['intake']['artifacts'], changed, cases, 'after'), 'parsed/emitted pair drift')
    changed = candidate[OWNER].replace(b'scalar_result = value isa Bool', b'scalar_result = false', 1)
    reject('scalar policy changed', lambda: source_scope(old_owner, changed), 'producer/scalar/index source scope')
    print('PASS:173 cases/shared36+own137;19 original targets/154 exact healthy;1006 assertions/four routes;direct1921;173 pairs across six epochs')
    print('PASS:actual own/new/external fixtures and default grammar;private noncached same-path source/loaded path;producer/scalar/index scope;actual version ' + version.decode().strip())
    print('PASS:' + str(len(controls)) + ' reason-sensitive corruptions: ' + '; '.join(controls))
    print('LIMIT:finite observed rows;generated errors retain class/text projection;native/cache/transitive/toolchain/OS custody4.2/SESSION5 and full23.4 admission separate')


if __name__ == '__main__':
    main()
