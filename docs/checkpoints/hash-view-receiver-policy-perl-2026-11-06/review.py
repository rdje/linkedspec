"""Readonly Perl first-view policy restoration and numeric source isolation proof."""
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
BASE = Path('docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06')
ACTIVATION = 'f5dded000bb9253e611510fff02a0e59c94eb85c'
HISTORICAL = '6845971744426a9c897a994bddfcee3a5f2171b6'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = 't/hash_view_receiver_source_policy.t'
POLICY = 'tests/fixtures/hash_view_receiver_policy_perl_cases.json'
SEEDS = 'tests/fixtures/hash_view_numeric_source_perl_cases.json'
REGRESSED = {'sorted_' + view + '_' + source for view in ('keys', 'values')
             for source in ('number', 'null', 'array', 'null_with')}


def digest(body):
    return hashlib.sha256(body).hexdigest()


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


def raw(directory, channel):
    return gzip.decompress((ROOT / directory / (channel + '.log.gz')).read_bytes())


def frames(body, prefix, diagnostic=False):
    result = {}
    for line in body.decode().splitlines():
        match = re.match((r'^\s*# ' if diagnostic else '^') + prefix + r' ([a-z0-9_]+) (.*)$', line)
        if match:
            assert match[1] not in result
            result[match[1]] = json.loads(match[2])
    return result


def recover(directory):
    expected = json.loads((ROOT / directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(ROOT / directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            body = archive.extractfile(member).read()
            row = expected[member.name]
            assert digest(body) == row['sha256'] and len(body) == row['bytes']
            assert member.mode & 0o777 == row['mode']
            found[member.name] = body
    assert found.keys() == expected.keys()
    return found


def ready(row):
    assert row['native_callable'] == row['loaded'] == 1
    assert all(row[field] is None for field in ('substitution_error', 'descriptor_error', 'build_error', 'emission_error', 'load_error'))
    assert row['warnings'] == []
    assert same(row['metadata'], dict(language_agnostic_action_ir_ready=1,
        raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
        unresolved_helper_count=0, unresolved_helpers=[]))


def host(state):
    return dict(main={'host_main': 'MAIN'} if state == 'main' else {},
                outer={'host_outer': 'OUTER'} if state == 'outer' else {})


def target(row, case, state='empty'):
    ready(row)
    assert same(row['host_before'], host(state)) and same(row['host_after'], host(state))
    for route in ('native', 'fresh'):
        assert row[route + '_cursor'] == case.get('cursors', {}).get(route, 0)
        if case.get('expected_error'):
            error = row[route + '_error']
            assert isinstance(error, dict) and error['detail'].startswith(case['expected_error'] + ' at ')
            assert same({key: value for key, value in error.items() if key != 'detail'}, case['expected_error_meta'][route])
        else:
            assert row[route + '_error'] is None and same(row[route], case['expected'])


def semantic(row):
    result = {key: value for key, value in row.items() if key not in
              ('module_input', 'handler_input', 'substitution', 'host_before', 'host_after')}
    return json.loads(re.sub(r'\(eval \d+\)', '(eval ID)', json.dumps(result)))


def artifacts(directory, rows, supplied, source_by_id):
    assert rows.keys() == supplied.keys() == source_by_id.keys()
    result = {}
    for identifier, row in rows.items():
        assert supplied[identifier]['source'] == source_by_id[identifier]
        for field, payload in (('module_input', 'emitted'), ('handler_input', 'handler')):
            item = row[field]
            path = PurePosixPath(item['path'])
            assert not path.is_absolute() and '..' not in path.parts
            assert str(path).startswith(str(directory) + '/')
            body = gzip.decompress((ROOT / str(path)).read_bytes())
            assert digest(body) == item['sha256'] and len(body) == item['bytes']
            assert body.decode() == supplied[identifier][payload]
            result[(identifier, payload)] = body
    return result


def validate_normal(rows, cases, seeds, before=False):
    identifiers = [case['id'] for case in cases] + ['seed_' + case['id'] + '_' + state for case in seeds for state in ('empty', 'outer', 'main')]
    assert list(rows) == identifiers
    for case in cases:
        row, identifier = rows[case['id']], case['id']
        if before and identifier in REGRESSED:
            ready(row)
            assert row['native_error'] is row['fresh_error'] is None
            expected = [None, ''] if identifier.endswith('null_with') else None
            assert same(row['native'], expected) and same(row['fresh'], expected)
        else:
            target(row, case)
    for case in seeds:
        for state in ('empty', 'outer', 'main'):
            row = rows['seed_' + case['id'] + '_' + state]
            if before and case['id'] != 'valid_named_hash':
                ready(row)
                assert row['host_before'] == row['host_after'] == host(state)
                expected = None if case['id'] == 'receiver_number' else (['host_main'] if state == 'main' else [])
                assert row['native_error'] is row['fresh_error'] is None
                assert same(row['native'], expected) and same(row['fresh'], expected)
            else:
                target(row, case, state)


def equal(a, b):
    assert a == b


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        assert not PurePosixPath(path).is_absolute() and '..' not in PurePosixPath(path).parts
        body = (ROOT / path).read_bytes()
        assert digest(body) == expected['sha256'] and len(body) == expected['bytes']
    phases = ('historical', 'current', 'seed/historical', 'seed/current', 'before', 'after', 'direct')
    data = {phase: recover(BASE / phase) for phase in phases}
    old_owner = subprocess.check_output(['git', 'show', HISTORICAL + ':' + OWNER])
    base_owner = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER])
    for prefix, overlay in (('', 'owner.pm'), ('seed/', 'seed-owner.pm')):
        earlier, current = data[prefix + 'historical'], data[prefix + 'current']
        path = str(BASE / overlay)
        assert earlier[path] == old_owner and current[path] == base_owner
        assert {name for name in earlier if earlier[name] != current[name]} == {path}
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl']))) as archive:
        owned = {member.name: archive.extractfile(member).read() for member in archive if member.isfile()}
    assert all(data['before'][path] == body for path, body in owned.items())
    for phase in ('after', 'direct'):
        assert {path for path in owned if data[phase][path] != owned[path]} == {OWNER}
    assert all(data['after'][path] == data['direct'][path] for path in owned)
    for phase in phases:
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
    for path in (NORMAL, POLICY, SEEDS):
        assert data['before'][path] == data['after'][path] == data['direct'][path]
    cases, seeds = json.loads(data['before'][POLICY]), json.loads(data['before'][SEEDS])
    assert len(cases) == 13 and len(seeds) == 4 and len(REGRESSED) == 8
    observed = {}
    for phase in ('historical', 'current'):
        directory = BASE / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n' and raw(directory, 'stderr') == b''
        rows = frames(raw(directory, 'stdout'), 'HASH_VIEW_POLICY_PERL')
        assert list(rows) == [case['id'] for case in cases]
        artifacts(directory, rows, frames(raw(directory, 'stdout'), 'HASH_VIEW_POLICY_INPUT'), {case['id']: case['source'] for case in cases})
        observed[phase] = rows
    original_sources = json.loads(data['historical'][str(BASE / 'cases.json')])
    assert [{key: row[key] for key in ('id', 'body', 'source', 'input', 'rule')} for row in cases] == original_sources
    for case in cases:
        identifier, original = case['id'], observed['historical'][case['id']]
        ready(original)
        if case.get('expected_error'):
            assert all(case['expected_error'] in original[route + '_error']['detail'] for route in ('native', 'fresh'))
        else:
            assert original['native_error'] is original['fresh_error'] is None
            assert same(original['native'], case['expected']) and same(original['fresh'], case['expected'])
        if identifier not in REGRESSED:
            assert same(semantic(original), semantic(observed['current'][identifier]))
    for phase in ('seed/historical', 'seed/current'):
        directory = BASE / phase
        assert (ROOT / directory / 'exit.txt').read_text() == '0\n' and raw(directory, 'stderr') == b''
        rows = frames(raw(directory, 'stdout'), 'HASH_VIEW_SOURCE_SEED')
        assert list(rows) == [case['id'] for case in seeds]
        artifacts(directory, rows, frames(raw(directory, 'stdout'), 'HASH_VIEW_POLICY_INPUT'), {case['id']: case['source'] for case in seeds})
        for case in seeds:
            row = rows[case['id']]
            ready(row)
            assert set(row['runs']) == {'empty', 'outer', 'main'}
            for state, run in row['runs'].items():
                assert run['host_before'] == run['host_after'] == host(state)
                expected = ['a', 'b'] if case['id'] == 'valid_named_hash' else (None if phase == 'seed/current' and case['id'] == 'receiver_number' else (['host_main'] if state == 'main' else []))
                assert run['native_error'] is run['fresh_error'] is None
                assert same(run['native'], expected) and same(run['fresh'], expected)
    source_by_id = {case['id']: case['source'] for case in cases}
    source_by_id.update({'seed_' + case['id'] + '_' + state: case['source'] for case in seeds for state in ('empty', 'outer', 'main')})
    normal, bodies = {}, {}
    for phase in ('before', 'after', 'direct'):
        directory = BASE / phase
        assert (ROOT / directory / 'exit.txt').read_text() == ('1\n' if phase == 'before' else '0\n')
        rows = frames(raw(directory, 'stderr'), 'VIEW_RECEIVER_SOURCE_PERL', True)
        validate_normal(rows, cases, seeds, phase == 'before')
        normal[phase] = rows
        bodies[phase] = artifacts(directory, rows, frames(raw(directory, 'stderr'), 'VIEW_RECEIVER_SOURCE_INPUT', True), source_by_id)
    for case in cases:
        assert same(semantic(observed['historical'][case['id']]), semantic(normal['after'][case['id']])), 'original own policy restored; only eval IDs normalized'
    healthy = 0
    for identifier, row in normal['before'].items():
        if same(semantic(row), semantic(normal['after'][identifier])):
            healthy += 1
    assert healthy == 12
    assert bodies['after'] == bodies['direct'], 'actual25 module/handler identities'
    summary = raw(BASE / 'direct', 'stdout').decode()
    assert 'Files=4, Tests=59,' in summary and summary.rstrip().endswith('Result: PASS')
    original_summary = raw(BASE / 'before', 'stdout').decode()
    assert 'Tests: 17 Failed: 11' in original_summary and original_summary.rstrip().endswith('Result: FAIL')
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(identifier, operation):
        rows = copy.deepcopy(normal['after'])
        operation(rows[identifier])
        validate_normal(rows, cases, seeds)

    reject('null body suppressed', lambda: mutate('sorted_keys_null_with', lambda row: row.update(native=[None, ''])))
    reject('Array error masked', lambda: mutate('sorted_values_array', lambda row: row.update(fresh_error=None)))
    reject('numeric host read', lambda: mutate('seed_free_number_main', lambda row: row.update(native=['host_main'])))
    reject('valid named Hash lost', lambda: mutate('seed_valid_named_hash_outer', lambda row: row.update(fresh=[])))
    reject('produced Count permission revived', lambda: mutate('produced_count', lambda row: row.update(native=[])))
    reject('host input mutated', lambda: mutate('seed_computed_number_main', lambda row: row.update(host_after={'main': {}, 'outer': {}})))
    missing = copy.deepcopy(normal['after'])
    missing.pop('seed_receiver_number_empty')
    reject('missing source row', lambda: validate_normal(missing, cases, seeds))
    body = bodies['after'][('sorted_keys_null_with', 'emitted')]
    reject('module drift', lambda: equal(body, body + b'\n'))
    return dict(policy_sources=13, restored_regressions=8, unchanged_policy_controls=5,
                numeric_seed_sources=4, seed_states=['empty', 'outer', 'main'],
                normal_groups=17, normal_before_failed=11, final_pass=17,
                healthy_before_observations_exact=12, final_direct_module_handler_pairs=25,
                direct_files=4, direct_top_level_tests=59, recovery_corruptions=rejected,
                scope='Focused own Perl receiver-policy restoration and bounded numeric sorted_keys isolation; historical owner source counterfactuals use same current SDK. Full native/cache/context custody, broad SESSION17 isolation, registration and full23.4 remain separate')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
