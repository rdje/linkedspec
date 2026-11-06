"""Readonly scoped Hash-view RED/GREEN, independent profiles and inverse proof."""
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
BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
ACTIVATION = '6845971744426a9c897a994bddfcee3a5f2171b6'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
RED = {'free_sorted_keys_hash_guard', 'receiver_sorted_keys_hash_guard',
       'free_sorted_values_hash_guard', 'receiver_sorted_values_hash_guard',
       'later_with', 'copy_guard', 'logical_guard'}


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


def ready(row):
    assert same(row['metadata'], dict(language_agnostic_action_ir_ready=1,
        raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
        unresolved_helper_count=0, unresolved_helpers=[]))
    assert row['native_callable'] == 1
    assert all(row[name] is None for name in ('descriptor_error', 'emission_error', 'build_error', 'substitution_error'))


def target(row, case):
    ready(row)
    assert row['loaded'] == 1 and row['load_error'] is None and not row['warnings']
    if case.get('expected_error'):
        for route, stage in (('native', 'rule_handler_eval'), ('fresh', 'execute_generated')):
            error = row[route + '_error']
            assert isinstance(error, dict) and case['expected_error'] in error['detail']
            assert error['stage'] == stage
    else:
        assert row['native_error'] is row['fresh_error'] is None
        assert same(row['native'], case['expected']) and same(row['fresh'], case['expected'])


def red(row, receiver=False):
    ready(row)
    error = row['native_error']
    assert isinstance(error, dict)
    if receiver:
        assert error['stage'] == 'rule_handler_compile' and 'syntax error' in error['detail']
        assert row['loaded'] == 0 and 'syntax error' in row['load_error'] and row['warnings']
    else:
        assert error['stage'] == 'rule_handler_eval' and 'Not a HASH reference' in error['detail']
        assert row['loaded'] == 1 and row['load_error'] is None and not row['warnings']
        error = row['fresh_error']
        assert isinstance(error, dict) and error['stage'] == 'execute_generated'
        assert 'Not a HASH reference' in error['detail']


def validate(rows, cases, phase):
    assert list(rows) == [case['id'] for case in cases]
    for case in cases:
        identifier = case['id']
        if phase == 'before' and identifier in RED:
            red(rows[identifier], identifier.startswith('receiver_'))
        else:
            target(rows[identifier], case)


def semantic(row, normalize_eval=False):
    value = {key: item for key, item in row.items()
             if key not in ('module_input', 'handler_input', 'substitution')}
    if normalize_eval:
        # Generated eval serials vary with compiler work; retain every other byte.
        value = json.loads(re.sub(r'\(eval \d+\)', '(eval ID)', json.dumps(value)))
    return value


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
    phases = ('before', 'after', 'direct', 'direct-qualified', 'profile-before', 'profile-after')
    data = {phase: recover(BASE / phase) for phase in phases}
    fixture = 'tests/fixtures/hash_view_result_guard_cases.json'
    cases = json.loads(data['before'][fixture])
    assert len(cases) == len({case['id'] for case in cases}) == 15
    assert RED <= {case['id'] for case in cases}
    assert all(data[phase][fixture] == data['before'][fixture] for phase in phases)
    normal = 't/hash_view_result_guard_composition.t'
    assert all(data[phase][normal] == data['before'][normal] for phase in phases)
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl']))) as archive:
        owned = {member.name: archive.extractfile(member).read() for member in archive if member.isfile()}
    assert all(data['before'][path] == data['profile-before'][path] == body for path, body in owned.items())
    assert {path for path in owned if data['after'][path] != data['before'][path]} == {OWNER}
    assert all(data[phase][path] == data['after'][path] for phase in ('direct', 'direct-qualified', 'profile-after') for path in owned)
    observations, emitted = {}, {}
    for phase in ('before', 'after', 'direct', 'direct-qualified'):
        directory = BASE / phase
        assert (ROOT / directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert (ROOT / directory / 'exit.txt').read_text() == ('1\n' if phase in ('before', 'direct') else '0\n')
        rows = frames(raw(directory, 'stderr'), 'HASH_VIEW_RESULT_PERL')
        validate(rows, cases, phase)
        supplied = frames(raw(directory, 'stderr'), 'HASH_VIEW_RESULT_INPUT')
        emitted[phase] = artifacts(directory, rows, supplied, cases)
        observations[phase] = rows
    for case in cases:
        if case['id'] not in RED:
            assert same(semantic(observations['before'][case['id']]), semantic(observations['after'][case['id']])), 'healthy semantics'
    assert emitted['after'] == emitted['direct'] == emitted['direct-qualified'], 'actual module and handler identity'
    failed_direct = raw(BASE / 'direct', 'stdout').decode()
    assert 'Files=4, Tests=67,' in failed_direct and failed_direct.rstrip().endswith('Result: FAIL')
    assert re.search(r't/sorted_values_scalar_isolation.t\s+\(Wstat: 256 Tests: 15 Failed: 1\)', failed_direct)
    failed_diagnostics = raw(BASE / 'direct', 'stderr').decode()
    assert "Failed test 'fluent Length Number'" in failed_diagnostics
    summary = raw(BASE / 'direct-qualified', 'stdout').decode()
    total = re.search(r'Files=4, Tests=(\d+),', summary)
    assert total and summary.rstrip().endswith('Result: PASS')
    assert '-j1' in json.loads((ROOT / BASE / 'direct-qualified/command.json').read_bytes())['argv']
    oracle = 'tests/fixtures/sorted_values_scalar_isolation.json'
    original_oracle = json.loads(data['direct'][oracle])
    expected_oracle = copy.deepcopy(original_oracle)
    changed_rows = [row for row in expected_oracle if row['name'] == 'fluent Length Number']
    assert len(changed_rows) == 1 and changed_rows[0]['expected'] == []
    changed_rows[0]['expected'] = None
    assert same(json.loads(data['direct-qualified'][oracle]), expected_oracle)
    assert data['direct'][oracle] == data['before'][oracle] == data['after'][oracle]
    frozen = json.loads((ROOT / BASE / 'frozen-profiles.json').read_bytes())
    profiles = {}
    profile_cases = json.loads(data['profile-before'][str(BASE / 'profiles.json')])
    assert len(profile_cases) == 5
    for phase in ('profile-before', 'profile-after'):
        directory = BASE / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n' and raw(directory, 'stderr') == b''
        assert (ROOT / directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert data[phase][str(BASE / 'profiles.json')] == data['profile-before'][str(BASE / 'profiles.json')]
        rows = frames(raw(directory, 'stdout'), 'HASH_VIEW_PERL', False)
        assert list(rows) == [case['id'] for case in profile_cases]
        artifacts(directory, rows, frames(raw(directory, 'stdout'), 'HASH_VIEW_INPUT', False), profile_cases)
        assert all(same(semantic(row, True), semantic(frozen['observations'][identifier], True)) for identifier, row in rows.items())
        profiles[phase] = rows
    assert hashlib.sha256(raw(BASE / 'profile-before', 'stdout')).hexdigest() == frozen['raw_stdout_sha256']
    control_root = BASE / 'guard-control'
    controlled = {phase: recover(control_root / phase) for phase in ('inverse', 'restored')}
    overlay = str(control_root / 'owner.pm')
    final_owner = data['after'][OWNER]
    needle = b'my $ordinary_hash_view_result_chain = ('
    assert final_owner.count(needle) == 1 and controlled['restored'][overlay] == final_owner
    assert controlled['inverse'][overlay] == final_owner.replace(needle, b'my $ordinary_hash_view_result_chain = 0 && (')
    assert {path for path in controlled['inverse'] if controlled['inverse'][path] != controlled['restored'][path]} == {overlay}
    for phase in ('inverse', 'restored'):
        directory = control_root / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n' and raw(directory, 'stderr') == b''
        rows = frames(raw(directory, 'stdout'), 'HASH_VIEW_CONTROL_PERL', False)
        case = next(case for case in cases if case['id'] == 'free_sorted_keys_hash_guard')
        assert list(rows) == [case['id']]
        red(rows[case['id']]) if phase == 'inverse' else target(rows[case['id']], case)
        artifacts(directory, rows, frames(raw(directory, 'stdout'), 'HASH_VIEW_CONTROL_INPUT', False), [case])
    policy_root = BASE / 'policy-control'
    policy = {phase: recover(policy_root / phase) for phase in ('activation', 'implemented')}
    policy_overlay = str(policy_root / 'owner.pm')
    assert policy['activation'][policy_overlay] == owned[OWNER]
    assert policy['implemented'][policy_overlay] == final_owner
    assert {path for path in policy['activation'] if policy['activation'][path] != policy['implemented'][path]} == {policy_overlay}
    policy_bodies = {}
    for phase in ('activation', 'implemented'):
        directory = policy_root / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n' and raw(directory, 'stderr') == b''
        policy_cases = json.loads(policy[phase][str(policy_root / 'case.json')])
        assert len(policy_cases) == 1 and same(policy_cases[0]['expected'], [None, []])
        rows = frames(raw(directory, 'stdout'), 'HASH_VIEW_CONTROL_PERL', False)
        assert list(rows) == [policy_cases[0]['id']]
        target(rows[policy_cases[0]['id']], policy_cases[0])
        assert "ref($__ls_selected_default) eq 'HASH'" in rows[policy_cases[0]['id']]['substitution']
        policy_bodies[phase] = artifacts(directory, rows, frames(raw(directory, 'stdout'), 'HASH_VIEW_CONTROL_INPUT', False), policy_cases)
    assert policy_bodies['activation'] == policy_bodies['implemented'], 'this policy generated source is unchanged'
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(identifier, operation):
        rows = copy.deepcopy(observations['after'])
        operation(rows[identifier])
        validate(rows, cases, 'after')

    reject('guard operand runs', lambda: mutate('free_sorted_keys_hash_guard', lambda row: row.update(native=[None, 'K'])))
    reject('copy recovers rejection', lambda: mutate('copy_guard', lambda row: row.update(native=['ran', 'W'])))
    reject('Boolean becomes numeric', lambda: mutate('nested_kinds', lambda row: row.update(fresh=[0, 8])))
    reject('needed error masked', lambda: mutate('needed_source_error', lambda row: row.update(native_error=None)))
    lost = copy.deepcopy(observations['after'])
    lost.pop('source_once_snapshot')
    reject('missing snapshot row', lambda: validate(lost, cases, 'after'))
    changed = copy.deepcopy(profiles['profile-after']['arity_profile'])
    changed['metadata']['language_agnostic_action_ir_ready'] = 1
    reject('malformed arity admitted', lambda: equal(semantic(changed, True), semantic(frozen['observations']['arity_profile'], True)))
    changed_error = copy.deepcopy(profiles['profile-after']['values_array_error_profile'])
    changed_error['native_error'] = None
    reject('source-domain error erased', lambda: equal(semantic(changed_error, True), semantic(frozen['observations']['values_array_error_profile'], True)))
    body = emitted['after'][('copy_guard', 'emitted')]
    reject('module body drift', lambda: equal(body, body + b'\n'))
    return dict(groups=len(cases), original_healthy=len(cases)-len(RED), original_red=len(RED),
                final_pass=len(cases), direct_files=4, direct_top_level_tests=int(total[1]),
                independent_profiles=len(profile_cases), same_path_source_inverse='actual reference-error RED/restored GREEN',
                oracle_correction='one stale fluent Length expectation; activation/final actual [null,[]] and emitted bytes identical',
                recovery_corruptions=rejected,
                scope='Focused Perl canonical ordinary Hash-view repair; original producer/source policies retained. Full native/transitive custody, isolation, registration23.4.1, callable contexts, peers and full23.4 remain separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
