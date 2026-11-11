"""Recover the finite Rust callable proof without executing the current SDK."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ACTIVATION = '7e99813d1a88b748cf310992a4ef6ffadf7e978f'
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/array_pipeline_callable_result_guard_composition.rs'
PROFILE = 'tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json'
CASES = 'tests/fixtures/array_pipeline_callable_rust_cases.json'
SHARED = 'tests/fixtures/array_pipeline_callable_result_guard_cases.json'
CONTROL = str(REL / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(left, right):
    assert json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(
        right, sort_keys=True, separators=(',', ':'))


def raw(name):
    return gzip.decompress((BASE / name).read_bytes())


def frames(body, tag):
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in result, 'duplicate frame'
        result[key] = json.loads(value)
    return result


def recover(phase):
    result = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts
        assert str(path).startswith(str(REL / phase) + '/')
        tag = path.name.removesuffix('-inputs.tar.gz')
        assert tag not in result
        seen, bodies = set(), {}
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in seen; seen.add(member.name)
                row = packet['files'][member.name]
                keep = member.name in {OWNER, NORMAL, PROFILE, CASES, SHARED, 'rust/Cargo.toml',
                    CONTROL + OWNER, CONTROL + 'rust/Cargo.toml',
                    str(REL / 'observer.rs'), str(REL / 'trace_observer.rs')}
                keep |= member.name.startswith(str(REL / phase / 'fresh/inputs') + '/')
                keep |= member.name.startswith(str(REL / phase / 'fresh/src/generated') + '/')
                keep |= member.name.startswith(str(REL / phase / 'normal-inputs') + '/')
                keep |= phase == 'trace' and member.name.startswith(str(REL / 'trace/inputs') + '/')
                chunks, hasher, size = [], hashlib.sha256(), 0
                stream = archive.extractfile(member)
                while chunk := stream.read(1024 * 1024):
                    hasher.update(chunk); size += len(chunk)
                    if keep:
                        chunks.append(chunk)
                assert size == row['bytes'] and hasher.hexdigest() == row['sha256']
                assert member.mode & 0o777 == row['mode']
                if keep:
                    bodies[member.name] = b''.join(chunks)
        assert seen == packet['files'].keys(), 'archive census'
        result[tag] = dict(files=packet['files'], bodies=bodies)
    return result


def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'CALLABLE_PIPELINE_RUST')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'CALLABLE_PIPELINE_RUST_FRESH')
    assert native.keys() == fresh.keys()
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}


def validate(actual, profiles):
    assert actual.keys() == profiles.keys(), 'route census'
    for key, profile in profiles.items():
        same(actual[key], {route: profile[route] for route in ROUTES})


def normal(phase, expected, red, capsules):
    stdout, stderr = raw(phase + '/normal-stdout.log.gz'), raw(phase + '/normal-stderr.log.gz')
    actual = frames(stderr, 'CALLABLE_PIPELINE_RUST_NORMAL')
    same(actual, {key: {route: row[route] for route in ROUTES[:-1]} for key, row in expected.items()})
    failed = set(re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M))
    assert {key.decode() for key in failed} == red
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if red else '0\n')
    assert f'{194 - len(red)} passed; {len(red)} failed'.encode() in stdout
    inputs = frames(stderr, 'CALLABLE_PIPELINE_RUST_NORMAL_INPUT')
    assert inputs.keys() == expected.keys()
    bodies = capsules['normal-serialized']['bodies']
    assert len(bodies) == 194
    for key, row in inputs.items():
        assert bodies[str(REL / phase / 'normal-inputs' / (key + '.json'))] == row['compiled'].encode()


def source_delta(old, current):
    start = current.index(b'    fn is_ordinary_array_pipeline_result_chain(')
    end = current.index(b'\n    fn ', start + 1)
    body = current[start:end]
    comment = b'''        // Function evaluation retains signature checks and source effects. Only
        // a following canonical pipeline establishes this function result guard.
'''
    changed = b'''            if self.spec.find_function(name).is_none()
                && Self::is_ordinary_array_pipeline_result_call(name, args, false)
            {
'''
    original = b'''            if self.spec.find_function(name).is_some() {
                return false;
            }
            if Self::is_ordinary_array_pipeline_result_call(name, args, false) {
'''
    assert body.count(comment) == body.count(changed) == 1
    body = body.replace(comment, b'', 1).replace(changed, original, 1)
    assert current[:start] + body + current[end:] == old, 'source scope'


def pairs(cold, repaired, cases):
    for case in cases:
        key = case['id']
        for tail in ('inputs/' + key + '.json', 'src/generated/' + key + '.rs'):
            assert cold[str(REL / 'intake/fresh' / tail)] == repaired[str(REL / 'after/fresh' / tail)], 'source pair'


def main():
    for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct', 'trace')
    data = {phase: recover(phase) for phase in phases}
    original = data['intake']['root']
    candidate = data['after']['root']
    old_owner = original['bodies'][OWNER]
    current_owner = candidate['bodies'][OWNER]
    assert old_owner == raw('owner-before.rs.gz')
    assert current_owner == raw('repair-run/owner-after.rs.gz')
    source_delta(old_owner, current_owner)

    # Stream the activation image instead of holding unrelated fixtures in RAM.
    command = ['git', 'archive', ACTIVATION, 'rust', 'tests/fixtures',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec',
        'cli_conformance/cases/help/stdout.txt']
    git_names = set()
    with subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as archive:
            for member in archive:
                if member.isfile():
                    body = archive.extractfile(member).read()
                    row = original['files'][member.name]
                    assert len(body) == row['bytes'] and digest(body) == row['sha256']
                    assert member.name not in git_names; git_names.add(member.name)
        assert process.wait() == 0
    assert git_names == {name for name in original['files']
        if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/'))}
    for phase in phases:
        root = data[phase]['root']
        for name in git_names:
            if phase == 'trace' and name.startswith('tests/fixtures/'):
                continue
            expected = candidate['files'][name] if name == OWNER and phase not in ('intake', 'before', 'trace') else original['files'][name]
            same(root['files'][name], expected)
        if phase not in ('intake', 'trace'):
            for name in (NORMAL, PROFILE, CASES):
                assert root['bodies'][name] == candidate['bodies'][name]
        if phase != 'trace':
            assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION

        expected_environment = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
        if phase not in ('intake', 'trace'):
            expected_environment['LINKEDSPEC_CALLABLE_PIPELINE_RUST_CAPTURE'] = str(REL / phase)
        commands = list((BASE / phase).glob('*-command.json'))
        assert len(commands) == (12 if phase in ('intake', 'after') else 9 if phase == 'direct' else 5)
        for path in commands:
            record = json.loads(path.read_bytes())
            assert record['cwd'] == '.'
            same(record['environment'], expected_environment)
            tag = path.name.removesuffix('-command.json')
            expected_exit = '101\n' if phase in ('before', 'private-old') and tag == 'normal' else '0\n'
            assert (BASE / phase / (tag + '-exit.txt')).read_text() == expected_exit
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file()
            assert (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if tag in ('native', 'fresh', 'normal', 'trace',
                'array_pipeline_result_guard_composition', 'key_count_callable_result_guard_composition'):
                executable = str(REL / phase / (tag + '-exec'))
                assert executable in data[phase][tag + '-product']['files']
                assert record['argv'][:2] == ['bash', 'tools/project_data_run.sh']
                assert record['argv'][2] == executable

    cases = json.loads(candidate['bodies'][CASES])
    profiles = json.loads(candidate['bodies'][PROFILE])
    assert len(cases) == len(profiles) == 194
    assert {case['id'] for case in cases} == profiles.keys()
    same(cases[:37], json.loads(original['bodies'][SHARED]))
    for phase in ('intake', 'after'):
        same(cases, json.loads((BASE / phase / 'cases.json').read_bytes()))
    before, after = routes('intake'), routes('after')
    assert len(before) == len(after) == 194
    validate(after, profiles)
    roles = {role: {key for key, profile in profiles.items() if profile['role'] == role}
        for role in ('supported-target', 'pattern-compatibility', 'preservation')}
    assert {key: len(value) for key, value in roles.items()} == {
        'supported-target': 8, 'pattern-compatibility': 3, 'preservation': 183}
    red = roles['supported-target'] | roles['pattern-compatibility']
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    assert roles['supported-target'] == set(baseline['supported_targets'])
    assert roles['pattern-compatibility'] == set(baseline['compatibility'])
    for case in cases:
        key = case['id']
        same(profiles[key]['case'], case)
        if key not in red:
            same(before[key], after[key])
        else:
            assert json.dumps(before[key], sort_keys=True) != json.dumps(after[key], sort_keys=True)
    for channel in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        assert raw('intake/' + channel) == raw('after/' + channel)
    pairs(data['intake']['fresh-source']['bodies'], data['after']['fresh-source']['bodies'], cases)
    for phase, expected, failures in (('before', before, red), ('private-old', before, red),
        ('private-fixed', after, set()), ('direct', after, set())):
        normal(phase, expected, failures, data[phase])
        public = 'intake' if failures else 'after'
        for case in cases:
            key = case['id']
            assert data[phase]['normal-serialized']['bodies'][str(REL / phase / 'normal-inputs' / (key + '.json'))] == data[public]['fresh-source']['bodies'][str(REL / public / 'fresh/inputs' / (key + '.json'))]
    for name, count in (('array_pipeline_result_guard_composition', 173),
        ('key_count_callable_result_guard_composition', 16)):
        assert f'{count} passed; 0 failed'.encode() in raw('direct/' + name + '-stdout.log.gz')

    private_old = {name: row for name, row in data['private-old']['root']['files'].items() if name.startswith(CONTROL)}
    private_current = {name: row for name, row in data['private-fixed']['root']['files'].items() if name.startswith(CONTROL)}
    assert private_old.keys() == private_current.keys()
    for name in private_old:
        if name == CONTROL + OWNER:
            assert private_old[name]['sha256'] == digest(old_owner)
            assert private_current[name]['sha256'] == digest(current_owner)
        else:
            same(private_old[name], private_current[name])
    manifest = original['bodies']['rust/Cargo.toml']
    adapter = posixpath.relpath('rgx/rgx-core', CONTROL + 'rust')
    assert manifest.count(b'path = "../rgx/rgx-core"') == 1
    adjusted = manifest.replace(b'path = "../rgx/rgx-core"', ('path = "' + adapter + '"').encode())
    assert data['private-old']['root']['bodies'][CONTROL + 'rust/Cargo.toml'] == adjusted

    # Capture mode persists and readbacks the serialized value before restoration.
    observer = original['bodies'][str(REL / 'observer.rs')]
    def retained_before_restore(source):
        assert source.index(b'fs::write(fresh.join("inputs")') < source.index(b'fs::read_to_string(')
        assert source.index(b'fs::read_to_string(') < source.index(b'serde_json::from_str(&retained)')
    retained_before_restore(observer)
    normal_source = candidate['bodies'][NORMAL]
    assert normal_source.index(b'std::fs::write(&target') < normal_source.index(b'std::fs::read_to_string(target)')
    assert normal_source.index(b'std::fs::read_to_string(target)') < normal_source.index(b'serde_json::from_str(&retained)')
    for phase in ('intake', 'after'):
        inputs = frames(raw(phase + '/native-stdout.log.gz'), 'CALLABLE_PIPELINE_RUST_INPUT')
        assert inputs.keys() == profiles.keys()
        for key, row in inputs.items():
            assert data[phase]['fresh-source']['bodies'][str(REL / phase / 'fresh/inputs' / (key + '.json'))] == row['compiled'].encode()

    # Preserve the historical omission rather than granting retroactive credit.
    legacy = 'docs/checkpoints/array-pipeline-result-guard-rust-2026-11-11'
    legacy_source = subprocess.check_output(['git', 'show', ACTIVATION + ':' + legacy + '/observer.rs'], cwd=ROOT)
    order = json.loads((BASE / 'restore-order-result2.json').read_bytes())
    assert digest(legacy_source) == order['sha256'] and len(legacy_source) == order['bytes']
    with tarfile.open(ROOT / order['retained_archive']) as archive:
        assert archive.extractfile(order['historical_observer']).read() == legacy_source
    assert legacy_source.index(b'serde_json::from_str(&serialized)') < legacy_source.index(b'fs::write(fresh.join("inputs")')
    first_failure = json.loads((BASE / 'restore-order-first-failure.json').read_bytes())
    assert first_failure['actual_exit'] == 1
    assert 'no separate raw file was captured' in first_failure['stderr_capture']

    repair = BASE / 'repair-run'
    identities = json.loads((repair / 'input-identities.json').read_bytes())
    seen = set()
    with tarfile.open(repair / 'inputs-before-use.tar.gz') as archive:
        for member in archive:
            assert member.name not in seen; seen.add(member.name)
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
    assert seen == identities.keys()
    for tag in ('rehearsal', 'apply', 'format'):
        assert (repair / (tag + '-exit.txt')).read_text() == '0\n'
        assert raw('repair-run/' + tag + '-stderr.log.gz') == b''
    rehearsal = json.loads(raw('repair-run/rehearsal-stdout.log.gz'))
    applied = json.loads(raw('repair-run/apply-stdout.log.gz'))
    assert rehearsal['applied'] is False and applied['applied'] is True
    assert applied['before_sha256'] == rehearsal['before_sha256'] == digest(old_owner)
    assert applied['after_sha256'] == rehearsal['after_sha256'] == digest(current_owner)
    assert raw('repair-run/format-stdout.log.gz') == b''

    traced = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_PIPELINE_TRACE')
    trace_inputs = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_PIPELINE_TRACE_INPUT')
    assert len(traced) == 7 and traced.keys() == trace_inputs.keys()
    assert data['trace']['root']['bodies'][str(REL / 'trace_observer.rs')].index(b'fs::write(') < data['trace']['root']['bodies'][str(REL / 'trace_observer.rs')].index(b'.execute_value_with_trace(')
    for key, actual in traced.items():
        same(actual, before[key]['native'])
        body = trace_inputs[key]['compiled'].encode()
        assert data['trace']['actual-traces']['bodies'][str(REL / 'trace/inputs' / (key + '.json'))] == body
        assert body == data['intake']['fresh-source']['bodies'][str(REL / 'intake/fresh/inputs' / (key + '.json'))]
        trace = (BASE / 'trace' / (key + '.trace.log')).read_bytes()
        assert b'rust_runtime:engine:execute_value' in trace
        assert b'rust_runtime:engine:lifecycle_block' in trace
    # Native trace is lifecycle/result evidence, not an expression-guard event.

    controls = []
    def reject(label, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)

    reject('actual old later-with result is RED', lambda: validate(before, profiles))
    for label, key, result in (
        ('late with executes', 'trim_later_with', {'value': ['ran', 'KVW']}),
        ('source effect lost', 'own_signature_variadic_multi_composed', {'value': [None, '']}),
        ('initial empty source skips valid with', 'initial_number_trim_each_receiver_with', {'value': [None, '']}),
        ('function signature error masked', 'own_signature_fixed_missing_composed', {'value': [None, '']}),
        ('required source error masked', 'needed_source_trim_each_receiver', {'value': 'masked'}),
        ('existing pattern producer effect skipped', 'own_pattern_block_composed', {'value': [None, '']}),
        ('Boolean becomes Number', 'nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ):
        changed = copy.deepcopy(after)
        assert key in changed
        changed[key] = {route: result for route in ROUTES}
        reject(label, lambda: validate(changed, profiles))
    changed = copy.deepcopy(after); changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, profiles))
    changed = dict(data['after']['fresh-source']['bodies'])
    path = str(REL / 'after/fresh/src/generated/source_once.rs'); changed[path] += b'\n// corruption\n'
    reject('emitted input changed', lambda: pairs(data['intake']['fresh-source']['bodies'], changed, cases))
    reject('unrelated source edit', lambda: source_delta(old_owner, current_owner + b'\n'))
    reject('old private image called repaired', lambda: same(private_old[CONTROL + OWNER]['sha256'], digest(current_owner)))
    reject('historical restore-before-persist promoted', lambda: retained_before_restore(legacy_source))
    return dict(recovery='PASS', programs=len(cases), routes=4, supported_targets=len(roles['supported-target']),
        separate_pattern_compatibility=len(roles['pattern-compatibility']), preserved=len(roles['preservation']),
        actual_serialized_module_pairs=2 * len(cases), normal_serialized_inputs=4 * len(cases),
        traced_serialized_inputs=len(traced), direct_groups=len(cases) + 173 + 16,
        effective_corruptions=controls,
        limits='Finite authored semantic/source-order evidence; three pattern compatibility changes grant no dynamic-pattern admission. New capture order retained; historical first-use gap4.24/raw audit stderr missing remain explicit. Other direct normals have semantic/source proof, not new serialized-before-use credit. Full native/cache/transitive/toolchain4.2/SESSION5/source/context/isolation/registration/declared5.4/full23.4 remain open.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
