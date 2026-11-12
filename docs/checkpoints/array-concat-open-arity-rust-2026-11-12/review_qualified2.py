"""Independently recover the finite Rust concat proof; execute no current SDK."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import subprocess
import tarfile
import sys

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
sys.path.insert(0, str(BASE))
import review_ordinary_qualified
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
NORMAL = 'rust/linkedspec-runtime/tests/array_concat_open_arity_result_guard_composition.rs'
CASES = 'tests/fixtures/array_concat_open_arity_rust_cases.json'
PROFILE = 'tests/fixtures/array_concat_open_arity_result_guard_rust_profiles.json'
OLD_PROFILE = 'tests/fixtures/array_transform_callable_result_guard_rust_profiles.json'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def same(left, right, reason):
    assert wire(left) == wire(right), reason


def digest(body):
    return hashlib.sha256(body).hexdigest()


def checked(body, mode, row):
    assert len(body) == row['bytes'] and digest(body) == row['sha256'], 'retained bytes'
    assert mode & 0o777 == row['mode'], 'retained mode'


def raw(name):
    return gzip.decompress((BASE / name).read_bytes())


def safe(name):
    path = PurePosixPath(name)
    assert not path.is_absolute() and '..' not in path.parts, 'relative path'


def recover(phase):
    result = {}
    selected = {OWNER, NORMAL, CASES, PROFILE, OLD_PROFILE, 'tests/fixtures/array_transform_result_guard_rust_profiles.json', 'tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json'}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        safe(packet['archive'])
        assert packet['archive'].startswith(str(REL / phase) + '/')
        tag = Path(packet['archive']).name.removesuffix('-inputs.tar.gz')
        assert tag not in result, 'duplicate packet'
        seen, bodies = set(), {}
        with tarfile.open(ROOT / packet['archive']) as archive:
            for member in archive:
                safe(member.name)
                assert member.isfile() and member.name not in seen, 'archive member'
                seen.add(member.name)
                row = packet['files'][member.name]
                keep = (member.name in selected or member.name.startswith(str(REL) + '/')
                    and not tag.endswith('-product'))
                count, hasher, chunks = 0, hashlib.sha256(), []
                stream = archive.extractfile(member)
                while chunk := stream.read(1024 * 1024):
                    hasher.update(chunk); count += len(chunk)
                    if keep:
                        chunks.append(chunk)
                assert count == row['bytes'] and hasher.hexdigest() == row['sha256'], 'retained bytes'
                assert member.mode & 0o777 == row['mode'], 'retained mode'
                if keep:
                    bodies[member.name] = b''.join(chunks)
        assert seen == packet['files'].keys(), 'archive census'
        result[tag] = dict(files=packet['files'], bodies=bodies)
    return result


def frames(body, tag):
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in result, 'duplicate frame'
        result[key] = json.loads(value)
    return result


def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'ARRAY_CONCAT_RUST')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'ARRAY_CONCAT_RUST_FRESH')
    assert native.keys() == fresh.keys(), 'fresh census'
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}


def source_delta(old, current):
    old_line = b'            "concat_arrays" => count == 2,\n'
    new_line = b'            "concat_arrays" => count >= 1,\n'
    old_comment = b'    // retain their original routes; variadic concat gains no new authority.\n'
    new_comment = b'    // retain their original routes. Concat keeps its existing open arity.\n'
    assert old.count(old_line) == current.count(new_line) == 1, 'source delta'
    assert old.count(old_comment) == current.count(new_comment) == 1, 'source delta'
    assert current.replace(new_line, old_line, 1).replace(new_comment, old_comment, 1) == old, 'source delta'


def pair(left, right):
    assert left == right, 'source pair'


def intent(case, original):
    key = case['id']
    if case['origin'] not in ('shared84', 'questions108'):
        return original[key]
    if case['origin'] == 'shared84':
        if case.get('question') == 'needed-producer-error':
            terminal = re.sub(r'_(hash|terminal)$', '_terminal', key)
            assert all(set(row) == {'error'} for row in original[terminal].values()), 'terminal error'
            return original[terminal]
        values = [] if case['empty'] else ['head', 'tail', 'end'][:case['array_count']]
        effects = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:case['array_count']]
        tail = case['tail']
        value = [values, effects] if tail == 'terminal' else [values[-1].upper(), effects] if tail == 'compatible' else [len(values), effects + 'W'] if tail == 'with_' else [None, effects]
    elif case.get('question') == 'valid-rest-source':
        effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
        value = [['head', 'tail', 'end'], effects] if case['tail'] == 'terminal' else [None, effects]
    elif case.get('question') == 'source-snapshot':
        value = [['head', 'tail', 'end'] if case['tail'] == 'terminal' else None, ['head', 'changed']]
    elif case.get('question') == 'nested-kinds':
        value = ['', '0', False, 0, None, {'k': [1]}, [False, 0], 'tail', 'end']
    else:
        return original[key]
    return {route: {'value': value} for route in ROUTES}


def validate(cases, profiles, original, after):
    keys = {case['id'] for case in cases}
    assert len(cases) == len(keys) == 504 and profiles.keys() == original.keys() == after.keys() == keys, 'record census'
    targets, compatibility, preserved = set(), set(), set()
    for case in cases:
        key = case['id']
        expected = intent(case, original)
        if key in {'own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'}:
            terminal = original[key + '_terminal_probe']
            for row in terminal.values():
                same(row, {'value': [['head', 'tail', 'tail', 1], 'SX']}, 'legacy terminal')
            expected = {route: {'value': [None, 'SX']} for route in ROUTES}
            role = 'legacy-operand-compatibility'; compatibility.add(key)
        elif wire(expected) != wire(original[key]):
            assert case.get('tail') in ('hash', 'later', 'composed'), 'supported terminal'
            role = 'supported-target'; targets.add(key)
        else:
            role = 'preservation'; preserved.add(key)
        same(after[key], expected, 'full observation:' + key)
        same(profiles[key], dict(case=case, role=role, **expected), 'full profile:' + key)
    assert (len(targets), len(compatibility), len(preserved)) == (16, 2, 486), 'classification'
    for question, count in (('initial-producer-policy', 80), ('invalid-signature', 8)):
        selected = [case for case in cases if case.get('question') == question]
        assert len(selected) == count, 'policy census'
        for case in selected:
            same(original[case['id']], after[case['id']], 'policy preservation')
    return targets | compatibility


def normal(phase, expected, red, packets):
    stdout = raw(phase + '/normal-stdout.log.gz')
    stderr = raw(phase + '/normal-stderr.log.gz')
    actual = frames(stderr, 'ARRAY_CONCAT_RUST_NORMAL')
    same(actual, {key: {route: row[route] for route in ROUTES[:-1]} for key, row in expected.items()}, 'normal observations')
    failed = {key.decode() for key in re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M)}
    assert failed == red, 'normal RED set'
    assert f'{504-len(red)} passed; {len(red)} failed'.encode() in stdout, 'normal totals'
    for tag, directory, field, packet in (
        ('ARRAY_CONCAT_RUST_NORMAL_PARSED_INPUT', 'normal-parsed', 'parsed', 'normal-parsed'),
        ('ARRAY_CONCAT_RUST_NORMAL_INPUT', 'normal-inputs', 'compiled', 'normal-serialized'),
    ):
        rows = frames(stderr, tag)
        assert rows.keys() == expected.keys() and len(packets[packet]['files']) == 504, 'normal snapshot census'
        for key, row in rows.items():
            assert packets[packet]['bodies'][str(REL / phase / directory / (key + '.json'))] == row[field].encode(), 'normal input'
    if not red:
        remaining = re.sub(rb'^ARRAY_CONCAT_RUST_NORMAL(?:_PARSED_INPUT|_INPUT)? \w+ \{.*\}\n', b'', stderr, flags=re.M)
        assert remaining == b'', 'normal unexpected stderr'


def main():
    rows = json.loads((BASE / 'qualified2-input-identities.json').read_bytes())
    with tarfile.open(BASE / 'qualified2-inputs-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == rows.keys(), 'qualified2 input census'
        for member in archive:
            body = archive.extractfile(member).read(); row = rows[member.name]
            checked(body, member.mode, row)
            path = ROOT / member.name
            checked(path.read_bytes(), path.stat().st_mode, row)
    assert (BASE / 'launches/review-qualified/exit.txt').read_text() == '1\n', 'original reader failure status'
    assert b'AssertionError: supported terminal' in raw('launches/review-qualified/stderr.log.gz'), 'original reader failure mechanism'
    for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        safe(name); path = ROOT / name
        checked(path.read_bytes(), path.stat().st_mode, row)
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct')
    data = {phase: recover(phase) for phase in phases}
    data['direct'].update(recover('direct-completion'))
    original_root, fixed_root = data['intake']['root'], data['after']['root']
    old, current = original_root['bodies'][OWNER], fixed_root['bodies'][OWNER]
    assert old == raw('owner-before.rs.gz') and current == raw('repair-run/owner-after.rs.gz')
    source_delta(old, current)
    names = set()
    command = ['git', 'archive', ACTIVATION, 'rust', 'tests/fixtures', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec', 'cli_conformance/cases/help/stdout.txt']
    with subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as archive:
            for member in archive:
                if member.isfile():
                    body = archive.extractfile(member).read(); row = original_root['files'][member.name]
                    assert len(body) == row['bytes'] and digest(body) == row['sha256'], 'Git source'
                    assert bool(member.mode & 0o111) == bool(row['mode'] & 0o111), 'Git executable class'
                    names.add(member.name)
        assert process.wait() == 0
    assert names == {name for name in original_root['files'] if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/'))}, 'Git census'
    cases = json.loads(fixed_root['bodies'][CASES]); profiles = json.loads(fixed_root['bodies'][PROFILE])
    same(cases, json.loads(original_root['bodies'][str(REL / 'cases.json')]), 'original case metadata')
    before, after = routes('intake'), routes('after')
    red = validate(cases, profiles, before, after)
    for phase in ('intake', 'after'):
        stdout = raw(phase + '/native-stdout.log.gz')
        for folder, tag, field in (
            ('parsed-inputs', 'ARRAY_CONCAT_RUST_PARSED_INPUT', 'parsed'),
            ('inputs', 'ARRAY_CONCAT_RUST_INPUT', 'compiled'),
        ):
            rows = frames(stdout, tag)
            assert rows.keys() == before.keys(), 'public snapshot census'
            for key, row in rows.items():
                name = str(REL / phase / 'fresh' / folder / (key + '.json'))
                assert data[phase]['fresh-source']['bodies'][name] == row[field].encode(), 'public snapshot'
    for case in cases:
        key = case['id']
        for folder in ('parsed-inputs', 'inputs', 'src/generated'):
            suffix = '.rs' if folder == 'src/generated' else '.json'
            left = str(REL / 'intake/fresh' / folder / (key + suffix))
            right = str(REL / 'after/fresh' / folder / (key + suffix))
            pair(data['intake']['fresh-source']['bodies'][left], data['after']['fresh-source']['bodies'][right])
    retired = json.loads((BASE / 'retired-intake.json').read_bytes())
    targets = [str(REL / 'intake' / name) for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
    assert retired['targets'] == targets, 'retirement targets'
    archived = {}
    for packet in data['intake'].values():
        archived.update(packet['files'])
    selected = {name: row for name, row in archived.items()
        if any(name == target or name.startswith(target + '/') for target in targets)}
    same({row['path']: {key: value for key, value in row.items() if key != 'path'} for row in retired['files']}, selected, 'retirement coverage')
    prior_profile = json.loads(original_root['bodies'][OLD_PROFILE])
    direct_profile = json.loads(data['direct']['root']['bodies'][OLD_PROFILE])
    expected_legacy = copy.deepcopy(prior_profile)
    for key in ('own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'):
        expected_legacy[key]['role'] = 'open-arity-operand-compatibility'
        for route in ROUTES:
            expected_legacy[key][route] = after[key][route]
    same(direct_profile, expected_legacy, 'legacy transfer')
    for case in cases:
        if case['origin'] == 'legacy312':
            key = case['id']
            same(before[key], {route: prior_profile[key][route] for route in ROUTES}, 'old own profile')
            for field in ('source', 'body', 'input', 'rule'):
                assert case[field] == prior_profile[key]['case'][field], 'old own source'
    for phase in phases:
        packets = data[phase]; root = packets['root']
        for name in names:
            expected = fixed_root['files'][name] if name == OWNER and phase not in ('intake', 'before') else original_root['files'][name]
            if name == OLD_PROFILE and phase in ('private-old', 'private-fixed', 'direct'):
                expected = data['direct']['root']['files'][name]
            same(root['files'][name], expected, 'root identity:' + phase + ':' + name)
        if phase != 'intake':
            for name in (NORMAL, CASES, PROFILE):
                same(root['files'][name], fixed_root['files'][name], 'normal input identity')
        assert (BASE / phase / 'activation.txt').read_text() == ACTIVATION + '\n'
        environment = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
        if phase != 'intake':
            environment['LINKEDSPEC_ARRAY_CONCAT_RUST_CAPTURE'] = str(REL / phase)
        for path in (BASE / phase).glob('*-command.json'):
            tag = path.name.removesuffix('-command.json'); command = json.loads(path.read_bytes())
            same(command['environment'], environment, 'command environment')
            assert command['cwd'] == '.'
            expected_exit = '101\n' if (tag == 'normal' and phase in ('before', 'private-old')) or (phase == 'direct' and tag == 'array_transform_result_guard_composition') else '0\n'
            assert (BASE / phase / (tag + '-exit.txt')).read_text() == expected_exit, 'command exit'
            for channel in ('stdout', 'stderr'):
                body = raw(phase + '/' + tag + '-' + channel + '.log.gz')
                if tag in ('native', 'fresh') and channel == 'stderr':
                    assert not body, 'SDK stderr'
            if tag in ('native', 'fresh', 'normal', 'array_transform_result_guard_composition', 'array_transform_callable_result_guard_composition', 'array_pipeline_callable_result_guard_composition'):
                executable = str(REL / phase / (tag + '-exec'))
                assert executable in packets[tag + '-product']['files'], 'executed product'
                assert command['argv'][:3] == ['bash', 'tools/project_data_run.sh', executable], 'executed command'
        if phase in ('before', 'private-old', 'private-fixed', 'direct'):
            normal(phase, before if phase in ('before', 'private-old') else after, red if phase in ('before', 'private-old') else set(), packets)
    private_old = data['private-old']['root']; private_fixed = data['private-fixed']['root']
    prefix = str(REL / 'control-owner') + '/'
    control_names = {name for name in private_old['files'] if name.startswith(prefix)}
    assert control_names == {name for name in private_fixed['files'] if name.startswith(prefix)}, 'same private population'
    assert control_names == {prefix + name for name in private_old['files']
        if name.startswith(('rust/', 'specs/', 'tests/', 'cli_conformance/'))}, 'private source census'
    for name in control_names:
        stripped = name[len(prefix):]
        if stripped == OWNER:
            assert private_old['bodies'][name] == old and private_fixed['bodies'][name] == current, 'same private owner'
        else:
            same(private_old['files'][name], private_fixed['files'][name], 'same private path')
            if stripped == 'rust/Cargo.toml':
                manifest = subprocess.check_output(['git', 'show', ACTIVATION + ':rust/Cargo.toml'], cwd=ROOT)
                dependency = posixpath.relpath('rgx/rgx-core', str(REL / 'control-owner/rust')).encode()
                expected = manifest.replace(b'path = "../rgx/rgx-core"', b'path = "' + dependency + b'"')
                assert private_old['bodies'][name] == expected, 'private public dependency path'
            else:
                same(private_old['files'][name], private_old['files'][stripped], 'private copied source')
    for phase in ('intake', 'after'):
        source = data[phase]['native-source']['bodies'][str(REL / phase / 'native/src/main.rs')]
        assert source.index(b'fs::write(&parsed_path') < source.index(b'validate(&parsed)') < source.index(b'compile(&parsed)'), 'parsed first use'
        part = source[source.index(b'let serialized ='):]
        assert part.index(b'fs::write(fresh.join("inputs")') < part.index(b'serde_json::from_str(&retained)'), 'compiled first use'
    normal_source = fixed_root['bodies'][NORMAL]
    assert normal_source.index(b'std::fs::write(&target') < normal_source.index(b'validate(&parsed)') < normal_source.index(b'compile(&parsed)'), 'normal parsed first use'
    part = normal_source[normal_source.index(b'let serialized ='):]
    assert part.index(b'std::fs::write(&target') < part.index(b'serde_json::from_str(&retained)'), 'normal compiled first use'
    ordinary_old, ordinary_final, ordinary_expected = review_ordinary_qualified.review(sys.modules[__name__], data, original_root, fixed_root)
    controls = []

    def reject(name, function, reason):
        try:
            function()
        except (AssertionError, KeyError) as error:
            assert reason in str(error), (name, str(error))
            controls.append(name)
        else:
            raise AssertionError('accepted corruption:' + name)

    for name, key, route, changed in (
        ('Hash operands', 'ordinary_1_free_hash', 'native', {'value': [['head'], 'SKV']}),
        ('later rejection', 'function_3_receiver_later', 'restored', {'value': ['ran', 'STUKVDW']}),
        ('source order', 'ordinary_3_free_terminal', 'plan', {'value': [['head', 'tail', 'end'], 'SUT']}),
        ('fresh divergence', 'ordinary_2_free_terminal', 'fresh', {'value': []}),
        ('empty with', 'ordinary_empty_free_with_', 'native', {'value': [None, '']}),
        ('snapshot', 'own80_snapshot_function_free_hash', 'native', {'value': [None, ['head']]}),
        ('nested Bool Number', 'own80_nested_function_free', 'native', {'value': ['', '0', 0, 0, None, {'k': [1]}, [False, 0], 'tail', 'end']}),
        ('rest effects', 'own80_signature_rest_multi_free_composed', 'native', {'value': [None, 'STU']}),
        ('legacy operands', 'own_extra_concat_arrays_free', 'native', {'value': [None, 'S']}),
        ('needed error', 'function_needed_source_free_hash', 'native', {'error': 'binding_kind_mismatch'}),
        ('invalid signature', 'own80_signature_fixed_missing_free_composed', 'native', {'value': None}),
    ):
        bad = copy.deepcopy(after); bad[key][route] = changed
        reject(name, lambda: validate(cases, profiles, before, bad), 'full observation:')
    bad = copy.deepcopy(after); del bad[next(iter(bad))]
    reject('record removed', lambda: validate(cases, profiles, before, bad), 'record census')
    initial = next(case['id'] for case in cases if case.get('question') == 'initial-producer-policy')
    bad = copy.deepcopy(after); bad[initial]['native'] = {'value': ['lost']}
    reject('initial policy', lambda: validate(cases, profiles, before, bad), 'full observation:')
    bad = copy.deepcopy(profiles); bad['ordinary_1_free_hash']['native']['error'] = 'extra'
    reject('field absence', lambda: validate(cases, bad, before, after), 'full profile:')
    reject('source expansion', lambda: source_delta(old, current + b'\n'), 'source delta')
    reject('result bound', lambda: source_delta(old, current.replace(b'"concat_arrays" => count >= 1,', b'"concat_arrays" => count >= 0,')), 'source delta')
    row = dict(bytes=3, sha256=digest(b'abc'), mode=0o644)
    reject('artifact byte', lambda: checked(b'abd', 0o644, row), 'retained bytes')
    reject('artifact mode', lambda: checked(b'abc', 0o755, row), 'retained mode')
    reject('absolute path', lambda: safe('/outside'), 'relative path')
    reject('escaping path', lambda: safe('../outside'), 'relative path')
    reject('duplicate frame', lambda: frames(b'ROW a {}\nROW a {}\n', 'ROW'), 'duplicate frame')
    reject('source pair byte', lambda: pair(b'original', b'changed'), 'source pair')
    bad = copy.deepcopy(direct_profile)
    key = next(key for key in bad if key not in ('own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'))
    bad[key]['native'] = {'value': None}
    reject('unqualified legacy transfer', lambda: same(bad, expected_legacy, 'legacy transfer'), 'legacy transfer')
    bad = copy.deepcopy(ordinary_final)
    key = next(key for key in bad if key not in ('extra_concat_arrays_free', 'extra_concat_arrays_receiver'))
    bad[key]['native'] = {'value': None}
    reject('ordinary unrelated transfer', lambda: same(bad, ordinary_expected, 'ordinary profile transfer'), 'ordinary profile transfer')
    legacy = next(case for case in cases if case['id'] == 'own_nested_scalar_kinds')
    same(intent(legacy, before), before[legacy['id']], 'legacy question preservation')
    bad = copy.deepcopy(cases)
    next(case for case in bad if case['id'] == legacy['id'])['origin'] = 'questions108'
    reject('legacy/new question collision', lambda: validate(bad, profiles, before, after), 'supported terminal')
    print(json.dumps(dict(readonly='PASS', programs=504, supported=16, compatibility=2, preserved=486,
        private_old_red=18, private_current=504, direct=1205, original_direct_exit=1, original_ordinary_passed=193, qualified_ordinary=2, qualified_missing_checks=508, corruption_controls=controls,
        limits='Historical exact public products/records; no current SDK execution, future freshness or full native/cache/transitive/toolchain/OS custody (4.2/SESSION5).'), sort_keys=True))


if __name__ == '__main__':
    main()
