"""Readonly scoped copy-result RED/GREEN, preservation and source inverse proof."""
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
BASE = Path('docs/checkpoints/copy-result-guard-perl-2026-11-06')
ACTIVATION = 'e2eab09c3452ae2a2e54c0b7d6a46acae08fb1f2'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
RED = {'copy_rejected_with', 'copy_rejected_default', 'receiver_copy_control',
       'repeated_copy_rejection', 'logical_rejection'}


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


def recover(directory):
    expected = json.loads((ROOT / directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(ROOT / directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            raw = archive.extractfile(member).read()
            row = expected[member.name]
            assert hashlib.sha256(raw).hexdigest() == row['sha256'] and len(raw) == row['bytes']
            assert member.mode & 0o777 == row['mode']
            found[member.name] = raw
    assert found.keys() == expected.keys()
    return found


def raw(directory, channel):
    return gzip.decompress((ROOT / directory / (channel + '.log.gz')).read_bytes())


def frames(body, prefix, diagnostic=True):
    result = {}
    pattern = r'^\s*# ' if diagnostic else '^'
    for line in body.decode().splitlines():
        match = re.match(pattern + prefix + r' ([a-z0-9_]+) (.*)$', line)
        if match:
            assert match[1] not in result
            result[match[1]] = json.loads(match[2])
    return result


def prepared(row):
    assert row['native_callable'] == row['loaded'] == 1
    assert all(row[name] is None for name in ('descriptor_error', 'emission_error', 'build_error', 'load_error'))


def target(row, case):
    prepared(row)
    assert not row['warnings']
    assert same(row['metadata'], dict(language_agnostic_action_ir_ready=1,
        raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
        unresolved_helper_count=0, unresolved_helpers=[]))
    if case.get('expected_error'):
        for route in ('native', 'fresh'):
            error = row[route + '_error']
            assert isinstance(error, dict) and case['expected_error'] in error['detail']
        assert row['native_error']['stage'] == 'rule_handler_eval'
        assert row['fresh_error']['stage'] == 'execute_generated'
    else:
        assert row['native_error'] is row['fresh_error'] is None
        assert same(row['native'], case['expected']) and same(row['fresh'], case['expected'])


def validate(rows, cases, phase):
    assert list(rows) == [case['id'] for case in cases]
    for case in cases:
        identifier, row = case['id'], rows[case['id']]
        if phase == 'before' and identifier in RED:
            prepared(row)
            assert row['native_error'] is row['fresh_error'] is None and not row['warnings']
            expected = [1, 'D'] if identifier == 'copy_rejected_default' else ['ran', 'DW' if identifier == 'logical_rejection' else 'W']
            assert same(row['native'], expected) and same(row['fresh'], expected)
        elif phase == 'after' and identifier == 'logical_rejection':
            assert isinstance(row['native_error'], dict)
            assert row['native_error']['stage'] == 'rule_handler_compile'
            assert row['loaded'] == 0 and 'syntax error' in row['load_error'] and row['warnings']
        else:
            target(row, case)


def artifacts(directory, observations, supplied, cases):
    assert list(supplied) == [case['id'] for case in cases]
    result = {}
    for case in cases:
        identifier = case['id']
        assert supplied[identifier]['source'] == case['source']
        for field, payload in (('module_input', 'emitted'), ('handler_input', 'handler')):
            item = observations[identifier][field]
            path = PurePosixPath(item['path'])
            assert not path.is_absolute() and '..' not in path.parts
            assert str(path).startswith(str(directory) + '/')
            body = gzip.decompress((ROOT / str(path)).read_bytes())
            assert hashlib.sha256(body).hexdigest() == item['sha256'] and len(body) == item['bytes']
            assert body.decode() == supplied[identifier][payload]
            result[(identifier, payload)] = body
    return result


def equal(a, b):
    assert a == b


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        body = (ROOT / path).read_bytes()
        assert hashlib.sha256(body).hexdigest() == expected['sha256'] and len(body) == expected['bytes']
    phases = ('before', 'after', 'final', 'direct')
    data = {phase: recover(BASE / phase) for phase in phases}
    cases = []
    for name in ('copy_result_guard_cases.json', 'copy_result_guard_perl_preservation_cases.json'):
        path = 'tests/fixtures/' + name
        assert all(data[phase][path] == data['before'][path] for phase in phases)
        cases += json.loads(data['before'][path])
    ids = {case['id'] for case in cases}
    assert len(ids) == len(cases) == 12 and RED <= ids
    assert all(data[phase]['t/copy_result_guard_composition.t'] == data['before']['t/copy_result_guard_composition.t'] for phase in phases)
    owned = {}
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl']))) as archive:
        owned = {member.name: archive.extractfile(member).read() for member in archive if member.isfile()}
    assert all(data['before'][path] == body for path, body in owned.items())
    for phase in ('after', 'final'):
        assert {path for path in owned if data[phase][path] != data['before'][path]} == {OWNER}
    assert all(data['direct'][path] == data['final'][path] for path in owned)
    observations, emitted = {}, {}
    for phase in phases:
        directory = BASE / phase
        assert (ROOT / directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert (ROOT / directory / 'exit.txt').read_text() == ('1\n' if phase in ('before', 'after') else '0\n')
        rows = frames(raw(directory, 'stderr'), 'COPY_RESULT_PERL')
        validate(rows, cases, phase)
        supplied = frames(raw(directory, 'stderr'), 'COPY_RESULT_INPUT')
        emitted[phase] = artifacts(directory, rows, supplied, cases)
        observations[phase] = rows
    for case in cases:
        if case['id'] not in RED:
            def semantic(row):
                return {key: value for key, value in row.items() if key not in ('module_input', 'handler_input')}
            assert same(semantic(observations['before'][case['id']]), semantic(observations['final'][case['id']])), 'original healthy semantic observation'
    assert emitted['final'] == emitted['direct'], 'actual final/direct module and handler identity'
    summary = raw(BASE / 'direct', 'stdout').decode()
    assert re.search(r'Files=5, Tests=92,', summary) and summary.rstrip().endswith('Result: PASS')
    assert '-j1' in json.loads((ROOT / BASE / 'direct/command.json').read_bytes())['argv']
    control_root = BASE / 'logical-control'
    controlled = {phase: recover(control_root / phase) for phase in ('inverse', 'restored')}
    overlay = str(control_root / 'owner.pm')
    final_owner = data['final'][OWNER]
    needle = b'my $guarded_result_logical_chain = ($ordinary_count_result_chain || $ordinary_length_result_chain || $ordinary_key_count_result_chain\n    || $ordinary_copy_result_chain)'
    assert final_owner.count(needle) == 1
    assert controlled['restored'][overlay] == final_owner
    assert controlled['inverse'][overlay] == final_owner.replace(needle, needle.replace(b'\n    || $ordinary_copy_result_chain', b''))
    assert {path for path in controlled['inverse'] if controlled['inverse'][path] != controlled['restored'][path]} == {overlay}
    for phase in ('inverse', 'restored'):
        directory = control_root / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n'
        assert raw(directory, 'stderr') == b''
        rows = frames(raw(directory, 'stdout'), 'COPY_CONTROL_PERL', False)
        case = next(case for case in cases if case['id'] == 'logical_rejection')
        assert list(rows) == ['logical_rejection']
        if phase == 'inverse':
            assert isinstance(rows['logical_rejection']['native_error'], dict)
            assert rows['logical_rejection']['native_error']['stage'] == 'rule_handler_compile'
            assert rows['logical_rejection']['loaded'] == 0
        else:
            target(rows['logical_rejection'], case)
        artifacts(directory, rows, frames(raw(directory, 'stdout'), 'COPY_CONTROL_INPUT', False), [case])
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(identifier, operation):
        rows = copy.deepcopy(observations['final'])
        operation(rows[identifier])
        validate(rows, cases, 'final')

    reject('rejected with recovery', lambda: mutate('copy_rejected_with', lambda row: row.update(native=['ran', 'W'])))
    reject('legitimate null suppressed', lambda: mutate('copy_valid_null_with', lambda row: row.update(native=[None, ''])))
    reject('logical operand runs', lambda: mutate('logical_rejection', lambda row: row.update(fresh=[None, 'D'])))
    reject('needed error masked', lambda: mutate('needed_copy_source_error', lambda row: row.update(native_error=None)))
    lost = copy.deepcopy(observations['final'])
    lost.pop('bridge_rejection')
    reject('missing healthy bridge', lambda: validate(lost, cases, 'final'))
    body = emitted['final'][('copy_rejected_with', 'emitted')]
    reject('module body drift', lambda: equal(body, body + b'\n'))
    return dict(groups=len(cases), original_healthy=len(cases)-len(RED), original_red=len(RED),
                first_candidate_pass=len(cases)-1, first_candidate_regression='logical_rejection compile failure',
                final_pass=len(cases), direct_files=5, direct_top_level_tests=92,
                same_path_source_inverse='actual RED/restored GREEN; only logical copy-role predicate changes',
                recovery_corruptions=rejected,
                scope='focused Perl canonical copy source/prefix repair; original/failed/final epochs retained; full native-transitive custody/isolation, registration23.4.1, peers and full23.4 remain separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
