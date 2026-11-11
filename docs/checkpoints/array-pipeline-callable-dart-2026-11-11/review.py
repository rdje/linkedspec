"""Readonly historical Dart pipeline proof; no current SDK execution."""
import copy
import gzip
import hashlib
import io
import json
import re
import posixpath
from pathlib import Path, PurePosixPath
import subprocess
import tarfile
from urllib.parse import unquote, urljoin, urlparse

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OWNER = 'dart/lib/src/runtime/interpreter.dart'
PROBE = 'dart/tool/probe_callable_array_pipeline_results.dart'
NORMAL = 'dart/test/array_pipeline_callable_result_guard_composition_test.dart'
PROFILE = 'tests/fixtures/array_pipeline_callable_result_guard_dart_profiles.json'
SHARED = 'tests/fixtures/array_pipeline_callable_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
ACTIVATION = '9ed018787cac456a0e0bf95942bcdb735f5e4e6c'
ROUTES = ('native', 'restored', 'plan', 'fresh')
OBS = 'dart/tool/callable_array_pipeline_observation.dart'
TRACE = 'dart/tool/trace_callable_array_pipeline_results.dart'
CONTROL = str(REL / 'control-owner') + '/'


def same(left, right):
    return json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))


def require_same(left, right):
    assert same(left, right)


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
    native = frames(raw(phase + '/native-stdout.log.gz'), 'CALLABLE_PIPELINE_DART')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'CALLABLE_PIPELINE_DART_FRESH')
    assert list(native) == list(fresh), 'fresh census'
    return {key: dict(value, fresh=fresh[key]) for key, value in native.items()}


def validate(actual, profiles):
    assert actual.keys() == profiles.keys(), 'route census'
    for key, profile in profiles.items():
        assert same(actual[key], {route: profile[route] for route in ROUTES}), 'complete wire result'


def normal(phase, expected, red, data):
    stdout = raw(phase + '/normal-stdout.log.gz')
    actual = frames(stdout, 'CALLABLE_PIPELINE_DART_NORMAL')
    assert same(actual, {key: {route: row[route] for route in ROUTES[:-1]} for key, row in expected.items()})
    failed = set(re.findall(rb'^\S+ \+\d+ -\d+: (\w+) \[E\]$', stdout, re.M))
    assert {key.decode() for key in failed} == red
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if red else '0\n')
    suffix = '+175 -19: Some tests failed.' if red else '+383: All tests passed!' if phase == 'direct' else '+194: All tests passed!'
    assert suffix.encode() in stdout
    parsed = frames(stdout, 'CALLABLE_PIPELINE_DART_NORMAL_INPUT')
    assert parsed.keys() == expected.keys()
    prefix = CONTROL if phase.startswith('private-') else ''
    folder = prefix + '.linkedspec-data/scratch/callable-pipeline-dart-normal/' + phase + '/'
    assert set(data['normal-parsed']) == {folder + key + '.json' for key in expected}
    for key, row in parsed.items():
        assert same(json.loads(data['normal-parsed'][folder + key + '.json']), row)
    assert raw(phase + '/normal-stderr.log.gz') == b''


def pairs(before, after, cases):
    for index, _case in enumerate(cases):
        for tail in (f'inputs/case_{index}.json', f'lib/case_{index}.dart'):
            assert before[str(REL / 'intake/fresh' / tail)] == after[str(REL / 'after/fresh' / tail)], 'parsed/module pair'


def source_delta(old, current):
    start = current.index(b'  bool _isOrdinaryArrayPipelineResultChain(')
    end = current.index(b'\n  bool ', start + 1)
    body = current[start:end]
    comment = b'''    // Function evaluation keeps invocation checks and source effects. A following
    // canonical pipeline owns result guards without becoming a free helper call.
'''
    changed = b'''      if (!compiledSpec.functionRegistry.hasName(receiver.name) &&
          (receiver.sourceMethod ?? receiver.name) == receiver.name &&
'''
    original = b'''      if (compiledSpec.functionRegistry.hasName(receiver.name)) {
        return false;
      }
      if ((receiver.sourceMethod ?? receiver.name) == receiver.name &&
'''
    assert body.count(comment) == body.count(changed) == 1
    body = body.replace(comment, b'', 1).replace(changed, original, 1)
    assert current[:start] + body + current[end:] == old, 'source scope'


def retained_first(source):
    assert source.index(b'inputFile.writeAsStringSync(serialized)') < source.index(b'inputFile.readAsStringSync()')
    assert source.index(b'inputFile.readAsStringSync()') < source.index(b'final compiled = compileSpec(parsed)')
    assert source.index(b'inputFile.readAsStringSync()') < source.index(b'final restored = SpecFile.fromJson(')


def main():
    for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    phases = ('intake', 'before', 'after', 'direct', 'private-old', 'private-fixed', 'trace')
    data = {phase: inputs(phase) for phase in phases}
    original, candidate = data['intake']['root'], data['after']['root']
    old_owner = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert original[OWNER] == raw('owner-before.dart.gz') == old_owner
    assert candidate[OWNER] == raw('repair-run/owner-after.dart.gz')
    source_delta(old_owner, candidate[OWNER])
    image = subprocess.check_output(['git', 'archive', ACTIVATION, 'dart', 'tests/fixtures',
        'specs/spec.spec', GRAMMAR, 'specs/pplugin.spec'], cwd=ROOT)
    git_names = set()
    with tarfile.open(fileobj=io.BytesIO(image)) as archive:
        for member in archive:
            if member.isfile():
                assert original[member.name] == archive.extractfile(member).read()
                git_names.add(member.name)
    assert git_names == {name for name in original if name.startswith(('dart/', 'tests/fixtures/', 'specs/'))
        and name not in (PROBE, OBS, 'dart/.dart_tool/package_config.json')}
    for phase in phases:
        private = phase.startswith('private-')
        prefix = CONTROL if private else ''
        root = data[phase]['root']
        for name in git_names:
            if phase == 'trace' and name.startswith('tests/fixtures/'):
                continue
            expected = candidate[name] if name == OWNER and phase not in ('intake', 'before', 'private-old', 'trace') else original[name]
            assert root[prefix + name] == expected, (phase, name)
        if phase not in ('intake', 'trace'):
            assert root[prefix + NORMAL] == candidate[NORMAL]
            assert root[prefix + PROFILE] == candidate[PROFILE]
        if phase != 'trace':
            assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        environment = dict(TERM='dumb', NO_COLOR='1')
        if phase in ('before', 'direct', 'private-old', 'private-fixed'):
            environment['LINKEDSPEC_CALLABLE_PIPELINE_DART_CAPTURE'] = phase
        commands = list((BASE / phase).glob('*-command.json'))
        assert len(commands) == (7 if phase in ('intake', 'after') else 4)
        for path in commands:
            record = json.loads(path.read_bytes()); tag = path.name.removesuffix('-command.json')
            assert record['environment'] == environment
            expected_cwd = str(REL / phase / 'fresh') if tag.startswith('fresh') else str(REL / 'control-owner/dart') if private else 'dart'
            assert record['cwd'] == expected_cwd
            assert record['argv'][:2] == ['bash', posixpath.relpath('tools/run_dart_project_data.sh', expected_cwd)]
            expected = '1\n' if phase in ('before', 'private-old') and tag == 'normal' else '0\n'
            assert (BASE / phase / (tag + '-exit.txt')).read_text() == expected
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file()
            assert (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if tag == 'normal':
                assert '--concurrency=1' in record['argv']
        sdk = prefix + 'dart'
        config = sdk + '/.dart_tool/package_config.json'
        routed(config, data[phase]['resolved'][config], sdk)

    cases = json.loads(candidate[str(REL / 'cases.json')])
    profiles = json.loads(candidate[PROFILE])
    assert len(cases) == len(profiles) == 194
    assert {case['id'] for case in cases} == profiles.keys()
    assert cases[:37] == json.loads(original[SHARED])
    for phase in ('intake', 'after'):
        assert cases == json.loads(data[phase]['root'][str(REL / phase / 'cases.json')])
    before, after = routes('intake'), routes('after')
    validate(after, profiles)
    roles = {role: {key for key, profile in profiles.items() if profile['role'] == role}
        for role in ('supported-target', 'pattern-compatibility', 'preservation')}
    assert {key: len(value) for key, value in roles.items()} == {
        'supported-target': 16, 'pattern-compatibility': 3, 'preservation': 175}
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    assert roles['supported-target'] == set(baseline['supported_targets'])
    assert roles['pattern-compatibility'] == set(baseline['compatibility'])
    red = roles['supported-target'] | roles['pattern-compatibility']
    for case in cases:
        key = case['id']; assert profiles[key]['case'] == case
        if key not in red:
            assert same(before[key], after[key])
        else:
            assert not same(before[key], after[key])
    for phase, expected, failures in (('before', before, red), ('private-old', before, red),
        ('private-fixed', after, set()), ('direct', after, set())):
        normal(phase, expected, failures, data[phase])
        public = 'intake' if failures else 'after'
        prefix = CONTROL if phase.startswith('private-') else ''
        folder = prefix + '.linkedspec-data/scratch/callable-pipeline-dart-normal/' + phase + '/'
        for index, case in enumerate(cases):
            assert data[phase]['normal-parsed'][folder + case['id'] + '.json'] == data[public]['emitted'][str(REL / public / f'fresh/inputs/case_{index}.json')]
    pairs(data['intake']['emitted'], data['after']['emitted'], cases)
    for phase in ('intake', 'after'):
        assert data[phase]['root'][PROBE] == original[PROBE]
        assert data[phase]['root'][OBS] == original[OBS]
        assert data[phase]['emitted'][str(REL / phase / 'fresh/lib/observation.dart')] == original[OBS]
        config = str(REL / phase / 'fresh/.dart_tool/package_config.json')
        routed(config, data[phase]['fresh'][config], 'dart')
        for tag in ('native', 'fresh'):
            assert raw(phase + '/' + tag + '-stderr.log.gz') == b''
        grammar = [json.loads(line.split(' ', 1)[1]) for line in raw(phase + '/native-stdout.log.gz').decode().splitlines()
            if line.startswith('CALLABLE_PIPELINE_DART_GRAMMAR ')]
        assert grammar == [dict(path=GRAMMAR, source=original[GRAMMAR].decode())]
    for name in (NORMAL, PROFILE, PROBE, OBS, GRAMMAR, str(REL / 'cases.json'),
        'dart/test/array_pipeline_result_guard_composition_test.dart',
        'docs/checkpoints/array-pipeline-result-guard-dart-2026-11-11/cases.json',
        'tests/fixtures/array_pipeline_result_guard_dart_profiles.json',
        'dart/test/key_count_callable_result_guard_composition_test.dart',
        'tests/fixtures/key_count_callable_result_cases.json',
        'tests/fixtures/key_count_callable_dart_profiles.json'):
        assert name in data['direct']['root'], 'direct fixture closure'
    old_private = {name: body for name, body in data['private-old']['root'].items() if name.startswith(CONTROL)}
    fixed_private = {name: body for name, body in data['private-fixed']['root'].items() if name.startswith(CONTROL)}
    assert old_private.keys() == fixed_private.keys()
    assert old_private[CONTROL + OWNER] == old_owner
    assert fixed_private[CONTROL + OWNER] == candidate[OWNER]
    for name in old_private.keys() - {CONTROL + OWNER}:
        assert old_private[name] == fixed_private[name]
    retained_first(original[PROBE])
    normal_source = candidate[NORMAL]
    assert normal_source.index(b'target.writeAsStringSync(serialized)') < normal_source.index(b'target.readAsStringSync()')
    assert normal_source.index(b'target.readAsStringSync()') < normal_source.index(b'final compiled = compileSpec(parsed)')
    assert b'error.toJson()' in original[OBS] and b'error is GeneratedSourceException' in original[OBS]

    repair = BASE / 'repair-run'
    identities = json.loads((repair / 'input-identities.json').read_bytes())
    seen = set()
    with tarfile.open(repair / 'inputs-before-use.tar.gz') as archive:
        for member in archive:
            assert member.name not in seen; seen.add(member.name)
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
    assert seen == identities.keys()
    for tag in ('rehearsal', 'apply', 'format'):
        assert (repair / (tag + '-exit.txt')).read_text() == '0\n'
        assert raw('repair-run/' + tag + '-stderr.log.gz') == b''
    rehearsal = json.loads(raw('repair-run/rehearsal-stdout.log.gz'))
    applied = json.loads(raw('repair-run/apply-stdout.log.gz'))
    assert rehearsal['applied'] is False and applied['applied'] is True
    assert applied['before_sha256'] == rehearsal['before_sha256'] == hashlib.sha256(old_owner).hexdigest()
    assert applied['after_sha256'] == rehearsal['after_sha256'] == hashlib.sha256(candidate[OWNER]).hexdigest()
    assert b'(0 changed)' in raw('repair-run/format-stdout.log.gz')

    traced = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_PIPELINE_DART_TRACE')
    traced_inputs = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_PIPELINE_DART_TRACE_INPUT')
    assert len(traced) == 7 and traced.keys() == traced_inputs.keys()
    trace_source = data['trace']['root'][TRACE]
    assert trace_source.index(b'writeAsStringSync(serialized)') < trace_source.index(b'compileSpec(parsed, trace: trace)')
    for key, actual in traced.items():
        assert same(actual, before[key]['native'])
        parsed = data['trace']['actual-traces'][str(REL / 'trace/inputs' / (key + '.json'))]
        assert same(json.loads(parsed), traced_inputs[key])
        index = next(index for index, case in enumerate(cases) if case['id'] == key)
        assert parsed == data['intake']['emitted'][str(REL / 'intake/fresh' / f'inputs/case_{index}.json')]
        trace = data['trace']['actual-traces'][str(REL / 'trace' / (key + '.trace.log'))]
        assert b'dart_frontend:parse_spec_with_functions' in trace
        assert b'dart_compiler:compile_spec' in trace and b'dart_runtime:parse' in trace

    legacy = json.loads((BASE / 'restore-order-result.json').read_bytes())
    sources = []
    for name in legacy['archive_owners']:
        with tarfile.open(ROOT / name) as archive:
            sources.append(archive.extractfile(legacy['source']).read())
    assert sources[0] == sources[1]
    assert len(sources[0]) == legacy['bytes'] and hashlib.sha256(sources[0]).hexdigest() == legacy['sha256']
    assert sources[0].index(b'final restored = SpecFile.fromJson(') < sources[0].index(b'writeAsStringSync(jsonEncode(parsed.toJson()))')

    controls = []
    def reject(label, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)

    reject('actual old registered receiver result is RED', lambda: validate(before, profiles))
    for label, key, result in (
        ('receiver operands execute', 'trim_each_receiver_hash_guard', {'value': [None, 'KV']}),
        ('source effect lost', 'own_signature_variadic_multi_composed', {'value': [None, '']}),
        ('valid empty initial skips with', 'initial_number_trim_each_receiver_with', {'value': [None, '']}),
        ('excluded free X evaluated', 'extra_trim_each_free', {'value': ['ran', 'SXKW']}),
        ('function signature error masked', 'own_signature_fixed_missing_composed', {'value': [None, '']}),
        ('needed source error masked', 'needed_source_trim_each_receiver', {'value': 'masked'}),
        ('regex result guard bypassed', 'invalid_range_receiver_composed', {'value': []}),
        ('existing pattern P skipped', 'own_pattern_block_composed', {'value': [None, '']}),
        ('Boolean becomes Number', 'nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ):
        changed = copy.deepcopy(after); assert key in changed
        changed[key] = {route: result for route in ROUTES}
        reject(label, lambda: validate(changed, profiles))
    changed = copy.deepcopy(after)
    changed['needed_source_trim_each_receiver']['plan']['error_json']['source_identity'] = 'wrong.spec'
    reject('generated source attribution changed', lambda: validate(changed, profiles))
    changed = copy.deepcopy(after); changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, profiles))
    changed = dict(data['after']['emitted'])
    path = str(REL / 'after/fresh/lib/case_0.dart'); changed[path] += b'\n// corruption\n'
    reject('emitted module changed', lambda: pairs(data['intake']['emitted'], changed, cases))
    reject('unrelated source edit', lambda: source_delta(old_owner, candidate[OWNER] + b'\n'))
    reject('old private image called repaired', lambda: require_same(
        hashlib.sha256(old_private[CONTROL + OWNER]).hexdigest(), hashlib.sha256(candidate[OWNER]).hexdigest()))
    reject('historical restore-before-persist promoted', lambda: retained_first(sources[0]))
    config = 'dart/.dart_tool/package_config.json'
    bad = json.loads(data['direct']['resolved'][config])
    next(package for package in bad['packages'] if package['name'] == 'linkedspec_dart')['rootUri'] = '../../'
    reject('own SDK routing changed', lambda: routed(config, json.dumps(bad).encode(), 'dart'))
    return dict(recovery='PASS', programs=len(cases), routes=4, supported_targets=16,
        separate_pattern_compatibility=3, preserved=175, parsed_module_pairs=2 * len(cases),
        normal_parsed_inputs=4 * len(cases), traced_parsed_inputs=len(traced), direct_groups=383,
        effective_corruptions=controls,
        limits='Finite authored controls; complete available RuntimeInterpreterException/GeneratedSourceException wire maps, no missing historical field recovery. Three pattern compatibility movements grant no new pattern admission. New capture order fixed; inherited Rust/Dart audit4.24 remains before admission. Native/VM/cache/transitive/toolchain4.2/SESSION5, source/context/isolation/registration/declared5.4/full23.4 remain open.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
