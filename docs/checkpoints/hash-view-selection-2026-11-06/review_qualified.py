"""Readonly original Hash-view selection and independent copy/null qualification."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/hash-view-selection-2026-11-06')
ACTIVATION = '659a1ecccdc0467951f529a8fa9add5e9f05e510'
VIEW_RED = {'free_sorted_keys_hash_guard', 'receiver_sorted_keys_hash_guard',
            'free_sorted_values_hash_guard', 'receiver_sorted_values_hash_guard',
            'later_with', 'copy_guard', 'logical_guard'}
COPY_RED = {'copy_rejected_with', 'copy_rejected_default', 'receiver_copy_control'}


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


def recover(phase):
    directory = ROOT / BASE / phase
    expected = json.loads((directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            raw = archive.extractfile(member).read()
            row = expected[member.name]
            assert hashlib.sha256(raw).hexdigest() == row['sha256']
            assert len(raw) == row['bytes'] and member.mode & 0o777 == row['mode']
            found[member.name] = raw
    assert found.keys() == expected.keys(), 'exact declared archive membership'
    return found


def frames(raw, prefix):
    result = {}
    for line in raw.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(body)
    return result


def prepared(row):
    assert row['native_callable'] == row['loaded'] == 1
    assert all(row[name] is None for name in ('descriptor_error', 'emission_error', 'build_error', 'load_error'))


def clean(row):
    prepared(row)
    assert row['native_error'] is row['fresh_error'] is None and not row['warnings']


def ready(row):
    assert row['metadata'] == dict(language_agnostic_action_ir_ready=1,
        raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
        unresolved_helper_count=0, unresolved_helpers=[])


def validate(rows, cases, phase):
    assert list(rows) == [case['id'] for case in cases], 'complete ordered actual source population'
    for case in cases:
        identifier, row = case['id'], rows[case['id']]
        if phase == 'intake' and identifier == 'arity_profile':
            clean(row)
            assert row['metadata']['language_agnostic_action_ir_ready'] == 0
            assert row['metadata']['unresolved_helpers'] == ['sorted_keys']
            assert same(row['native'], ['ran', 'W']) and same(row['fresh'], ['ran', 'W'])
            continue
        ready(row)
        if phase == 'intake' and identifier in VIEW_RED:
            assert isinstance(row['native_error'], dict), 'typed actual error object required'
            if identifier.startswith('receiver_'):
                assert row['native_error']['stage'] == 'rule_handler_compile'
                assert 'syntax error' in row['native_error']['detail'] and 'syntax error' in row['load_error']
                assert row['loaded'] == 0 and row['warnings']
            else:
                prepared(row)
                assert row['native_error']['stage'] == 'rule_handler_eval'
                assert 'Not a HASH reference' in row['native_error']['detail']
                assert row['fresh_error']['code'] == 'generated_execution_failed'
                assert 'Not a HASH reference' in row['fresh_error']['detail'] and not row['warnings']
        elif case.get('expected_error'):
            prepared(row)
            assert all(case['expected_error'] in row[name]['detail'] for name in ('native_error', 'fresh_error'))
            assert row['native_error']['stage'] == 'rule_handler_eval'
            assert row['fresh_error']['stage'] == 'execute_generated' and not row['warnings']
        else:
            clean(row)
            if phase == 'intake' and identifier == 'constructor_copy_oracle':
                expected = [None, 'ran', 'X']
            elif phase == 'copy-controls' and identifier in COPY_RED:
                expected = [1, 'D'] if identifier == 'copy_rejected_default' else ['ran', 'W']
            else:
                expected = case['expected']
            assert same(row['native'], expected) and same(row['fresh'], expected), identifier


def equal(a, b):
    assert a == b


def main():
    for path, expected in json.loads((ROOT / BASE / 'qualification-input-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    inputs = {phase: recover(phase) for phase in ('intake', 'copy-controls')}
    owned = {}
    body = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'])
    with tarfile.open(fileobj=io.BytesIO(body)) as archive:
        owned = {member.name: archive.extractfile(member).read() for member in archive if member.isfile()}
    for path, raw in inputs['intake'].items():
        if path.startswith('perl/') or path.startswith('specs/'):
            assert raw == owned[path] == inputs['copy-controls'][path], 'same actual activation runtime/grammar inputs'
    cases, observations, artifacts = {}, {}, {}
    for phase, filename in (('intake', 'cases.json'), ('copy-controls', 'copy-controls.json')):
        directory = ROOT / BASE / phase
        assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert (directory / 'exit.txt').read_text() == '0\n'
        assert gzip.decompress((directory / 'stderr.log.gz').read_bytes()) == b''
        raw = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
        cases[phase] = json.loads(inputs[phase][str(BASE / filename)])
        rows, supplied = frames(raw, 'HASH_VIEW_PERL'), frames(raw, 'HASH_VIEW_INPUT')
        validate(rows, cases[phase], phase)
        assert list(supplied) == list(rows)
        artifacts[phase] = {}
        for case in cases[phase]:
            identifier = case['id']
            assert supplied[identifier]['source'] == case['source']
            for field, suffix, payload in (('module_input', 'pm', 'emitted'), ('handler_input', 'handler.pl', 'handler')):
                item = rows[identifier][field]
                path = BASE / phase / (identifier + '.' + suffix + '.gz')
                assert item['path'] == str(path)
                actual = gzip.decompress((ROOT / path).read_bytes())
                assert hashlib.sha256(actual).hexdigest() == item['sha256'] and len(actual) == item['bytes']
                assert actual.decode() == supplied[identifier][payload], 'actual artifact before fresh loading/execution'
                artifacts[phase][(identifier, payload)] = actual
        observations[phase] = rows
    projected = [case for case in cases['intake'] if case['id'] not in {'constructor_copy_oracle', 'arity_profile'}]
    projected += [case for case in cases['copy-controls'] if case['id'] == 'constructor_rejected_with']
    view_fixture = json.loads((ROOT / 'tests/fixtures/hash_view_result_guard_cases.json').read_bytes())
    copy_fixture = json.loads((ROOT / 'tests/fixtures/copy_result_guard_cases.json').read_bytes())
    assert same(view_fixture, projected) and same(copy_fixture, cases['copy-controls'])
    assert len(projected) == 15 and len(copy_fixture) == 6
    copy_module = artifacts['copy-controls'][('copy_rejected_with', 'handler')]
    constructor = artifacts['copy-controls'][('constructor_rejected_with', 'handler')]
    assert b'__ls_with_value' in copy_module and b'__ls_selected_default' in copy_module
    assert b'__ls_free_default_rejected' not in copy_module and b'__ls_free_default_rejected' in constructor
    assert b'{"a":1}.sorted_keys().set_key(' in artifacts['intake'][('receiver_sorted_keys_hash_guard', 'handler')]
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(phase, identifier, operation):
        damaged = copy.deepcopy(observations[phase])
        operation(damaged[identifier])
        validate(damaged, cases[phase], phase)

    reject('view runtime failure hidden', lambda: mutate('intake', 'free_sorted_keys_hash_guard', lambda row: row.update(native_error=None)))
    reject('receiver compile failure hidden', lambda: mutate('intake', 'receiver_sorted_keys_hash_guard', lambda row: row.update(native_error=None)))
    reject('valid copied null suppressed', lambda: mutate('copy-controls', 'copy_valid_null_with', lambda row: row.update(native=None)))
    reject('copy rejection surprise normalized', lambda: mutate('copy-controls', 'copy_rejected_with', lambda row: row.update(native=[None, ''])))
    reject('nonadmitted arity promoted', lambda: mutate('intake', 'arity_profile', lambda row: row['metadata'].update(language_agnostic_action_ir_ready=1)))
    lost = copy.deepcopy(observations['intake'])
    lost.pop('valid_empty_with')
    reject('missing healthy source', lambda: validate(lost, cases['intake'], 'intake'))
    damaged = copy.deepcopy(view_fixture)
    damaged[0]['source'] += ' '
    reject('projected source drift', lambda: equal(damaged, projected))
    reject('actual module drift', lambda: equal(copy_module, copy_module + b'\n'))
    return dict(original_groups=len(cases['intake']), view_failures=sorted(VIEW_RED),
                separate_copy_oracle_failure='constructor_copy_oracle', nonadmitted_arity_profile=1,
                qualified_copy_groups=len(copy_fixture), copy_failures=sorted(COPY_RED),
                frozen_view_sources=len(view_fixture), frozen_view_healthy=8, frozen_view_red=7,
                recovery_corruptions=rejected, production_changes=0,
                scope='finite original16 and independent copy6 at identical declared runtime inputs; shared15 is a source-preserving projection, not one original15 execution; peers/full native-transitive custody/isolation/admission separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
