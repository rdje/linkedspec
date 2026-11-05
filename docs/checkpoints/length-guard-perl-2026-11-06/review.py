"""Read-only finite Length RED/GREEN and declared-input recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import tarfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path('docs/checkpoints/length-guard-perl-2026-11-06')
FIXTURE = 'tests/fixtures/length_result_guard_cases.json'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = 't/length_result_guard_composition.t'


def same(a, b):
    return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def archive_inputs(phase):
    directory = ROOT / HERE / phase
    identities = json.loads((directory / 'input-identities.json').read_text())
    recovered = {}
    with tarfile.open(directory / 'inputs-before.tar.gz') as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in recovered
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == identities[member.name]
            recovered[member.name] = body
    assert set(recovered) == set(identities), 'complete declared input recovery'
    return recovered


def observations(phase):
    directory = ROOT / HERE / phase
    stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes()).decode()
    stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes()).decode()
    groups = re.findall(r'^(not )?ok (\d+) - (.*)$', stdout, re.M)
    found = []
    for line in stderr.splitlines():
        match = re.search(r'LENGTH_(?:GUARD_(?:ACTUAL|ERROR)|HOST) (\S+) (\{.*\})', line)
        if match:
            found.append((match[1], json.loads(match[2])))
    return groups, found


def validate(rows, fixtures, require_targets):
    expected_ids = [r['id'] for r in fixtures] + ['empty', 'outer', 'main']
    assert [r[0] for r in rows] == expected_ids, 'observation population/order'
    for identifier, row in rows:
        assert row['native_callable'] == row['loaded'] == 1
        assert not any(row.get(k) for k in ('build_error', 'emission_error', 'load_error', 'descriptor_error'))
        assert row['warnings'] == []
        metadata = row['metadata']
        assert metadata['language_agnostic_action_ir_ready'] == 1
        assert all(metadata[k] == 0 for k in ('raw_perl_dependency_count',
            'canonical_action_ir_fallback_count', 'unresolved_helper_count'))
        if identifier in ('empty', 'outer', 'main'):
            assert row['main_host'] == (dict(main='MAIN') if identifier == 'main' else {})
            assert row['outer_host'] == (dict(outer='OUTER') if identifier == 'outer' else {})
            assert not row['fresh_error']
            if require_targets:
                assert row['fresh'] is None, 'host Hash contamination'
            continue
        fixture = next(f for f in fixtures if f['id'] == identifier)
        if fixture.get('expected_error'):
            for route in ('native', 'fresh'):
                error = row[route+'_error']
                assert isinstance(error, dict)
                assert fixture['expected_error'] in json.dumps(error)
                assert error['stage'] == ('rule_handler_eval' if route == 'native' else 'execute_generated')
                assert row[route] is None
        else:
            assert not row['native_error'] and not row['fresh_error']
            assert row['native_cursor'] == row['fresh_cursor'] == 0
            assert same(row['native'], row['fresh'])
            if require_targets:
                expected = fixture.get('expected', fixture.get('perl_expected'))
                assert same(row['native'], expected), 'target value/kind/effects'


def verify_digest(body, digest):
    assert hashlib.sha256(body).hexdigest() == digest, 'retained proof byte identity'


def main():
    manifests = json.loads((ROOT / HERE / 'retained-identities.json').read_text())
    for path, digest in manifests.items():
        verify_digest((ROOT / path).read_bytes(), digest)
    recovered = {p: archive_inputs(p) for p in ('before', 'after', 'nearest')}
    assert recovered['before'][FIXTURE] == recovered['after'][FIXTURE] == (ROOT / FIXTURE).read_bytes()
    assert recovered['before'][NORMAL] == recovered['after'][NORMAL] == (ROOT / NORMAL).read_bytes()
    assert recovered['after'] == recovered['nearest'], 'same accepted direct inputs'
    changed = [p for p in recovered['before'] if recovered['before'][p] != recovered['after'][p]]
    assert changed == [OWNER], 'only the compiler owner changes between original epochs'
    before_owner = recovered['before'][OWNER].decode()
    after_owner = recovered['after'][OWNER].decode()
    producer = re.compile(r" if \(\$method_call && \$method_call->\{method\} eq 'length'\) \{.*?(?=\nif \(\$method_call && \$method_call->\{method\} eq 'substr')", re.S)
    assert producer.search(before_owner).group() == producer.search(after_owner).group(), 'legacy Length producer unchanged'
    fixtures = json.loads(recovered['before'][FIXTURE])
    groups = {}
    rows = {}
    for phase in ('before', 'after'):
        groups[phase], rows[phase] = observations(phase)
        assert [int(g[1]) for g in groups[phase]] == list(range(1, 20))
        modules = ROOT / HERE / phase / 'modules'
        assert {p.name for p in modules.iterdir()} == {'module-'+str(i)+'.pm.gz' for i in range(1, 20)}
        for module in modules.iterdir():
            assert b'sub Execute' in gzip.decompress(module.read_bytes())
        validate(rows[phase], fixtures, phase == 'after')
    assert [int(g[1]) for g in groups['before'] if g[0]] == [2,3,7,10,11,13,14,17,18,19]
    assert not any(g[0] for g in groups['after'])
    assert (ROOT / HERE / 'before/exit.txt').read_text() == '1\n'
    assert (ROOT / HERE / 'after/exit.txt').read_text() == '0\n'
    healthy = [0,3,4,5,7,8,11,14,15]
    for index in healthy:
        assert same(rows['before'][index], rows['after'][index]), 'original healthy observation changed'
    nearest = ROOT / HERE / 'nearest'
    assert (nearest / 'exit.txt').read_text() == '0\n'
    assert b'Result: PASS' in gzip.decompress((nearest / 'stdout.log.gz').read_bytes())
    rejected = []
    for control in ('missing-row', 'false-as-number', 'host-leak', 'changed-module'):
        altered = copy.deepcopy(rows['after'])
        try:
            if control == 'missing-row': altered.pop()
            elif control == 'false-as-number': altered[11][1]['native'][0] = 0
            elif control == 'host-leak': altered[-1][1]['fresh'] = dict(main='MAIN', k=1)
            else:
                path = str(HERE / 'after/modules/module-1.pm.gz')
                verify_digest((ROOT / path).read_bytes()+b'changed', manifests[path])
            validate(altered, fixtures, True)
        except AssertionError:
            rejected.append(control)
        else:
            raise AssertionError('ineffective control: '+control)
    print(json.dumps(dict(result='PASS', original_groups='9PASS10RED', final_groups='19PASS',
        unchanged_healthy_programs=9, rejected_controls=rejected,
        limits='Finite native/fresh same-process proof and declared own input recovery. Actual new-normal modules persist before eval; nearest consumers retain their existing capture limits. No full native/transitive closure, general isolation, peer or full admission claim.'), sort_keys=True))


if __name__ == '__main__':
    main()
