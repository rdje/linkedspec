"""Readonly historical Dart transform proof; no current SDK execution."""
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
PROBE = 'dart/tool/probe_callable_array_transform_results.dart'
NORMAL = 'dart/test/array_transform_callable_result_guard_composition_test.dart'
PROFILE = 'tests/fixtures/array_transform_callable_result_guard_dart_profiles.json'
SHARED = 'tests/fixtures/array_transform_callable_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
ACTIVATION = '5ac1fac5eb7126cd8f952858f8df194914884830'
ROUTES = ('native', 'restored', 'plan', 'fresh')
OBS = 'dart/tool/callable_array_transform_observation.dart'
TRACE = 'dart/tool/trace_callable_array_transform_results.dart'
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
    native = frames(raw(phase + '/native-stdout.log.gz'), 'CALLABLE_TRANSFORM_DART')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'CALLABLE_TRANSFORM_DART_FRESH')
    assert list(native) == list(fresh), 'fresh census'
    return {key: dict(value, fresh=fresh[key]) for key, value in native.items()}


def validate(actual, profiles):
    assert actual.keys() == profiles.keys(), 'route census'
    for key, profile in profiles.items():
        assert same(actual[key], {route: profile[route] for route in ROUTES}), 'complete wire result'


def normal(phase, expected, red, data):
    stdout = raw(phase + '/normal-stdout.log.gz')
    actual = frames(stdout, 'CALLABLE_TRANSFORM_DART_NORMAL')
    assert same(actual, {key: {route: row[route] for route in ROUTES[:-1]} for key, row in expected.items()})
    failed = set(re.findall(rb'^\S+ \+\d+ -\d+: (\w+) \[E\]$', stdout, re.M))
    assert {key.decode() for key in failed} == red
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if red else '0\n')
    suffix = '+281 -31: Some tests failed.' if red else '+647: All tests passed!' if phase == 'direct' else '+312: All tests passed!'
    assert suffix.encode() in stdout
    parsed = frames(stdout, 'CALLABLE_TRANSFORM_DART_NORMAL_INPUT')
    assert parsed.keys() == expected.keys()
    prefix = CONTROL if phase.startswith('private-') else ''
    folder = prefix + '.linkedspec-data/scratch/callable-transform-dart-normal/' + phase + '/'
    assert set(data['normal-parsed']) == {folder + key + '.json' for key in expected}
    for key, row in parsed.items():
        assert same(json.loads(data['normal-parsed'][folder + key + '.json']), row)
    assert raw(phase + '/normal-stderr.log.gz') == b''


def pairs(before, after, cases):
    for index, _case in enumerate(cases):
        for tail in (f'inputs/case_{index}.json', f'lib/case_{index}.dart'):
            assert before[str(REL / 'intake/fresh' / tail)] == after[str(REL / 'after/fresh' / tail)], 'parsed/module pair'


def source_delta(old, current):
    start = current.index(b'  bool _isOrdinaryArrayTransformResultChain(')
    end = current.index(b'\n  bool ', start + 1)
    body = current[start:end]
    comment = b'''    // Function evaluation keeps invocation checks and source effects. A following
    // canonical transform owns result guards without becoming a free helper call.
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


def recover_archive(path, identities):
    recovered = {}
    with tarfile.open(path) as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in recovered
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            recovered[member.name] = body
    assert recovered.keys() == identities.keys()
    return recovered


def check_notice(stderr, row):
    assert len(stderr) == row['bytes'] == 83 and hashlib.sha256(stderr).hexdigest() == row['sha256']
    pid = row['observed_child_pid']
    assert stderr == f'tools/project_data_run.sh: child setpgid ({pid} to {pid}): Operation not permitted\n'.encode()
    assert row['original_final_pgid'] == 'uncaptured' and row['actual_comparator_exit'] == 0


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
                row = next(p for p in json.loads((BASE / 'intake/custody.json').read_bytes()) if p['tag'] == 'root')['files'][member.name]
                assert bool(row['mode'] & 0o111) == bool(member.mode & 0o111)
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
            environment['LINKEDSPEC_CALLABLE_TRANSFORM_DART_CAPTURE'] = phase
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
    assert len(cases) == len(profiles) == 312
    assert {case['id'] for case in cases} == profiles.keys()
    assert cases[:45] == json.loads(original[SHARED])
    for phase in ('intake', 'after'):
        assert cases == json.loads(data[phase]['root'][str(REL / phase / 'cases.json')])
    before, after = routes('intake'), routes('after')
    validate(after, profiles)
    roles = {role: {key for key, profile in profiles.items() if profile['role'] == role}
        for role in ('supported-target', 'initial-source-compatibility', 'preservation')}
    assert {key: len(value) for key, value in roles.items()} == {
        'supported-target': 28, 'initial-source-compatibility': 3, 'preservation': 281}
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    assert roles['supported-target'] == set(baseline['supported_targets'])
    assert roles['initial-source-compatibility'] == set(baseline['initial_source_compatibility'])
    red = roles['supported-target'] | roles['initial-source-compatibility']
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
        folder = prefix + '.linkedspec-data/scratch/callable-transform-dart-normal/' + phase + '/'
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
            if line.startswith('CALLABLE_TRANSFORM_DART_GRAMMAR ')]
        assert grammar == [dict(path=GRAMMAR, source=original[GRAMMAR].decode())]
    for name in (NORMAL, PROFILE, PROBE, OBS, GRAMMAR, str(REL / 'cases.json'),
        'dart/test/array_transform_result_guard_composition_test.dart',
        'docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json',
        'tests/fixtures/array_transform_result_guard_dart_profiles.json',
        'dart/test/array_pipeline_callable_result_guard_composition_test.dart',
        'docs/checkpoints/array-pipeline-callable-dart-2026-11-11/cases.json',
        'tests/fixtures/array_pipeline_callable_result_guard_dart_profiles.json'):
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

    traced = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_TRANSFORM_DART_TRACE')
    traced_inputs = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_TRANSFORM_DART_TRACE_INPUT')
    assert len(traced) == 9 and traced.keys() == traced_inputs.keys()
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

    initial = [case['id'] for case in cases if case.get('question') in (
        'initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
    assert len(initial) == 104 and all(same(before[key], after[key]) for key in initial)
    assert after['own_scalar_bool_receiver_with']['native'] == {'value': [None, '']}
    assert after['own_scalar_bool_free_with']['native'] == {'value': [0, 'W']}
    for phase in ('before', 'after', 'direct'):
        grammar = json.loads((BASE / phase / 'default-grammar-resolution.json').read_bytes())
        assert grammar['nearer_candidate_exists'] is False and grammar['selected'] == GRAMMAR
        assert grammar['selected_sha256'] == hashlib.sha256(original[GRAMMAR]).hexdigest()

    # Gate every actual launcher input and producer, including analysis/repair
    # and evidence-generating scripts, rather than just the final runtime body.
    # This finite completed population excludes the reader's own unfinished
    # launcher. Its before-use inputs and eventual result are retained outside
    # the earlier seal by run_stage.py.
    completed_launches = ('prepare', 'format-tools', 'intake', 'inspect-intake',
        'prepare-trace', 'format-trace', 'trace', 'freeze-policy', 'format-normal',
        'prepare-epochs', 'before', 'check-before', 'repair', 'after', 'check-after',
        'launcher-notice', 'remaining', 'private-old', 'private-fixed', 'direct',
        'prepare-review', 'retire-live', 'current')
    for tag in completed_launches:
        folder = BASE / 'launches' / tag
        rows = json.loads((folder / 'identities.json').read_bytes())
        recovered = recover_archive(folder / 'inputs.tar.gz', rows)
        record = json.loads((folder / 'command.json').read_bytes())
        assert record['cwd'] == '.' and record['environment'] == {}
        producers = [name for name in record['argv'] if name.endswith('.py')]
        assert producers and all(name in recovered for name in producers)
        for name in producers:
            assert recovered[name] == (ROOT / name).read_bytes(), 'actual producer changed'
        assert (folder / 'exit.txt').read_text() == '0\n'
        stderr = gzip.decompress((folder / 'stderr.log.gz').read_bytes())
        if folder.name == 'check-after':
            notice = json.loads((BASE / 'launcher-notice.json').read_bytes())
            check_notice(stderr, notice)
        else:
            assert stderr == b'', 'unexpected actual outer stderr'
    assert (BASE / 'remaining/complete.txt').is_file()
    for phase in ('private-old', 'private-fixed', 'direct'):
        for suffix in ('', '-memory'):
            assert (BASE / 'remaining' / (phase + suffix + '-exit.txt')).read_text() == '0\n'
            assert raw('remaining/' + phase + suffix + '-stderr.log.gz') == b''
    retired = json.loads((BASE / 'retired-live-copies.json').read_bytes())
    assert len(retired) == 642
    for row in retired:
        assert not (ROOT / row['path']).exists()
        packet = next(p for p in json.loads((BASE / row['phase'] / 'custody.json').read_bytes()) if p['tag'] == row['tag'])
        assert row['identity'] == packet['files'][row['path']]
        assert row['archive'] == packet['archive']

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
        ('receiver Hash operands execute', 'take_receiver_hash_guard', {'value': [None, 'KV']}),
        ('later with evaluates', 'take_later_with', {'value': ['ran', 'W']}),
        ('source S is lost', 'own_source_before_rejection', {'value': [None, '']}),
        ('count N is lost', 'positive_take_receiver_terminal', {'value': [[], 'S']}),
        ('slice C is lost', 'positive_slice_receiver_terminal', {'value': [[], 'SN']}),
        ('concat T is lost', 'positive_concat_arrays_receiver_terminal', {'value': [[], 'S']}),
        ('valid empty Array skips first with', 'own_initial_number_take_receiver_with', {'value': [None, '']}),
        ('Boolean receiver adopts free empty policy', 'own_scalar_bool_receiver_with', {'value': [0, 'W']}),
        ('excluded free X evaluated', 'own_extra_sorted_free', {'value': ['ran', 'SXKVW']}),
        ('function signature error masked', 'own_signature_fixed_missing_composed', {'value': [None, '']}),
        ('needed source error masked', 'own_needed_source_take_receiver', {'value': 'masked'}),
        ('Boolean becomes Number', 'own_nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ):
        changed = copy.deepcopy(after); assert key in changed
        changed[key] = {route: result for route in ROUTES}
        reject(label, lambda: validate(changed, profiles))
    changed = copy.deepcopy(after)
    changed['own_needed_source_take_receiver']['plan']['error_json']['source_identity'] = 'wrong.spec'
    reject('generated source attribution changed', lambda: validate(changed, profiles))
    changed = copy.deepcopy(after); changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, profiles))
    changed = dict(data['after']['emitted'])
    path = str(REL / 'after/fresh/lib/case_0.dart'); changed[path] += b'\n// corruption\n'
    reject('emitted module changed', lambda: pairs(data['intake']['emitted'], changed, cases))
    reject('unrelated source edit', lambda: source_delta(old_owner, candidate[OWNER] + b'\n'))
    reject('old private image called repaired', lambda: require_same(
        hashlib.sha256(old_private[CONTROL + OWNER]).hexdigest(), hashlib.sha256(candidate[OWNER]).hexdigest()))
    late = original[PROBE].replace(b'inputFile.readAsStringSync()', b'inputFile.readAsStringSync_REPLACED()', 1)
    reject('parsed snapshot readback removed', lambda: retained_first(late))
    changed = copy.deepcopy(after)
    del changed['own_needed_source_take_receiver']['plan']['error_json']['stage']
    reject('available error field dropped', lambda: validate(changed, profiles))
    changed = copy.deepcopy(after)
    changed['own_needed_source_take_receiver']['native']['error_json']['invented'] = True
    reject('absent error field invented', lambda: validate(changed, profiles))
    reject('outer launcher notice suppressed', lambda: check_notice(b'', notice))
    reject('actual Dart stderr hidden', lambda: require_same(raw('after/native-stderr.log.gz') + b'warning', b''))
    config = 'dart/.dart_tool/package_config.json'
    bad = json.loads(data['direct']['resolved'][config])
    next(package for package in bad['packages'] if package['name'] == 'linkedspec_dart')['rootUri'] = '../../'
    reject('own SDK routing changed', lambda: routed(config, json.dumps(bad).encode(), 'dart'))
    return dict(recovery='PASS', programs=len(cases), routes=4, supported_targets=28,
        separate_initial_compatibility=3, preserved=281, initial_policies=104,
        parsed_module_pairs=2 * len(cases), normal_parsed_inputs=4 * len(cases),
        traced_parsed_inputs=len(traced), direct_groups=647, effective_corruptions=controls,
        limits='Finite authored full-wire controls only. Three initial-source continuations are separate compatibility; Boolean receiver-null/free-empty stays exact. Actual outer launcher83-byte notice retained under SESSION7, final PGID uncaptured. No full native/VM/cache/transitive/toolchain/OS4.2/SESSION5, historical4.24, context/isolation/registration/declared5.4/full23.4 admission.')



if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
