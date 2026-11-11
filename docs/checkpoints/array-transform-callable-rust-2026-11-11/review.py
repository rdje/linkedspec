"""Recover the finite Rust transform proof without executing a current SDK."""
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
ACTIVATION = '238da4cc727e9f5921990ef5e8575b45ceac2887'
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs'
CASES = 'tests/fixtures/array_transform_callable_rust_cases.json'
PROFILE = 'tests/fixtures/array_transform_callable_result_guard_rust_profiles.json'
SHARED = 'tests/fixtures/array_transform_callable_result_guard_cases.json'
CONTROL = str(REL / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')

def digest(body):
    return hashlib.sha256(body).hexdigest()

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def same(left, right):
    assert encoded(left) == encoded(right), 'full record'

def raw(name):
    return gzip.decompress((BASE / name).read_bytes())

def frames(body, tag):
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in result, 'duplicate frame'
        result[key] = json.loads(value)
    return result

def recover(phase):
    packets = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts
        assert str(path).startswith(str(REL / phase) + '/')
        tag = path.name.removesuffix('-inputs.tar.gz')
        assert tag not in packets
        bodies, seen = {}, set()
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in seen
                seen.add(member.name)
                row = packet['files'][member.name]
                keep = member.name in {OWNER, NORMAL, CASES, PROFILE, SHARED, 'rust/Cargo.toml',
                    CONTROL + OWNER, CONTROL + 'rust/Cargo.toml',
                    str(REL / 'observer.rs'), str(REL / 'trace_observer.rs')}
                keep |= member.name.startswith(str(REL / phase / 'fresh') + '/')
                keep |= member.name.startswith(str(REL / phase / 'normal-inputs') + '/')
                keep |= member.name.startswith(str(REL / phase / 'normal-parsed') + '/')
                keep |= phase == 'trace' and (member.name.startswith(str(REL / 'trace/inputs') + '/')
                    or member.name.startswith(str(REL / 'trace/parsed-inputs') + '/') or member.name.endswith('.trace.log'))
                hasher, count, chunks = hashlib.sha256(), 0, []
                stream = archive.extractfile(member)
                while chunk := stream.read(1024 * 1024):
                    hasher.update(chunk)
                    count += len(chunk)
                    if keep:
                        chunks.append(chunk)
                assert count == row['bytes'] and hasher.hexdigest() == row['sha256'], 'archive bytes'
                assert member.mode & 0o777 == row['mode'], 'captured filesystem mode'
                if keep:
                    bodies[member.name] = b''.join(chunks)
        assert seen == packet['files'].keys(), 'archive census'
        packets[tag] = dict(files=packet['files'], bodies=bodies)
    return packets

def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'CALLABLE_TRANSFORM_RUST')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'CALLABLE_TRANSFORM_RUST_FRESH')
    assert native.keys() == fresh.keys()
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}

def validate(actual, profiles):
    assert actual.keys() == profiles.keys(), 'route census'
    for key, profile in profiles.items():
        assert encoded(actual[key]) == encoded({route: profile[route] for route in ROUTES}), 'observation:' + key

def source_delta(old, current):
    start = current.index(b'    fn is_ordinary_array_transform_result_chain(')
    end = current.index(b'\n    fn ', start + 1)
    body = current[start:end]
    comment = b'''        // Function evaluation retains signature checks and source effects. Only
        // a following canonical transform establishes this function result guard.
'''
    changed = b'''            if self.spec.find_function(name).is_none()
                && Self::is_ordinary_array_transform_result_call(name, args, false)
            {
'''
    original = b'''            if self.spec.find_function(name).is_some() {
                return false;
            }
            if Self::is_ordinary_array_transform_result_call(name, args, false) {
'''
    assert body.count(comment) == body.count(changed) == 1, 'source scope'
    body = body.replace(comment, b'', 1).replace(changed, original, 1)
    assert current[:start] + body + current[end:] == old, 'source scope'

def pairs(cold, repaired, cases):
    for case in cases:
        key = case['id']
        for tail in ('parsed-inputs/' + key + '.json', 'inputs/' + key + '.json', 'src/generated/' + key + '.rs'):
            assert cold[str(REL / 'intake/fresh' / tail)] == repaired[str(REL / 'after/fresh' / tail)], 'source pair'

def parsed_before_compile(source, normal=False):
    write = b'std::fs::write(&target' if normal else b'fs::write(&parsed_path'
    assert source.index(write) < source.index(b'validate(&parsed)') < source.index(b'compile(&parsed)'), 'parsed before compile'

def serialized_before_restore(source, normal=False):
    source = source[source.index(b'let serialized ='):]
    write = b'std::fs::write(&target' if normal else b'fs::write(fresh.join("inputs")'
    read = b'std::fs::read_to_string(target)' if normal else b'fs::read_to_string('
    assert source.index(write) < source.index(read) < source.index(b'serde_json::from_str(&retained)'), 'serialized before restore'

def normal(phase, expected, red, capsules):
    stdout = raw(phase + '/normal-stdout.log.gz')
    stderr = raw(phase + '/normal-stderr.log.gz')
    actual = frames(stderr, 'CALLABLE_TRANSFORM_RUST_NORMAL')
    same(actual, {key: {route: row[route] for route in ROUTES[:-1]} for key, row in expected.items()})
    failures = {key.decode() for key in re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M)}
    assert failures == red
    assert (BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if red else '0\n')
    assert f'{312-len(red)} passed; {len(red)} failed'.encode() in stdout
    for tag, directory, field, packet in (
        ('CALLABLE_TRANSFORM_RUST_NORMAL_INPUT', 'normal-inputs', 'compiled', 'normal-serialized'),
        ('CALLABLE_TRANSFORM_RUST_NORMAL_PARSED_INPUT', 'normal-parsed', 'parsed', 'normal-parsed')):
        inputs = frames(stderr, tag)
        assert inputs.keys() == expected.keys() and len(capsules[packet]['bodies']) == 312
        for key, row in inputs.items():
            assert capsules[packet]['bodies'][str(REL / phase / directory / (key + '.json'))] == row[field].encode()

def main():
    for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256'], 'sealed bytes'
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct', 'trace')
    data = {phase: recover(phase) for phase in phases}
    original, candidate = data['intake']['root'], data['after']['root']
    old, current = original['bodies'][OWNER], candidate['bodies'][OWNER]
    assert old == raw('owner-before.rs.gz') and current == raw('repair-run/owner-after.rs.gz')
    source_delta(old, current)
    names = set()
    command = ['git', 'archive', ACTIVATION, 'rust', 'tests/fixtures', 'specs/spec.spec',
        'specs/user_function_definition.spec', 'specs/pplugin.spec', 'cli_conformance/cases/help/stdout.txt']
    with subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as archive:
            for member in archive:
                if member.isfile():
                    body = archive.extractfile(member).read()
                    row = original['files'][member.name]
                    assert len(body) == row['bytes'] and digest(body) == row['sha256']
                    # Git executable class and captured full permissions are distinct.
                    assert bool(member.mode & 0o111) == bool(row['mode'] & 0o111)
                    names.add(member.name)
        assert process.wait() == 0
    assert names == {name for name in original['files'] if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/'))}
    for phase in phases:
        root = data[phase]['root']
        for name in names:
            if phase == 'trace' and name.startswith('tests/fixtures/'):
                continue
            expected = candidate['files'][name] if name == OWNER and phase not in ('intake', 'before', 'trace') else original['files'][name]
            same(root['files'][name], expected)
        if phase not in ('intake', 'trace'):
            for name in (NORMAL, CASES, PROFILE):
                assert root['bodies'][name] == candidate['bodies'][name]
        if phase != 'trace':
            assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        environment = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
        if phase not in ('intake', 'trace'):
            environment['LINKEDSPEC_CALLABLE_TRANSFORM_RUST_CAPTURE'] = str(REL / phase)
        commands = list((BASE / phase).glob('*-command.json'))
        assert len(commands) == (12 if phase in ('intake', 'after') else 9 if phase == 'direct' else 5)
        for path in commands:
            record = json.loads(path.read_bytes())
            assert record['cwd'] == '.'
            same(record['environment'], environment)
            tag = path.name.removesuffix('-command.json')
            expected_exit = '101\n' if phase in ('before', 'private-old') and tag == 'normal' else '0\n'
            assert (BASE / phase / (tag + '-exit.txt')).read_text() == expected_exit
            assert (BASE / phase / (tag + '-stdout.log.gz')).is_file() and (BASE / phase / (tag + '-stderr.log.gz')).is_file()
            if tag in ('native', 'fresh', 'normal', 'trace', 'array_transform_result_guard_composition', 'array_pipeline_callable_result_guard_composition'):
                executable = str(REL / phase / (tag + '-exec'))
                assert executable in data[phase][tag + '-product']['files']
                assert record['argv'][:3] == ['bash', 'tools/project_data_run.sh', executable]
    cases, profiles = json.loads(candidate['bodies'][CASES]), json.loads(candidate['bodies'][PROFILE])
    assert len(cases) == len(profiles) == 312 and {case['id'] for case in cases} == profiles.keys()
    same(cases[:45], json.loads(original['bodies'][SHARED]))
    before, after = routes('intake'), routes('after')
    validate(after, profiles)
    red = {key for key, row in profiles.items() if row['role'] == 'supported-target'}
    preserved = {key for key, row in profiles.items() if row['role'] == 'preservation'}
    assert len(red) == 20 and len(preserved) == 292 and red | preserved == profiles.keys()
    assert red == set(json.loads((BASE / 'baseline.json').read_bytes())['supported_targets'])
    for case in cases:
        key = case['id']
        same(profiles[key]['case'], case)
        assert (encoded(before[key]) != encoded(after[key])) == (key in red)
    for channel in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        assert raw('intake/' + channel) == raw('after/' + channel)
    pairs(data['intake']['fresh-source']['bodies'], data['after']['fresh-source']['bodies'], cases)
    for phase, expected, failures in (('before', before, red), ('private-old', before, red), ('private-fixed', after, set()), ('direct', after, set())):
        normal(phase, expected, failures, data[phase])
        public = 'intake' if failures else 'after'
        for case in cases:
            key = case['id']
            for packet, directory in (('normal-serialized', 'inputs'), ('normal-parsed', 'parsed-inputs')):
                local = 'normal-inputs' if packet == 'normal-serialized' else 'normal-parsed'
                assert data[phase][packet]['bodies'][str(REL / phase / local / (key + '.json'))] == data[public]['fresh-source']['bodies'][str(REL / public / 'fresh' / directory / (key + '.json'))]
    for name, count in (('array_transform_result_guard_composition', 195), ('array_pipeline_callable_result_guard_composition', 194)):
        assert f'{count} passed; 0 failed'.encode() in raw('direct/' + name + '-stdout.log.gz')
    private = [{name: row for name, row in data[phase]['root']['files'].items() if name.startswith(CONTROL)} for phase in ('private-old', 'private-fixed')]
    assert private[0].keys() == private[1].keys()
    for name in private[0]:
        if name == CONTROL + OWNER:
            assert private[0][name]['sha256'] == digest(old) and private[1][name]['sha256'] == digest(current)
        else:
            same(private[0][name], private[1][name])
    manifest = original['bodies']['rust/Cargo.toml']
    adapter = posixpath.relpath('rgx/rgx-core', CONTROL + 'rust')
    assert manifest.count(b'path = "../rgx/rgx-core"') == 1
    assert data['private-old']['root']['bodies'][CONTROL + 'rust/Cargo.toml'] == manifest.replace(b'path = "../rgx/rgx-core"', ('path = "' + adapter + '"').encode())
    observer = original['bodies'][str(REL / 'observer.rs')]
    parsed_before_compile(observer)
    serialized_before_restore(observer)
    parsed_before_compile(candidate['bodies'][NORMAL], True)
    serialized_before_restore(candidate['bodies'][NORMAL], True)
    for phase in ('intake', 'after'):
        for tag, directory, field in (('CALLABLE_TRANSFORM_RUST_INPUT', 'inputs', 'compiled'), ('CALLABLE_TRANSFORM_RUST_PARSED_INPUT', 'parsed-inputs', 'parsed')):
            inputs = frames(raw(phase + '/native-stdout.log.gz'), tag)
            assert inputs.keys() == profiles.keys()
            for key, row in inputs.items():
                assert data[phase]['fresh-source']['bodies'][str(REL / phase / 'fresh' / directory / (key + '.json'))] == row[field].encode()
    identities = json.loads((BASE / 'repair-run/input-identities.json').read_bytes())
    with tarfile.open(BASE / 'repair-run/inputs-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == identities.keys()
        for member in archive:
            body, row = archive.extractfile(member).read(), identities[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256'] and member.mode & 0o777 == row['mode']
    for tag in ('rehearsal', 'apply', 'format'):
        assert (BASE / 'repair-run' / (tag + '-exit.txt')).read_text() == '0\n'
        assert raw('repair-run/' + tag + '-stderr.log.gz') == b''
    rehearsal, applied = [json.loads(raw('repair-run/' + tag + '-stdout.log.gz')) for tag in ('rehearsal', 'apply')]
    assert rehearsal['applied'] is False and applied['applied'] is True
    assert applied['before_sha256'] == rehearsal['before_sha256'] == digest(old)
    assert applied['after_sha256'] == rehearsal['after_sha256'] == digest(current)
    traced = frames(raw('trace/trace-stdout.log.gz'), 'CALLABLE_TRANSFORM_TRACE')
    trace_source = data['trace']['root']['bodies'][str(REL / 'trace_observer.rs')]
    parsed_before_compile(trace_source)
    assert trace_source.index(b'fs::write(output.join("inputs")') < trace_source.index(b'.execute_value_with_trace(')
    assert len(traced) == 7
    for key, observed in traced.items():
        same(observed, before[key]['native'])
        for directory in ('inputs', 'parsed-inputs'):
            assert data['trace']['actual-traces']['bodies'][str(REL / 'trace' / directory / (key + '.json'))] == data['intake']['fresh-source']['bodies'][str(REL / 'intake/fresh' / directory / (key + '.json'))]
        trace = raw('trace/' + key + '.trace.log.gz')
        assert trace == data['trace']['actual-traces']['bodies'][str(REL / 'trace' / (key + '.trace.log'))]
        assert b'rust_runtime:engine:execute_value' in trace and b'rust_runtime:engine:lifecycle_block' in trace
    controls = []
    def reject(label, operation, reason):
        try:
            operation()
        except AssertionError as error:
            assert str(error) == reason, 'wrong rejection: ' + label + ': ' + str(error)
            controls.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)
    first_old = next(key for key in profiles if encoded(before[key]) != encoded({route: profiles[key][route] for route in ROUTES}))
    reject('actual old guard results', lambda: validate(before, profiles), 'observation:' + first_old)
    for label, key, result in (
        ('late with executes', 'take_later_with', {'value': ['ran', 'KVW']}),
        ('source effect lost', 'source_effect_before_rejection', {'value': [None, '']}),
        ('count order lost', 'positive_take_receiver_composed', {'value': [None, 'S']}),
        ('slice order reversed', 'positive_slice_receiver_composed', {'value': [None, 'SCN']}),
        ('concat second operand skipped', 'positive_concat_arrays_receiver_composed', {'value': [None, 'S']}),
        ('initial valid empty skips with', 'own_initial_number_take_receiver_with', {'value': [None, '']}),
        ('initial concat element lost', 'own_initial_number_concat_arrays_receiver', {'value': ['tail']}),
        ('invalid function signature masked', 'own_signature_fixed_missing_composed', {'value': [None, '']}),
        ('needed source error masked', 'own_needed_source_take_receiver', {'value': 'masked'}),
        ('Boolean becomes Number', 'own_nested_scalar_kinds', {'value': [['', '0', None, 0, 0], [0, 0, None, '0', '']]})):
        changed = copy.deepcopy(after)
        changed[key] = {route: result for route in ROUTES}
        reject(label, lambda: validate(changed, profiles), 'observation:' + key)
    changed = copy.deepcopy(after)
    changed.pop('source_once')
    reject('missing fresh case', lambda: validate(changed, profiles), 'route census')
    for tail in ('src/generated/source_once.rs', 'inputs/source_once.json', 'parsed-inputs/source_once.json'):
        changed = dict(data['after']['fresh-source']['bodies'])
        changed[str(REL / 'after/fresh' / tail)] += b'corruption'
        reject('changed ' + tail, lambda: pairs(data['intake']['fresh-source']['bodies'], changed, cases), 'source pair')
    reject('unrelated source edit', lambda: source_delta(old, current + b'\n'), 'source scope')
    def private_image():
        assert private[0][CONTROL + OWNER]['sha256'] == digest(current), 'private owner'
    reject('old private image called repaired', private_image, 'private owner')
    early_compile = observer.replace(b'    let parsed_bytes =', b'    compile(&parsed).unwrap();\n    let parsed_bytes =', 1)
    reject('parsed snapshot after compile', lambda: parsed_before_compile(early_compile), 'parsed before compile')
    serialized_line = b'    let serialized = serde_json::to_string(&compiled).unwrap();\n'
    assert observer.count(serialized_line) == 1
    early_restore = observer.replace(serialized_line,
        serialized_line + b'    serde_json::from_str(&retained).unwrap();\n', 1)
    reject('serialized snapshot after restore', lambda: serialized_before_restore(early_restore), 'serialized before restore')
    return dict(recovery='PASS', programs=312, routes=4, supported_targets=20, preserved=292,
        actual_parsed_compiled_module_triples=624, normal_parsed_inputs=1248,
        normal_serialized_inputs=1248, traced_parsed_inputs=7, traced_serialized_inputs=7,
        direct_groups=701, effective_corruptions=controls,
        limits='Finite authored semantic/source-order proof. Full error strings and route envelopes are retained; typed diagnostic APIs were not acquired. Parsed snapshots precede compile; compiled inputs precede restore and invocation. Native/cache/transitive/toolchain/OS4.2/SESSION5, historical4.24, source/context/isolation/registration, declared Lua5.4 and full23.4 remain open. First review outer channels and later prose are outside the earlier semantic seal.')

if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
