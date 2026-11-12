"""Independent readonly finite concat selection oracle; imports no SDK/producer."""
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
BASE = Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12')
ACTIVATION = 'd21b84a4c8da663ee2a7600a2dc814d354502612'
META = {'language_agnostic_action_ir_ready', 'raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count', 'unresolved_helpers'}


def read(name):
    path = PurePosixPath(name)
    assert not path.is_absolute() and '..' not in path.parts
    target = ROOT / name
    assert target.is_file() and not target.is_symlink()
    return target.read_bytes()


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def equal(actual, expected):
    assert actual == expected


def unpack(path, rows):
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


def frames(body):
    records, products = {}, {}
    for line in body.decode().splitlines():
        if line.startswith(('ARRAY_CONCAT_OPEN_PERL ', 'ARRAY_CONCAT_OPEN_INPUT ')):
            prefix, key, raw = line.split(' ', 2)
            target = records if prefix == 'ARRAY_CONCAT_OPEN_PERL' else products
            assert key not in target
            target[key] = json.loads(raw)
    return records, products


def ready(row):
    meta = row['metadata']
    assert set(meta) == META
    return meta['language_agnostic_action_ir_ready'] == 1 and not meta['unresolved_helpers'] and all(meta[key] == 0 for key in (
        'raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count'))


def intent(case):
    count, kind, tail = case['array_count'], case['source_kind'], case['tail']
    assert type(count) is int and count in (1, 2, 3)
    assert kind in ('ordinary', 'function') and case['form'] in ('free', 'receiver')
    assert tail in ('terminal', 'compatible', 'with_', 'hash', 'later')
    prefix = 'fn supply(seed) {return(seed)}\n\n' if kind == 'function' else ''
    assert case['source'] == prefix + 'Value:: I {' + case['body'] + '}\n'
    assert case['body'].startswith('order="";out=') and case['body'].endswith(';return([out,order])')
    assert case['input'] == 'x' and case['rule'] == 'Value'
    if '_needed_' in case['id']:
        assert case['expected_error'] == 'binding_kind_mismatch' and 'expected' not in case
        assert 'items="bad";items+=1;' in case['source']
        return None
    assert 'expected_error' not in case
    effects = ('S' if kind == 'function' else '') if case['empty'] else 'STU'[:count]
    elements = [] if case['empty'] else ['head', 'tail', 'end'][:count]
    value = elements if tail == 'terminal' else elements[-1].upper() if tail == 'compatible' else len(elements) if tail == 'with_' else None
    expected = [value, effects + ('W' if tail == 'with_' else '')]
    assert wire(case['expected']) == wire(expected)
    return expected


def contract(case, row):
    if not ready(row) or row['warnings']:
        return False
    expected = intent(case)
    for route, flag in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row[flag] != 1 or route not in row:
            return False
        error = row[route + '_error']
        if '_needed_' in case['id']:
            if not error or 'binding_kind_mismatch' not in wire(error):
                return False
        elif error or wire(row[route]) != wire(expected):
            return False
    return True


def artifact(case, record, products):
    assert products['source'] == case['source']
    for field, key in (('module_input', 'emitted'), ('handler_input', 'handler')):
        row, body = record[field], products[key]
        assert isinstance(body, str) and row is not None
        raw = body.encode()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert Path(row['path']).parent == BASE / 'intake'
        assert gzip.decompress(read(row['path'])) == raw


def observer_order(body):
    assert body.index(b'LinkedSpec::emit_generated_source(') < body.index(b"persist($id,'pm',$emitted)") < body.index(b'my $loaded=')
    assert body.index(b'parser_source_ref=>\\$handler') < body.index(b"persist($id,'handler.pl',$handler)") < body.index(b'$native->(')
    assert b'gunzip $path => \\$retained' in body and b'$retained eq $body' in body


def main():
    for name, row in json.loads(read(str(BASE / 'sealed-identities.json'))).items():
        body = read(name)
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    folder = BASE / 'intake'
    rows = json.loads(read(str(folder / 'input-identities.json')))
    inputs = unpack(folder / 'inputs-before-first-run.tar.gz', rows)
    contexts = [name for name in rows if not name.startswith(('perl/', 'specs/', str(BASE) + '/'))]
    origin = {}
    archive_bytes = subprocess.check_output(['git', 'archive', ACTIVATION, '--', 'perl', 'specs', *contexts], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(archive_bytes)) as archive:
        for member in archive:
            if member.isfile():
                origin[member.name] = (archive.extractfile(member).read(), bool(member.mode & 0o111))
    for name, (body, executable) in origin.items():
        equal(inputs[name], body)
        assert bool(rows[name]['mode'] & 0o111) == executable
    source = inputs['perl/LinkedSpec/ActionIR/MethodLowering.pm']
    assert re.search(rb'concat_arrays\s*=>\s*\[1, undef\]', source)
    assert b"my $minimum = ($method eq 'slice' || $method eq 'concat_arrays') ? 2 : 1;" in source
    observer_order(inputs[str(BASE / 'observer.pl')])
    cases = json.loads(inputs[str(BASE / 'cases.json')])
    assert len(cases) == len({case['id'] for case in cases}) == 84
    records, products = frames(gzip.decompress(read(str(folder / 'observer-stdout.log.gz'))))
    assert list(records) == list(products) == [case['id'] for case in cases]
    assessment = json.loads(read(str(BASE / 'assessment.json')))
    assert wire(assessment['observed']) == wire(records)
    wanted = {f'ordinary_{count}_{shape}' for count in (1, 3) for shape in ('free_hash', 'free_later', 'receiver_later')}
    wanted |= {f'function_{count}_{shape}' for count in (1, 3) for shape in ('free_hash', 'free_later', 'receiver_hash', 'receiver_later')}
    wanted |= {f'function_needed_{fault}_{form}_hash' for fault in ('source', 'operand') for form in ('free', 'receiver')}
    differences, passing = [], []
    by_id = {case['id']: case for case in cases}
    for case in cases:
        key = case['id']; row = records[key]
        intent(case)
        artifact(case, row, products[key])
        actual = contract(case, row)
        assert actual is (key not in wanted)
        (passing if actual else differences).append(key)
        if key in wanted:
            terminal = key[:-len(case['tail'])] + 'terminal'
            assert contract(by_id[terminal], records[terminal])
            if key.startswith('ordinary_') and '_free_' in key:
                assert ready(row) and row['loaded'] == 1 and row['native_error']['stage'] == 'rule_handler_eval'
                assert 'Not a HASH reference' in row['native_error']['detail'] and 'Not a HASH reference' in row['fresh_error']['detail']
            elif key.startswith('ordinary_'):
                expected_order = ('S' if case['array_count'] == 1 else 'STU') + 'DW'
                assert ready(row) and row['native'] == row['fresh'] == ['ran', expected_order]
            elif case['form'] == 'free':
                assert row['metadata']['unresolved_helpers'] == ['concat_arrays'] and not ready(row)
                value = ['ran', 'KVDW'] if case['tail'] == 'later' else [{'k': 1}, 'KV']
                assert row['native'] == row['fresh'] == value
            elif case['tail'] == 'later':
                assert row['metadata']['unresolved_helpers'] == ['copy'] and row['native'] == row['fresh'] == ['ran', 'DW']
            else:
                assert ready(row) and not row['loaded'] and row['native_error']['stage'] == 'rule_handler_compile'
                assert 'syntax error' in row['load_error'] and 'fresh' not in row and 'fresh_error' not in row
    assert len(differences) == 18 and len(passing) == 66
    assert assessment['contract_differences'] == assessment['terminal_supported_composition_targets'] == differences
    assert assessment['contract_pass'] == passing and assessment['producer_or_terminal_questions'] == [] and assessment['artifact_files'] == 168
    for tag in ('memory', 'version', 'syntax', 'observer'):
        assert read(str(folder / (tag + '-exit.txt'))) == b'0\n'
        stderr = gzip.decompress(read(str(folder / (tag + '-stderr.log.gz'))))
        equal(stderr, (str(BASE / 'observer.pl') + ' syntax OK\n').encode() if tag == 'syntax' else b'')
        command = json.loads(read(str(folder / (tag + '-command.json'))))
        assert command['cwd'] == '.' and command['argv'][:2] == ['bash', 'tools/project_data_run.sh']
    for tag in ('prepare', 'capture', 'inspect', 'current'):
        launch = BASE / 'launches' / tag
        unpack(launch / 'inputs.tar.gz', json.loads(read(str(launch / 'identities.json'))))
        assert read(str(launch / 'exit.txt')) == b'0\n' and gzip.decompress(read(str(launch / 'stderr.log.gz'))) == b''
    current = json.loads(read(str(BASE / 'current/result.json')))
    assert current['current_inputs'] == 'PASS' and read(str(BASE / 'current/exit.txt')) == b'0\n'
    equal(gzip.decompress(read(str(BASE / 'current/stderr.log.gz'))), b'')
    unpack(BASE / 'current/inputs-before-reader.tar.gz', json.loads(read(str(BASE / 'current/identities.json'))))
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective selection control: ' + name)

    def require_contract(case, row):
        assert contract(case, row)

    healthy = 'function_3_free_with_'
    assert contract(by_id[healthy], records[healthy]) and records[healthy]['native'] == [3, 'STUW']
    missing_ready = copy.deepcopy(records[healthy]); missing_ready['metadata']['language_agnostic_action_ir_ready'] = 0
    reject('matching values hide unready metadata', lambda: require_contract(by_id[healthy], missing_ready))
    reject('old supported failure called PASS', lambda: require_contract(by_id['function_3_free_hash'], records['function_3_free_hash']))
    wrong_order = copy.deepcopy(records[healthy]); wrong_order['native'] = [3, 'SUW']
    reject('additional Array T skipped', lambda: require_contract(by_id[healthy], wrong_order))
    wrong_source = copy.deepcopy(records[healthy]); wrong_source['fresh'] = [3, 'TUW']
    reject('source S skipped', lambda: require_contract(by_id[healthy], wrong_source))
    correct_empty = 'ordinary_empty_receiver_with_'
    assert records[correct_empty]['native'] == [0, 'W']
    empty = copy.deepcopy(records[correct_empty]); empty['native'] = [None, '']
    reject('empty Array with skipped', lambda: require_contract(by_id[correct_empty], empty))
    needed = 'function_needed_operand_free_terminal'
    assert contract(by_id[needed], records[needed]) and records[needed]['native_error']
    masked = copy.deepcopy(records[needed]); masked['native_error'] = None
    reject('needed error masked', lambda: require_contract(by_id[needed], masked))
    compile_key = 'function_3_receiver_hash'
    assert 'fresh' not in records[compile_key] and 'stage' in records[compile_key]['native_error']
    altered = copy.deepcopy(records); altered[compile_key]['fresh'] = None
    reject('fresh field invented after failed load', lambda: equal(wire(altered), wire(records)))
    altered_stage = copy.deepcopy(records); altered_stage[compile_key]['native_error'].pop('stage')
    reject('full diagnostic stage omitted', lambda: equal(wire(altered_stage), wire(records)))
    omitted = copy.deepcopy(records); omitted.pop(healthy)
    reject('question omitted', lambda: equal(list(omitted), list(records)))
    changed = copy.deepcopy(products[healthy]); changed['emitted'] += '\n'
    reject('emitted input body changed', lambda: artifact(by_id[healthy], records[healthy], changed))
    changed_dump = copy.deepcopy(products[healthy]); changed_dump['handler'] += '\n'
    reject('standalone dump changed', lambda: artifact(by_id[healthy], records[healthy], changed_dump))
    late = inputs[str(BASE / 'observer.pl')].replace(b"persist($id,'pm',$emitted)", b'late_module_snapshot')
    reject('module snapshot omitted', lambda: observer_order(late))
    reject('SDK source image changed', lambda: equal(source + b'\n', origin['perl/LinkedSpec/ActionIR/MethodLowering.pm'][0]))
    reject('unexpected stderr hidden', lambda: equal(b'unexpected stderr', b''))
    assert len(controls) == 14
    return dict(recovery='PASS', programs=84, contract_pass=66, supported_composition_differences=18,
        actual_module_dump_pairs=84, artifact_files=168, current_declared_inputs=current['declared_inputs'],
        effective_corruptions=controls, limits='Finite historical own-Perl selection; no SDK replay, fix, peer/portable/completeness admission. Standalone dump follows internal Get compilation; full native4.2/SESSION5 and source/context/registration/full23.4 remain separate.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
