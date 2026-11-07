"""Read only the actual historical Perl selection; never execute a parser."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/hash-value-result-selection-2026-11-07')
ACTIVATION = '795e8c1ade747d12a1c1e304ddf144a9372eea2e'
METHODS = ('merge_hash', 'set_key', 'rename_key', 'drop_keys', 'pick_keys')
FREE_RED = {name + '_free_array_guard' for name in METHODS}
COMPILE_RED = {name + '_receiver_array_guard' for name in METHODS} | {
    'needed_source_error_composed', 'needed_value_error_composed'}
LATER_RED = {'merge_later_with': ['ran', 'W'], 'set_copy_later_with': ['ran', 'W'],
             'rename_logical_later_with': ['ran', 'DW']}
RED = FREE_RED | COMPILE_RED | LATER_RED.keys()


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def frames(raw, prefix):
    result = {}
    for line in raw.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(body)
    return result


def recover():
    directory = ROOT / BASE / 'intake'
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            raw = archive.extractfile(member).read()
            expected = identities[member.name]
            assert hashlib.sha256(raw).hexdigest() == expected['sha256']
            assert len(raw) == expected['bytes'] and member.mode & 0o777 == expected['mode']
            found[member.name] = raw
    assert found.keys() == identities.keys(), 'exact pre-use archive membership'
    return found


def validate(rows, cases):
    assert list(rows) == [case['id'] for case in cases], 'complete ordered original32'
    assert len(cases) == 32 and sum(not c.get('profile_only') for c in cases) == 28
    for case in cases:
        identifier, row = case['id'], rows[case['id']]
        assert case['source'] == 'Value:: I {' + case['body'] + '}\n'
        assert case['input'] == 'x' and case['rule'] == 'Value'
        assert row['native_callable'] == 1 and row['native_cursor'] == 0
        assert all(row[key] is None for key in ('substitution_error', 'descriptor_error',
                   'emission_error', 'build_error'))
        profile = case.get('profile_only', False)
        helper = identifier.split('_free_')[0].split('_receiver_')[0]
        expected_metadata = dict(language_agnostic_action_ir_ready=0 if profile else 1,
            raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
            unresolved_helper_count=1 if profile else 0, unresolved_helpers=[helper] if profile else [])
        assert row['metadata'] == expected_metadata
        if identifier in COMPILE_RED:
            assert row['loaded'] == 0 and row['native'] is None and 'fresh' not in row
            error = row['native_error']
            assert isinstance(error, dict) and error['type'] == 'runtime_handler'
            assert error['stage'] == 'rule_handler_compile' and error['rule_label'] == 'Value'
            assert error['summary'] == 'Rule handler compilation failed'
            assert 'syntax error' in error['detail'] and 'syntax error' in row['load_error']
            assert row['warnings'] and all(isinstance(w, str) for w in row['warnings'])
            continue
        assert row['loaded'] == 1 and row['load_error'] is None and row['fresh_cursor'] == 0
        assert not row['warnings']
        if case.get('expected_error'):
            assert row['native'] is row['fresh'] is None
            for channel, stage, kind in (('native_error', 'rule_handler_eval', 'runtime_handler'),
                                         ('fresh_error', 'execute_generated', 'generated_source_error')):
                error = row[channel]
                assert isinstance(error, dict) and error['stage'] == stage and error['type'] == kind
                assert error['rule_label'] == 'Value'
                assert error['detail'] == 'binding_kind_mismatch identifier=items expected_kind=array actual_kind=scalar\n'
            assert row['fresh_error']['code'] == 'generated_execution_failed'
            continue
        assert row['native_error'] is row['fresh_error'] is None
        expected = None if profile else ([[], ''] if identifier in FREE_RED else LATER_RED.get(identifier, case['expected']))
        assert same(row['native'], expected) and same(row['fresh'], expected), identifier
        if profile:
            assert identifier in {h + '_' + form + '_zero_keys_profile'
                                  for h in ('drop_keys', 'pick_keys') for form in ('free', 'receiver')}
            assert 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:' + helper in row['substitution']


def validate_projection(fixture, cases):
    projected = [case for case in cases if not case.get('profile_only')]
    assert len(fixture) == len(projected) == 28 and same(fixture, projected), 'unchanged eligible source projection'


def validate_artifact(identifier, field, suffix, payload, item, actual, supplied):
    assert item['path'] == str(BASE / 'intake' / (identifier + '.' + suffix + '.gz'))
    assert hashlib.sha256(actual).hexdigest() == item['sha256'] and len(actual) == item['bytes']
    assert actual.decode() == supplied[payload], 'actual module/handler before use'


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    inputs = recover()
    body = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'])
    with tarfile.open(fileobj=io.BytesIO(body)) as archive:
        owned = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    assert set(owned) == {p for p in inputs if p.startswith(('perl/', 'specs/'))}
    for path, raw in owned.items():
        assert raw == inputs[path], 'actual activation Perl and conservative grammar inputs'
    for name in ('capture.py', 'observer.pl', 'cases.py', 'cases.json'):
        assert inputs[str(BASE / name)] == (ROOT / BASE / name).read_bytes()
    directory = ROOT / BASE / 'intake'
    assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
    assert (directory / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((directory / 'stderr.log.gz').read_bytes()) == b''
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
               str(BASE / 'observer.pl'), str(BASE / 'cases.json'), str(BASE / 'intake')]
    assert json.loads((directory / 'command.json').read_bytes()) == dict(argv=command)
    raw = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
    cases = json.loads(inputs[str(BASE / 'cases.json')])
    rows, supplied = frames(raw, 'HASH_VALUE_PERL'), frames(raw, 'HASH_VALUE_INPUT')
    validate(rows, cases)
    assert list(supplied) == list(rows)
    artifacts = {}
    for case in cases:
        identifier = case['id']
        assert supplied[identifier]['source'] == case['source']
        for field, suffix, payload in (('module_input', 'pm', 'emitted'), ('handler_input', 'handler.pl', 'handler')):
            item = rows[identifier][field]
            actual = gzip.decompress((directory / (identifier + '.' + suffix + '.gz')).read_bytes())
            validate_artifact(identifier, field, suffix, payload, item, actual, supplied[identifier])
            artifacts[identifier, payload] = actual
    fixture = json.loads((ROOT / 'tests/fixtures/hash_value_result_guard_cases.json').read_bytes())
    validate_projection(fixture, cases)
    profiles = json.loads((ROOT / BASE / 'zero-key-profiles.json').read_bytes())
    assert same(profiles, [dict(case=c, observation=rows[c['id']]) for c in cases if c.get('profile_only')])
    free = artifacts['pick_keys_free_array_guard', 'handler']
    constructor = artifacts['constructor_hash_guard', 'handler']
    receiver = artifacts['pick_keys_receiver_array_guard', 'handler']
    assert b'__ls_take' in free and b'else { [] }' in free
    assert b'{"a":1,"b":2}.pick_keys("b").take(' in receiver
    assert b'__ls_free_default_rejected' in constructor
    assert b'return merge_hash(' in artifacts['needed_source_error_composed', 'handler']
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective evidence corruption: ' + name)

    def mutate(identifier, operation):
        damaged = copy.deepcopy(rows)
        operation(damaged[identifier])
        validate(damaged, cases)

    reject('healthy compatible value drift', lambda: mutate('merge_hash_compatible', lambda r: r.update(native=[3, 'a,b'])))
    reject('Bool normalized to Number', lambda: mutate('nested_kinds_and_source', lambda r: r.update(fresh=[0, None, 8, 0, False])))
    reject('original free failure silently blessed green', lambda: mutate('pick_keys_free_array_guard', lambda r: r.update(native=[None, ''])))
    lost = copy.deepcopy(rows)
    lost.pop('empty_pick_with')
    reject('missing preservation member', lambda: validate(lost, cases))
    damaged = copy.deepcopy(fixture)
    damaged[0]['source'] += ' '
    reject('projected source drift', lambda: validate_projection(damaged, cases))
    reject('zero-key unready profile promoted', lambda: mutate('drop_keys_free_zero_keys_profile', lambda r: r['metadata'].update(language_agnostic_action_ir_ready=1)))
    reject('needed producer error stage masked', lambda: mutate('needed_value_error_terminal', lambda r: r['native_error'].update(stage='rule_handler_compile')))
    reject('actual handler drift', lambda: validate_artifact('pick_keys_free_array_guard', 'handler_input', 'handler.pl', 'handler', rows['pick_keys_free_array_guard']['handler_input'], free + b'\n', supplied['pick_keys_free_array_guard']))
    assert len(RED) == 15
    return dict(original_sources=32, eligible_unchanged_sources=28, eligible_failures=sorted(RED),
                healthy_controls=13, unready_zero_key_profiles=4, actual_artifact_pairs=32,
                evidence_corruptions=rejected, production_changes=0,
                scope='historical finite public Perl Get/native/fresh selection; original errors/warnings/metadata/cursors retained, no peer verdict, initial-source normalization, native-transitive custody, general context or full23.4 admission')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
