"""Independent historical concat oracle. No SDK/capture/policy-writer imports."""
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
BASE = Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12')
ACTIVATION = 'b15ca562e8044d9a8a369e613926bf016598f708'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = 't/array_concat_open_arity_result_guard_composition.t'
FIXTURE = 'tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json'
LEGACY = 'tests/fixtures/array_transform_callable_result_guard_perl_cases.json'
LEGACY_NORMAL = 't/array_transform_callable_result_guard_composition.t'
PRIVATE = str(BASE / 'control-owner/MethodLowering.pm')
READY = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def equal(actual, expected):
    assert actual == expected


def exact(actual, expected):
    assert wire(actual) == wire(expected)


def read(name):
    if name == str(BASE / 'source-and-profile.diff'):
        row = json.loads((ROOT / BASE / 'patch_archive/identity.json').read_bytes())
        target = ROOT / BASE / 'patch_archive/source-and-profile.diff.gz'
        assert target.is_file() and not target.is_symlink()
        body = gzip.decompress(target.read_bytes())
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert target.stat().st_mode & 0o777 == row['mode']
        return body
    path = PurePosixPath(name)
    assert not path.is_absolute() and '..' not in path.parts
    target = ROOT / name
    assert target.is_file() and not target.is_symlink()
    return target.read_bytes()


def unpack(folder, stem='input', filename='inputs-before-first-run.tar.gz'):
    rows = json.loads(read(str(folder / (stem + '-identities.json'))))
    return unpack_rows(folder / filename, rows), rows


def unpack_rows(path, rows):
    result = {}
    with tarfile.open(ROOT / path) as archive:
        for member in archive:
            key = PurePosixPath(member.name)
            assert member.isfile() and not key.is_absolute() and '..' not in key.parts and member.name not in result
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    assert result.keys() == rows.keys()
    return result


def channel(folder, tag, name):
    return gzip.decompress(read(str(folder / (tag + '-' + name + '.log.gz'))))


def frames(stdout, stderr=b'', intake=False):
    records, products, owners = {}, {}, []
    row_tag = 'ARRAY_CONCAT_PERL' if intake else 'ARRAY_CONCAT_NORMAL_ROW'
    input_tag = 'ARRAY_CONCAT_INPUT' if intake else 'ARRAY_CONCAT_NORMAL_INPUT'
    for line in (stdout + b'\n' + stderr).decode().splitlines():
        line = line.lstrip()
        if line.startswith('# '):
            line = line[2:]
        if line.startswith('ARRAY_CONCAT_NORMAL_OWNER '):
            owners.append(json.loads(line[len('ARRAY_CONCAT_NORMAL_OWNER '):]))
        elif line.startswith((row_tag + ' ', input_tag + ' ')):
            tag, key, raw = line.split(' ', 2)
            chosen = records if tag == row_tag else products
            assert key not in chosen
            chosen[key] = json.loads(raw)
    return records, products, owners


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalized(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def project(row):
    return normalized({key: value for key, value in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


def loaded_owner(actual, logical, metadata, root_digest):
    path = PurePosixPath(actual['path'])
    suffix = PurePosixPath(logical)
    assert '..' not in path.parts
    if path.is_absolute():
        assert path.parts[-len(suffix.parts):] == suffix.parts
        prefix = PurePosixPath(*path.parts[:-len(suffix.parts)])
        assert hashlib.sha256(str(prefix).encode()).hexdigest() == root_digest
    else:
        assert str(path) == logical
    row = metadata[logical]
    assert actual['bytes'] == row['bytes'] and actual['sha256'] == row['sha256']


def receipt(phase):
    # Plain original receipts may be retired only after verified gzip preservation.
    relative = str(BASE / (phase + '-check.json'))
    if (ROOT / relative).is_file():
        return json.loads(read(relative))
    return json.loads(gzip.decompress(read(relative + '.gz')))


def source_scope(old, new):
    before = b''' my $minimum = ($method eq 'slice' || $method eq 'concat_arrays') ? 2 : 1;
 my $maximum = $method eq 'slice' ? 3 : ($method eq 'sorted' || $method eq 'reversed') ? 1 : 2;
 return 0 if $count < $minimum || $count > $maximum;
'''
    after = b''' my $minimum = $method eq 'slice' ? 2 : 1;
 my $maximum = $method eq 'concat_arrays' ? undef
  : $method eq 'slice' ? 3 : ($method eq 'sorted' || $method eq 'reversed') ? 1 : 2;
 return 0 if $count < $minimum || (defined($maximum) && $count > $maximum);
'''
    comment_old = b'# Ordinary Array transforms retain their existing producers and optional arities.'
    comment_new = b'# Ordinary Array transforms retain their existing producers and accepted arities.'
    assert old.count(before) == old.count(comment_old) == 1
    assert new == old.replace(before, after).replace(comment_old, comment_new)
    assert re.search(rb'concat_arrays\s*=>\s*\[1, undef\]', old)
    assert re.search(rb'concat_arrays\s*=>\s*\[1, undef\]', new)


def intended_value(case):
    count, tail = case['array_count'], case['tail']
    effects = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:count]
    elements = [] if case['empty'] else ['head', 'tail', 'end'][:count]
    value = elements if tail == 'terminal' else elements[-1].upper() if tail == 'compatible' else len(elements) if tail == 'with_' else None
    return [value, effects + ('W' if tail == 'with_' else '')]


def derive(cases, cold):
    expected = {key: project(row) for key, row in cold.items()}
    targets, non_array, rejected = [], ['own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'], [
        'own80_signature_fixed_missing_free_composed', 'own80_signature_rest_missing_free_composed']
    by_id = {row['id']: row for row in cases}
    for case in cases[:84]:
        key = case['id']
        if 'expected_error' in case:
            assert case['expected_error'] == 'binding_kind_mismatch'
            oracle = key[:-len(case['tail'])] + 'terminal'
            terminal = project(cold[oracle])
            for route in ('native', 'fresh'):
                assert 'binding_kind_mismatch' in wire(terminal[route + '_error'])
            exact(terminal['metadata'], READY)
            healthy = wire(expected[key]['metadata']) == wire(READY) and not expected[key]['warnings']
            healthy = healthy and all(expected[key][flag] == 1 and expected[key].get(route + '_error')
                and 'binding_kind_mismatch' in wire(expected[key][route + '_error'])
                for route, flag in (('native', 'native_callable'), ('fresh', 'loaded')))
            if not healthy:
                targets.append(key)
                expected[key] = terminal
        else:
            desired = intended_value(case)
            exact(desired, case['expected'])
            actual = cold[key]
            healthy = actual['metadata'] == READY and actual['loaded'] == actual['native_callable'] == 1 and not actual['warnings']
            healthy = healthy and all(actual[route + '_error'] is None and wire(actual[route]) == wire(desired) for route in ('native', 'fresh'))
            if not healthy:
                terminal = key[:-len(case['tail'])] + 'terminal'
                result = project(cold[terminal])
                exact(result['metadata'], READY)
                assert not result['warnings'] and result['native_error'] is result['fresh_error'] is None
                result.update(native=copy.deepcopy(desired), fresh=copy.deepcopy(desired))
                expected[key] = result
                targets.append(key)
    assert len(targets) == 18
    for case in cases[396:]:
        key = case['id']
        if case['question'] == 'valid-rest-source' and case['tail'] == 'composed':
            terminal = key.removesuffix('_composed') + '_terminal'
            result = project(cold[terminal])
            effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
            exact(result['native'], [['head', 'tail', 'end'], effects])
            result.update(native=[None, effects], fresh=[None, effects])
            expected[key] = result
            targets.append(key)
        elif case['question'] == 'source-snapshot' and case['tail'] == 'hash':
            terminal = key.removesuffix('_hash') + '_terminal'
            result = project(cold[terminal])
            exact(result['native'], [['head', 'tail', 'end'], ['head', 'changed']])
            result.update(native=[None, ['head', 'changed']], fresh=[None, ['head', 'changed']])
            expected[key] = result
            targets.append(key)
    assert len(targets) == 26
    for key in non_array:
        terminal = project(cold[key + '_terminal_probe'])
        exact(terminal['native'], [['head', 'tail', 'tail'], 'SX'])
        exact(terminal['metadata'], READY)
        result = project(cold[key])
        result.update(native=[None, 'SX'], fresh=[None, 'SX'], metadata=copy.deepcopy(READY))
        expected[key] = result
    for key in rejected:
        terminal = project(cold[key.removesuffix('_composed') + '_terminal'])
        assert terminal['metadata']['language_agnostic_action_ir_ready'] == 0
        assert terminal['metadata']['unresolved_helpers'] == (['pair'] if 'fixed' in key else ['keep'])
        exact(terminal['native'], [['tail', 'end'], 'TU'])
        terminal.update(native=[None, 'TU'], fresh=[None, 'TU'])
        expected[key] = terminal
    compatibility = non_array + rejected
    preserved = [case['id'] for case in cases if case['id'] not in targets + compatibility]
    assert len(preserved) == 474
    return expected, targets, compatibility, preserved


def observer_order(body):
    assert body.index(b'LinkedSpec::emit_generated_source(') < body.index(b"persist($id,'pm',$emitted)") < body.index(b'my $loaded=')
    assert body.index(b'parser_source_ref=>\\$handler') < body.index(b"persist($id,'handler.pl',$handler)") < body.index(b'$native->(')
    assert b'gunzip $path => \\$retained' in body and b'$retained eq $body' in body


def splice(before, after, changes):
    """Rebuild only the named JSON objects, retaining every surrounding byte."""
    original, qualified = json.loads(before), json.loads(after)
    assert len(original) == len(qualified)
    wanted = {row['case']['id']: row for row in qualified}
    decoder, cursor, edits = json.JSONDecoder(), before.index('[') + 1, []
    while True:
        while before[cursor].isspace() or before[cursor] == ',':
            cursor += 1
        if before[cursor] == ']':
            break
        row, end = decoder.raw_decode(before, cursor)
        key = row['case']['id']
        exact(row['case'], wanted[key]['case'])
        if key in changes:
            assert wire(row) != wire(wanted[key])
            edits.append((cursor, end, json.dumps(wanted[key], indent=2).replace('\n', '\n  ')))
        else:
            exact(row, wanted[key])
        cursor = end
    assert len(edits) == len(changes)
    for start, end, replacement in reversed(edits):
        before = before[:start] + replacement + before[end:]
    assert before == after


def artifact(record, products):
    for field, name in (('module_input', 'emitted'), ('handler_input', 'handler')):
        row, raw = record[field], products[name].encode()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        equal(gzip.decompress(read(row['path'])), raw)


def launch(folder, actual):
    rows = json.loads(read(str(folder / 'identities.json')))
    inputs = unpack_rows(folder / 'inputs.tar.gz', rows)
    command = json.loads(read(str(folder / 'command.json')))
    assert command['cwd'] == '.' and command['argv'][:2] == ['bash', 'tools/project_data_run.sh']
    equal(read(str(folder / 'exit.txt')), (str(actual) + '\n').encode())
    stderr = gzip.decompress(read(str(folder / 'stderr.log.gz')))
    if actual == 0:
        equal(stderr, b'')
    else:
        assert b'AssertionError' in stderr
    # The launched instrument itself was snapshotted before subprocess.run.
    script = next(arg for arg in command['argv'] if arg.endswith('.py'))
    equal(inputs[script], read(script))
    return inputs


def negative_controls(records, products, expected, cases, roots, metadata, old, new, digest):
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)

    current = {key: project(row) for key, row in records['restored'].items()}
    exact(current, expected)
    for key in ('function_3_free_hash', 'ordinary_1_receiver_later', 'function_needed_operand_free_hash'):
        assert wire(project(records['before'][key])) != wire(expected[key])
        reject('old target hidden: ' + key, lambda key=key: exact(project(records['before'][key]), expected[key]))
    key = 'function_3_free_hash'
    assert expected[key]['native'] == [None, 'STU']
    for effect in ('TU', 'SU', 'ST', 'STUSTU', 'STUKVDW'):
        changed = copy.deepcopy(expected[key]); changed['native'] = [None, effect]
        reject('source/operand/tail effect ' + effect, lambda changed=changed: exact(changed, expected[key]))
    changed = copy.deepcopy(current); changed.pop(key)
    reject('case omitted', lambda: exact(changed, expected))
    nested = 'own80_nested_function_free'
    assert type(expected[nested]['native'][2]) is bool and expected[nested]['native'][2] is False
    changed = copy.deepcopy(expected[nested]); changed['native'][2] = 0
    reject('nested Bool changed to Number', lambda: exact(changed, expected[nested]))
    changed = copy.deepcopy(expected[key]); assert type(changed['loaded']) is int and changed['loaded'] == 1
    changed['loaded'] = True
    reject('numeric load flag changed to Bool', lambda: exact(changed, expected[key]))
    needed = 'function_needed_operand_free_hash'
    assert expected[needed]['native_error']['stage'] and expected[needed]['fresh_error']
    changed = copy.deepcopy(expected[needed]); changed['native_error'].pop('stage')
    reject('needed error stage omitted', lambda: exact(changed, expected[needed]))
    changed = copy.deepcopy(expected[needed]); changed['fresh_error'] = None
    reject('needed error masked', lambda: exact(changed, expected[needed]))
    compile_key = 'function_3_receiver_hash'
    assert 'fresh' not in records['before'][compile_key] and not records['before'][compile_key]['loaded']
    changed = copy.deepcopy(records['before'][compile_key]); changed['fresh'] = None
    reject('fresh field invented after load failure', lambda: exact(changed, records['before'][compile_key]))
    rejected = 'own80_signature_fixed_missing_free_composed'
    assert expected[rejected]['metadata']['unresolved_helpers'] == ['pair']
    changed = copy.deepcopy(expected[rejected]); changed['metadata'] = copy.deepcopy(READY)
    reject('bad signature admitted', lambda: exact(changed, expected[rejected]))
    changed = copy.deepcopy(expected[rejected]); changed['metadata']['unresolved_helpers'] = ['concat_arrays']
    reject('original bad callee attribution lost', lambda: exact(changed, expected[rejected]))
    compatibility = 'own_extra_concat_arrays_free'
    assert expected[compatibility]['native'] == [None, 'SX']
    changed = copy.deepcopy(expected[compatibility]); changed['fresh'] = [None, 'S']
    reject('legacy excess-operand X skipped', lambda: exact(changed, expected[compatibility]))
    snapshot = 'own80_snapshot_function_free_hash'
    assert expected[snapshot]['native'] == [None, ['head', 'changed']]
    changed = copy.deepcopy(expected[snapshot]); changed['native'][1][1] = 'tail'
    reject('operand snapshot ordering lost', lambda: exact(changed, expected[snapshot]))
    for field in ('emitted', 'handler'):
        changed = copy.deepcopy(products['restored'][key]); changed[field] += '\n'
        reject('artifact changed: ' + field, lambda changed=changed: artifact(records['restored'][key], changed))
    observer = roots['intake'][str(BASE / 'observer.pl')]
    observer_order(observer)
    changed = observer.replace(b"persist($id,'pm',$emitted)", b'late_snapshot')
    reject('module before-use snapshot omitted', lambda: observer_order(changed))
    reject('unrelated SDK edit', lambda: source_scope(old, new + b'\n'))
    private = dict(path=PRIVATE + '.alias', bytes=metadata['inverse'][PRIVATE]['bytes'], sha256=metadata['inverse'][PRIVATE]['sha256'])
    reject('private owner alias', lambda: loaded_owner(private, PRIVATE, metadata['inverse'], digest))
    stderr = channel(BASE / 'restored', 'normal', 'stderr')
    assert b'ARRAY_CONCAT_NORMAL_ROW ' in stderr
    reject('normal diagnostic channel erased', lambda: equal(b'', stderr))
    preserved = next(case['id'] for case in cases[84:396] if case['id'] not in ('own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'))
    changed = copy.deepcopy(expected[preserved]); changed['warnings'].append('invented')
    reject('unrelated legacy profile changed', lambda: exact(changed, expected[preserved]))
    assert len(controls) == 25
    return controls


def main():
    qualification_rows = json.loads(read(str(BASE / 'patch_archive/input-identities.json')))
    qualification_inputs = unpack_rows(BASE / 'patch_archive/inputs-before-reader.tar.gz', qualification_rows)
    for name, body in qualification_inputs.items():
        equal(read(name), body)
        if name != str(BASE / 'source-and-profile.diff'):
            assert (ROOT / name).stat().st_mode & 0o777 == qualification_rows[name]['mode']
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    phases = ('intake', 'before', 'after', 'inverse', 'restored', 'direct')
    roots, metadata, records, products, owners = {}, {}, {}, {}, {}
    for phase in phases:
        roots[phase], metadata[phase] = unpack(BASE / phase)
        records[phase], products[phase], owners[phase] = frames(channel(BASE / phase, 'observer' if phase == 'intake' else 'normal', 'stdout'),
            channel(BASE / phase, 'observer' if phase == 'intake' else 'normal', 'stderr'), phase == 'intake')
    origin = {}
    paths = ['perl', 'specs', LEGACY, LEGACY_NORMAL, 't/array_transform_result_guard_composition.t',
        'tests/fixtures/array_transform_result_guard_cases.json', 'tests/fixtures/array_transform_result_guard_perl_profiles.json',
        'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json', 'tools/project_data_run.sh', 'tools/project_data_env.sh',
        'docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json']
    raw = subprocess.check_output(['git', 'archive', ACTIVATION, '--', *paths], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(raw)) as archive:
        for member in archive:
            if member.isfile():
                origin[member.name] = (archive.extractfile(member).read(), bool(member.mode & 0o111))
    old = origin[OWNER][0]
    new = gzip.decompress(read(str(BASE / 'owner-after.pm.gz')))
    source_scope(old, new)
    legacy_after = gzip.decompress(read(str(BASE / 'legacy-fixture-after.json.gz')))
    legacy_normal_after = gzip.decompress(read(str(BASE / 'legacy-normal-after.t.gz')))
    splice(origin[LEGACY][0].decode(), legacy_after.decode(), ['own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'])
    for phase in phases:
        for name, (body, executable) in origin.items():
            if name.startswith('docs/checkpoints/array-concat-open-arity-selection-'):
                continue
            wanted = (old if phase in ('intake', 'before') else new) if name == OWNER else legacy_after if name == LEGACY and phase not in ('intake', 'before') else legacy_normal_after if name == LEGACY_NORMAL and phase not in ('intake', 'before') else body
            equal(roots[phase][name], wanted)
            assert bool(metadata[phase][name]['mode'] & 0o111) == executable
    cases = json.loads(roots['intake'][str(BASE / 'cases.json')])
    for phase in phases:
        exact(json.loads(roots[phase][str(BASE / 'cases.json')]), cases)
        observer_order(roots[phase][str(BASE / 'observer.pl')])
        if phase != 'intake':
            observer_order(roots[phase][NORMAL])
            version = 'original-v1' if phase in ('before', 'after') else 'qualified-v2'
            equal(roots[phase][NORMAL], gzip.decompress(read(str(BASE / ('normal-' + version + '.t.gz')))))
            equal(roots[phase][FIXTURE], gzip.decompress(read(str(BASE / ('fixture-' + version + '.json.gz')))))
    shared = json.loads(origin['docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json'][0])
    assert len(cases) == 504 and len(shared) == 84
    for before, actual in zip(shared, cases[:84]):
        exact({**before, 'origin': 'selection84'}, actual)
    legacy = json.loads(origin[LEGACY][0])
    for profile, actual in zip(legacy, cases[84:396]):
        wanted = {key: profile['case'][key] for key in ('id', 'body', 'source', 'input', 'rule')}
        wanted.update(origin='legacy312', profile_only=True)
        exact(actual, wanted)
    assert len(cases[396:]) == 108 and all(case['origin'] == 'own' and case['profile_only'] is True for case in cases[396:])
    cold = records['intake']
    assert list(cold) == [case['id'] for case in cases]
    expected, targets, compatibility, preserved = derive(cases, cold)
    baseline = json.loads(read(str(BASE / 'baseline-qualified.json')))
    exact(baseline['observed'], cold)
    assert baseline['supported_targets'] == targets and baseline['separate_compatibility'] == compatibility and baseline['preserved'] == preserved
    splice(gzip.decompress(read(str(BASE / 'fixture-original-v1.json.gz'))).decode(),
        gzip.decompress(read(str(BASE / 'fixture-qualified-v2.json.gz'))).decode(), compatibility[2:])
    full = json.loads(read(str(BASE / 'epoch-expectations-qualified.json')))
    exact(full['current'], expected)
    exact(full['before'], {key: project(row) for key, row in cold.items()})
    prefix_digest = receipt('before')['runtime_root_sha256']
    pairs = 0
    for phase in phases:
        assert set(records[phase]) == set(products[phase]) == set(cold)
        wanted = {key: project(row) for key, row in cold.items()} if phase in ('intake', 'before', 'inverse') else expected
        exact({key: project(row) for key, row in records[phase].items()}, wanted)
        for case in cases:
            key = case['id']
            assert products[phase][key]['source'] == case['source']
            for field, name in (('module_input', 'emitted'), ('handler_input', 'handler')):
                row, body = records[phase][key][field], products[phase][key][name].encode()
                assert Path(row['path']).parent == BASE / phase
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
                equal(gzip.decompress(read(row['path'])), body)
                prior = 'intake' if phase == 'before' else 'before' if phase == 'inverse' else 'after' if phase in ('restored', 'direct') else None
                if prior:
                    equal(body, products[prior][key][name].encode())
            pairs += 1
        if phase != 'intake':
            assert len(owners[phase]) == 1
            logical = PRIVATE if phase in ('inverse', 'restored') else OWNER
            loaded_owner(owners[phase][0], logical, metadata[phase], prefix_digest)
            if phase in ('inverse', 'restored'):
                equal(roots[phase][PRIVATE], old if phase == 'inverse' else new)
        actual_exit = read(str(BASE / phase / ('observer-exit.txt' if phase == 'intake' else 'normal-exit.txt')))
        equal(actual_exit, dict(intake=b'0\n', before=b'28\n', after=b'2\n', inverse=b'30\n', restored=b'0\n', direct=b'0\n')[phase])
        tags = ('memory', 'version', 'syntax', 'observer') if phase == 'intake' else ('memory', 'syntax', 'normal')
        for tag in tags:
            command = json.loads(read(str(BASE / phase / (tag + '-command.json'))))
            assert command['cwd'] == '.' and command['argv'][:2] == ['bash', 'tools/project_data_run.sh']
            if tag not in ('observer', 'normal'):
                equal(read(str(BASE / phase / (tag + '-exit.txt'))), b'0\n')
                syntax_name = str(BASE / 'observer.pl') if phase == 'intake' else NORMAL
                equal(channel(BASE / phase, tag, 'stderr'), (syntax_name + ' syntax OK\n').encode() if tag == 'syntax' else b'')
        if phase == 'intake':
            equal(channel(BASE / phase, 'observer', 'stderr'), b'')
        else:
            failed = re.findall(rb'^not ok \d+ - ([a-z][a-z0-9_]+)\s*$', channel(BASE / phase, 'normal', 'stdout'), re.M)
            wanted_failed = targets + compatibility[:2] if phase == 'before' else compatibility[2:] if phase == 'after' else targets + compatibility if phase == 'inverse' else []
            assert len(failed) == len(wanted_failed) and {key.decode() for key in failed} == set(wanted_failed)
        if phase == 'after':
            assert not (ROOT / BASE / phase / 'complete.txt').exists()
        else:
            assert read(str(BASE / phase / 'complete.txt'))
    assert pairs == 3024
    assert not (ROOT / BASE / 'control-owner').exists()
    assert read(str(BASE / 'launches/after/exit.txt')) == b'1\n'
    assert read(str(BASE / 'launches/check-before/exit.txt')) == b'1\n'
    assert read(str(BASE / 'launches/qualify-outcomes/exit.txt')) == b'1\n'
    assert json.loads(read(str(BASE / 'after-qualified-review.json')))['original_normal_exit'] == 2
    assert b'Files=3, Tests=1028' in channel(BASE / 'direct', 'normal', 'stdout')
    assert b'Result: PASS' in channel(BASE / 'direct', 'normal', 'stdout')
    signature, signature_meta = unpack(BASE / 'signature_oracle')
    signature_owner = str(BASE / 'signature_oracle/MethodLowering.pm')
    equal(signature[signature_owner], old)
    assert signature_meta[signature_owner]['mode'] == metadata['before'][OWNER]['mode']
    assert not (ROOT / signature_owner).exists()
    sr, sp, _ = frames(gzip.decompress(read(str(BASE / 'signature_oracle/stdout.log.gz'))), intake=True)
    selected = json.loads(signature[str(BASE / 'signature_oracle/cases.json')])
    assert len(selected) == len(sr) == len(sp) == 4
    for case in selected:
        key = case['id']; original = next(row for row in cases if row['id'] == key.removeprefix('oracle_'))
        wanted = copy.deepcopy(original); wanted['id'] = key
        for field in ('body', 'source'):
            assert wanted[field].count(',{order=cat(order,"U");["end"]}') == 1
            wanted[field] = wanted[field].replace(',{order=cat(order,"U");["end"]}', '')
        exact(case, wanted)
        exact(sr[key]['metadata'], dict(READY, language_agnostic_action_ir_ready=0, unresolved_helper_count=1,
            unresolved_helpers=['pair' if case['signature'] == 'fixed_missing' else 'keep']))
        for route in ('native', 'fresh'):
            exact(sr[key][route], [['tail'], 'T'] if case['tail'] == 'terminal' else [None, 'T'])
        artifact(sr[key], sp[key])
    equal(read(str(BASE / 'signature_oracle/exit.txt')), b'0\n')
    stderr = gzip.decompress(read(str(BASE / 'signature_oracle/stderr.log.gz')))
    assert len(stderr.splitlines()) == 1 and stderr.startswith(b'SIGNATURE_ORACLE_OWNER ')
    loaded_owner(json.loads(stderr.split(b' ', 1)[1]), signature_owner, signature_meta, prefix_digest)
    completed = json.loads(read(str(BASE / 'completed-launches.json')))
    assert len(completed) == 25
    for tag, actual in completed.items():
        launch(BASE / 'launches' / tag, actual)
    assert completed['after'] == completed['check-before'] == completed['qualify-outcomes'] == 1
    launch(BASE / 'launches/finalize', 0)
    launch(BASE / 'launches/current', 0)
    launch(BASE / 'launches/seal', 0)
    for name, row in json.loads(read(str(BASE / 'retired-receipts.json'))).items():
        assert not (ROOT / name).exists()
        raw = gzip.decompress(read(row['archive']))
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert (ROOT / row['archive']).stat().st_mode & 0o777 == row['mode']
    qrows = json.loads(read(str(BASE / 'outcome_qualification/input-identities.json')))
    unpack_rows(BASE / 'outcome_qualification/inputs-before-qualification.tar.gz', qrows)
    qrows = json.loads(read(str(BASE / 'outcome_qualification/completion-identities.json')))
    unpack_rows(BASE / 'outcome_qualification/completion-inputs.tar.gz', qrows)
    current = json.loads(read(str(BASE / 'current/result.json')))
    assert current['current_inputs'] == 'PASS'
    equal(read(str(BASE / 'current/exit.txt')), b'0\n')
    equal(gzip.decompress(read(str(BASE / 'current/stderr.log.gz'))), b'')
    current_rows = json.loads(read(str(BASE / 'current/identities.json')))
    unpack_rows(BASE / 'current/inputs-before-reader.tar.gz', current_rows)
    controls = negative_controls(records, products, expected, cases, roots, metadata, old, new, prefix_digest)
    return dict(recovery='PASS', programs=504, supported_targets=26, separate_compatibility=4,
        full_preserved_records=474, actual_retained_pairs=pairs, additional_signature_oracle_pairs=4,
        current_declared_inputs=current['declared_inputs'], effective_corruptions=controls,
        limits='Finite Perl result/compatibility controls, strict JSON kinds/full fields; no SDK replay. Original before28/after2 capture1/owner comparator1/qualification preparation1 remain. Canonical admission/native4.2/SESSION5/earlier direct transient closure stay separate.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
