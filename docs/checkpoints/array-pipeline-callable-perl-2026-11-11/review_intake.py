"""Independent readonly source/arity intake recovery; no latest-SDK dependency."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
ACTIVATION = '237a738bfff46034b2f9b4d157e507c59f6994ca'
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[key], b[key]) for key in a)
    return a == b


def raw(phase, tag='observer', channel='stdout'):
    return gzip.decompress((ROOT / BASE / phase / (tag + '-' + channel + '.log.gz')).read_bytes())


def frames(body, tag):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def recover(phase):
    records = json.loads((ROOT / BASE / phase / 'input-identities.json').read_bytes())
    files = {}
    with tarfile.open(ROOT / BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in files
            body = archive.extractfile(member).read()
            row = records[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256'] and member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == records.keys()
    return files


def historical(names):
    result = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
        input=''.join(ACTIVATION + ':' + name + '\n' for name in names).encode(), stdout=subprocess.PIPE, check=True)
    position, files = 0, {}
    for name in names:
        end = result.stdout.index(b'\n', position)
        header = result.stdout[position:end].split()
        assert header[1] == b'blob'
        size = int(header[2]); position = end + 1
        files[name] = result.stdout[position:position + size]; position += size + 1
    assert position == len(result.stdout)
    return files


def validate_policy(rows, cases, original):
    assert list(rows) == [case['id'] for case in cases]
    assert same(rows, original), 'complete observed record changed'
    first_with = 0
    for case in cases[41:]:
        key, row, question = case['id'], rows[case['id']], case['question']
        if question == 'initial-terminal':
            assert row['metadata'] == META and row['native'] == row['fresh'] == []
            assert row['native_error'] is None and row['fresh_error'] is None
        if question == 'initial-first-with':
            terminal = rows[key.removesuffix('_with')]
            assert terminal['native'] == terminal['fresh'] == []
            assert row['metadata'] == META and row['native'] == row['fresh'] == [0, 'W']
            assert row['native_error'] is None and row['fresh_error'] is None
            first_with += 1
        if question.startswith('function-arity-'):
            assert row['metadata']['language_agnostic_action_ir_ready'] == 0
            assert row['native'] == row['fresh'] == [None, '']
    assert first_with == 42
    assert rows['own_source_before_rejection']['native'] == ['ran', 'W']
    assert rows['own_source_before_rejection']['metadata'] != META
    assert same(rows['own_nested_scalar_kinds']['native'], [[False, None, ''], [False, 0, None, '0', '']])
    assert same(rows['own_numeric_array_source']['native'], [[3], [3], [3], [3]])
    assert rows['own_pattern_source_string_terminal']['native'] == [['head'], '']
    for kind in ('variable', 'block'):
        assert rows['own_pattern_source_' + kind + '_terminal']['native'] == [[], '']


def validate_arity(rows, cases):
    assert list(rows) == [case['id'] for case in cases]
    free = [case['id'] for case in cases if case['id'].endswith('_free')]
    assert len(free) == 9
    for key in free:
        row, receiver = rows[key], rows[key.removesuffix('_free') + '_receiver']
        assert row['metadata']['language_agnostic_action_ir_ready'] == 0
        assert row['metadata']['raw_perl_dependency_count'] == row['metadata']['canonical_action_ir_fallback_count'] == 0
        assert row['loaded'] == 1 and row['native_error'] is None and row['fresh_error'] is None
        assert row['native'] == row['fresh'] == [None, '']
        assert receiver['metadata'] == META and receiver['native'] is None
        if '_extra_' in key:
            assert receiver['loaded'] == 0 and receiver['native_error']['stage'] == 'rule_handler_compile'
            assert 'fresh' not in receiver and 'fresh_error' not in receiver
            assert 'syntax error' in receiver['load_error'] and receiver['warnings']
        else:
            assert receiver['loaded'] == 1 and receiver['native_error']['stage'] == 'rule_handler_eval'
            assert all('Undefined subroutine' in receiver[route + '_error']['detail']
                and '__array_value_' in receiver[route + '_error']['detail'] for route in ('native', 'fresh'))


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'intake-sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
        if name.endswith('.gz'): gzip.decompress(body)
    inputs = {phase: recover(phase) for phase in ('intake', 'arity')}
    names = sorted(name for name in inputs['intake'] if name.startswith(('perl/', 'specs/')))
    old = historical(names)
    assert all({name: files[name] for name in names} == old for files in inputs.values())
    cases = json.loads(inputs['intake'][str(BASE / 'cases.json')])
    arity_cases = json.loads(inputs['arity'][str(BASE / 'arity-cases.json')])
    assert len(cases) == 178 and len(arity_cases) == 18
    common = json.loads(inputs['intake']['tests/fixtures/array_pipeline_callable_perl_selection_cases.json'])
    assert cases[:41] == common and cases[41:] == json.loads(inputs['intake'][str(BASE / 'profile-sources.json')])
    packet = json.loads((ROOT / BASE / 'classification.json').read_bytes())
    observations, pairs = {}, {}
    for phase, population in (('intake', cases), ('arity', arity_cases)):
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        for tag in ('version', 'observer'):
            assert (ROOT / BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
            assert raw(phase, tag, 'stderr') == b''
        command = json.loads((ROOT / BASE / phase / 'observer-command.json').read_bytes())
        observer = 'observer.pl' if phase == 'intake' else 'arity_observer.pl'
        fixture = 'cases.json' if phase == 'intake' else 'arity-cases.json'
        assert command == dict(cwd='.', argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(BASE / observer), str(BASE / fixture), str(BASE / phase)])
        rows = frames(raw(phase), 'ARRAY_PIPELINE_CALLABLE_PERL_PERL')
        supplied = frames(raw(phase), 'ARRAY_PIPELINE_CALLABLE_PERL_INPUT')
        assert list(rows) == list(supplied) == [case['id'] for case in population]
        if phase == 'intake': validate_policy(rows, population, packet['observations'])
        else: validate_arity(rows, population); assert same(rows, packet['arity_observations'])
        observations[phase], pairs[phase] = rows, {}
        for case in population:
            key = case['id']; assert supplied[key]['source'] == case['source']
            pair = []
            for suffix, field, identity_key in (('pm', 'emitted', 'module_input'), ('handler.pl', 'handler', 'handler_input')):
                path = str(BASE / phase / (key + '.' + suffix + '.gz'))
                body = gzip.decompress((ROOT / path).read_bytes())
                assert body == supplied[key][field].encode()
                assert rows[key][identity_key] == dict(path=path, bytes=len(body), sha256=digest(body))
                pair.append(body)
            pairs[phase][key] = pair
    assert raw('intake', 'version') == raw('arity', 'version')
    owner = old['perl/LinkedSpec/ActionIR/MethodLowering.pm']
    start = owner.index(b'my $ordinary_array_pipeline_result_chain =')
    end = owner.index(b'# Copy and collection results stay together;', start)
    assert b'_user_function_definition_for_name($deps, $receiver->{name})' in owner[start:end]
    assert b'return undef unless $effective_args;' in owner
    missing_handler = pairs['arity']['arity_missing_split_each_receiver'][1]
    assert b'__array_value_split_each(' in missing_handler
    assert b'__array_value_filter_match(' in pairs['arity']['arity_missing_filter_match_receiver'][1]
    assert len(packet['supported_targets']) == 25
    assert {role: list(packet['roles'].values()).count(role) for role in set(packet['roles'].values())} == {
        'supported-target': 25, 'preservation': 128, 'function-signature-fence': 4,
        'pattern-producer-boundary': 3, 'arity-prerequisite-observation': 18}
    rejected = []

    def reject(name, operation):
        try: operation()
        except (AssertionError, KeyError): rejected.append(name)
        else: raise AssertionError('ineffective corruption: ' + name)

    def mutate(key, field, value):
        changed = copy.deepcopy(observations['intake']); changed[key][field] = value
        validate_policy(changed, cases, packet['observations'])

    reject('first with suppressed', lambda: mutate('own_initial_number_trim_each_receiver_with', 'native', [None, '']))
    reject('producer effect loss hidden', lambda: mutate('own_source_before_rejection', 'native', [None, 'S']))
    reject('function arity admitted', lambda: mutate('own_function_arity_extra_terminal', 'metadata', META))
    reject('computed pattern body executed', lambda: mutate('own_pattern_source_block_terminal', 'native', [[], 'P']))
    wrong = copy.deepcopy(observations['intake']['own_nested_scalar_kinds']['native']); wrong[0][0] = 0
    reject('Bool to Number', lambda: mutate('own_nested_scalar_kinds', 'native', wrong))
    wrong = copy.deepcopy(observations['intake']['own_numeric_array_source']['native']); wrong[0][0] = '3'
    reject('numeric kind normalized', lambda: mutate('own_numeric_array_source', 'native', wrong))
    changed = copy.deepcopy(observations['arity']); changed['arity_missing_split_each_receiver']['metadata'] = changed['arity_missing_split_each_free']['metadata']
    reject('false ready failure hidden', lambda: validate_arity(changed, arity_cases))
    changed = copy.deepcopy(observations['arity']); changed['arity_extra_uniq_receiver']['fresh_error'] = None
    reject('invented fresh after failed load', lambda: validate_arity(changed, arity_cases))
    changed = copy.deepcopy(observations['arity']); changed['arity_missing_filter_match_receiver']['fresh_error']['detail'] = 'masked'
    reject('private helper leak hidden', lambda: validate_arity(changed, arity_cases))
    changed = copy.deepcopy(observations['arity']); changed['arity_missing_split_each_free']['native'] = [None, 'S']
    reject('free rejection effects', lambda: validate_arity(changed, arity_cases))
    missing = copy.deepcopy(observations['intake']); del missing['own_prior_copy']
    reject('policy case omitted', lambda: validate_policy(missing, cases, packet['observations']))
    reject('actual handler drift', lambda: equal(digest(missing_handler + b'\n'), digest(missing_handler)))
    print(json.dumps(dict(original_programs=178, unchanged_qualified=41, own_questions=137,
        terminal_arity_programs=18, actual_pairs=196, terminal_and_first_with_preserved=84,
        supported_result_targets=25, preservation=128, function_signature_fences=4,
        pattern_producer_boundaries=3, original_arity_observations=18,
        terminal_receiver_arity_defects=9, terminal_free_rejection_oracles=9,
        extra_receiver_compile_failures=7, missing_receiver_private_helper_errors=2,
        recovery='PASS', effective_corruptions=rejected,
        limits='No production change or defect closure. Nine false-ready arity receivers are not accepted policies; free-form rejections are the same-backend oracle. Six metadata fields/full observed errors and artifacts; same-process fresh modules. Native/cache/transitive/toolchain4.2/SESSION5, shadowing32/context/isolation/registration/declared5.4/full23.4 remain separate.'), indent=2))


if __name__ == '__main__':
    main()
