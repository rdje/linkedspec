"""Readonly recovery of actual source images, unchanged tests and host oracles."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import runpy
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/hash-helper-source-isolation-perl-2026-11-07')
ACTIVATION = '8005ebf9ca2aa2d195d0ce7ce4da697de7b956c4'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = str(BASE / 'control-owner.pm')
PHASES = ('before', 'after', 'qualified_after', 'private_inverse', 'private_restored', 'qualified_direct')
prior = runpy.run_path(str(ROOT / 'docs/checkpoints/hash-value-result-guard-perl-2026-11-07/review_preflight.py'))
same, projection = prior['same'], prior['projection']


def frames(raw, prefix):
    result = {}
    for line in raw.decode().splitlines():
        line = line.lstrip(' #\t')
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(body)
    return result


def recover(phase):
    directory = ROOT / BASE / phase
    records = json.loads((directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in found
            raw = archive.extractfile(member).read()
            expected = records[member.name]
            assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
            assert member.mode & 0o777 == expected['mode']
            found[member.name] = raw
    assert found.keys() == records.keys()
    return found


def artifact(identifier, suffix, payload, row, supplied, raw, phase):
    expected = row['module_input' if suffix == 'pm' else 'handler_input']
    assert expected['path'] == str(BASE / phase / (identifier + '.' + suffix + '.gz'))
    assert len(raw) == expected['bytes'] and hashlib.sha256(raw).hexdigest() == expected['sha256']
    assert raw.decode() == supplied[payload]


def legacy_main(case):
    identifier = case['id']
    if identifier == 'merge_number_overlay':
        return {'a': 'HOST_MAIN', 'host_main': 'MAIN'}
    if identifier == 'pick_number_key_effect':
        return [{'a': 'HOST_MAIN'}, 'SK']
    if identifier == 'drop_number_key_effect':
        return [{'host_main': 'MAIN'}, 'SK']
    if identifier in ('pick_null_key_effect', 'drop_null_key_effect'):
        return case['expected']
    if any(helper in identifier for helper in ('merge_hash', 'set_key')) or identifier == 'merge_string_source':
        return {'a': 'HOST_MAIN', 'b': 2, 'host_main': 'MAIN'}
    if 'rename_key' in identifier:
        return {'b': 'HOST_MAIN', 'host_main': 'MAIN'}
    if 'drop_keys' in identifier:
        return {'host_main': 'MAIN'}
    assert 'pick_keys' in identifier
    return {'a': 'HOST_MAIN'}


def validate(rows, targets, profiles, phase):
    identifiers = ['host_' + c['id'] for c in targets] + ['policy_' + p['case']['id'] for p in profiles]
    assert list(rows) == identifiers and len(identifiers) == 64
    for case in targets:
        identifier = 'host_' + case['id']
        row = rows[identifier]
        assert row['native_callable'] == row['loaded'] == 1 and row['warnings'] == []
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error', 'load_error'))
        assert row['metadata'] == dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
            canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
        assert set(row['runs']) == {'empty', 'outer', 'main'}
        original = phase in ('before', 'private_inverse')
        partial = phase == 'after' and (case['id'].startswith('initial_number_') or case['id'] == 'merge_number_overlay')
        for state, run in row['runs'].items():
            hosts = dict(main={'a': 'HOST_MAIN', 'host_main': 'MAIN'} if state == 'main' else {},
                         outer={'a': 'HOST_OUTER', 'host_outer': 'OUTER'} if state == 'outer' else {})
            assert same(run['host_before'], hosts) and same(run['host_after'], hosts)
            expected = legacy_main(case) if state == 'main' and (original or partial) else case['expected']
            assert run['native_error'] is run['fresh_error'] is None
            assert run['native_cursor'] == run['fresh_cursor'] == 0
            assert same(run['native'], expected) and same(run['fresh'], expected), (phase, identifier, state)
        if case['id'].startswith('initial_number_') or case['id'] == 'merge_number_overlay':
            assert ('%3' in row['substitution']) == (original or partial), 'literal-number shortcut independently visible'
    for profile in profiles:
        assert same(projection(rows['policy_' + profile['case']['id']]), profile['expected_observation']), 'all48 original public policies'


def validate_sdk(found, baseline, owner):
    assert {p for p in found if p.startswith(('perl/', 'specs/'))} == set(baseline)
    assert all(found[p] == (owner if p == OWNER else raw) for p, raw in baseline.items())


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    inputs = {phase: recover(phase) for phase in PHASES}
    body = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(body)) as archive:
        baseline = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    original, partial, fixed = (inputs[p][OWNER] for p in ('before', 'after', 'qualified_after'))
    assert len({original, partial, fixed}) == 3 and original == baseline[OWNER]
    for phase in PHASES:
        validate_sdk(inputs[phase], baseline, original if phase == 'before' else partial if phase == 'after' else fixed)
    tests = 't/hash_helper_source_isolation.t'
    fixtures = [str(Path('tests/fixtures') / name) for name in ('hash_helper_source_isolation_perl_cases.json',
                'hash_helper_source_isolation_perl_extra_cases.json', 'hash_value_result_guard_perl_profiles.json')]
    for phase in PHASES:
        assert all(inputs[phase][p] == inputs['before'][p] for p in [tests] + fixtures), 'same actual test and frozen source/targets'
    targets = json.loads(inputs['before'][fixtures[0]]) + json.loads(inputs['before'][fixtures[1]])
    profiles = json.loads(inputs['before'][fixtures[2]])
    assert len(targets) == 16 and len(profiles) == 48
    cases = {'host_' + c['id']: c for c in targets}
    cases.update({'policy_' + p['case']['id']: p['case'] for p in profiles})
    observations, artifacts, summaries = {}, {}, {}
    for phase in PHASES:
        directory = ROOT / BASE / phase
        assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
        expected_exit = 1 if phase in ('before', 'after', 'private_inverse') else 0
        assert (directory / 'exit.txt').read_text() == str(expected_exit) + '\n'
        stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
        stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes())
        rows, supplied = frames(stderr, 'HASH_HELPER_SOURCE_PERL'), frames(stderr, 'HASH_HELPER_SOURCE_INPUT')
        validate(rows, targets, profiles, phase)
        assert list(rows) == list(supplied) == list(cases)
        failures = [line.split(' - ', 1)[1] for line in stdout.decode().splitlines() if line.startswith('not ok ')]
        expected_failures = ['host_' + c['id'] for c in targets if not same(legacy_main(c), c['expected'])]
        if phase == 'after':
            expected_failures = ['host_' + c['id'] for c in targets if c['id'].startswith('initial_number_') or c['id'] == 'merge_number_overlay']
        elif phase not in ('before', 'private_inverse'):
            expected_failures = []
        assert failures == expected_failures
        assert ('Result: FAIL' if expected_exit else 'Result: PASS') in stdout.decode()
        summary = re.search(r'Files=(\d+), Tests=(\d+),', stdout.decode())
        assert summary
        summaries[phase] = dict(files=int(summary[1]), tests=int(summary[2]), failed_groups=len(failures))
        assert summaries[phase]['files'] == (4 if phase == 'qualified_direct' else 1)
        assert summaries[phase]['tests'] == (93 if phase == 'qualified_direct' else 64)
        artifacts[phase] = {}
        for identifier, case in cases.items():
            assert supplied[identifier]['source'] == case['source']
            for suffix, payload in (('pm', 'emitted'), ('handler.pl', 'handler')):
                actual = gzip.decompress((directory / (identifier + '.' + suffix + '.gz')).read_bytes())
                artifact(identifier, suffix, payload, rows[identifier], supplied[identifier], actual, phase)
                artifacts[phase][identifier, suffix] = actual
        if phase.startswith('private_'):
            image = original if phase == 'private_inverse' else fixed
            assert inputs[phase][PRIVATE] == image
            marker = [line.split(' ', 1)[1] for line in stderr.decode().splitlines() if line.startswith('HASH_HELPER_OWNER_IMAGE ')]
            assert len(marker) == 1
            assert json.loads(marker[0]) == dict(path=PRIVATE, sha256=hashlib.sha256(image).hexdigest(), bytes=len(image))
            assert (ROOT / BASE / (phase + '-wrapper-exit.txt')).read_text() == '0\n'
            assert gzip.decompress((ROOT / BASE / (phase + '-wrapper-stderr.log.gz')).read_bytes()) == b''
        observations[phase] = rows
    assert artifacts['qualified_after'] == artifacts['qualified_direct'] == artifacts['private_restored'], 'all64 final/direct/private artifact pairs identical'
    assert artifacts['before'] == artifacts['private_inverse'], 'all64 exact old-source artifact pairs recovered'
    rejected = []

    def reject(name, action):
        try:
            action()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective evidence corruption: ' + name)

    def damage(phase, identifier, action):
        rows = copy.deepcopy(observations[phase])
        action(rows[identifier])
        validate(rows, targets, profiles, phase)

    identifier = 'host_initial_number_merge_hash_free'
    reject('original main read hidden', lambda: damage('before', identifier, lambda r: r['runs']['main'].update(native={'b': 2})))
    reject('fixed main read reintroduced', lambda: damage('qualified_after', identifier, lambda r: r['runs']['main'].update(fresh={'host_main': 'MAIN'})))
    reject('literal shortcut silently retained', lambda: damage('qualified_after', identifier, lambda r: r.update(substitution=r['substitution'] + ' %3')))
    reject('defined scalar key effect skipped', lambda: damage('qualified_after', 'host_pick_number_key_effect', lambda r: r['runs']['empty'].update(native=[{}, 'S'])))
    reject('original Array source error suppressed', lambda: damage('qualified_after', 'policy_initial_array_set_key_free', lambda r: r.update(native_error=None)))
    reject('host mutated', lambda: damage('qualified_after', identifier, lambda r: r['runs']['main']['host_after']['main'].clear()))
    lost = copy.deepcopy(observations['qualified_after'])
    lost.pop(identifier)
    reject('missing source group', lambda: validate(lost, targets, profiles, 'qualified_after'))
    raw = artifacts['qualified_after'][identifier, 'pm']
    row = observations['qualified_after'][identifier]
    reject('actual module drift', lambda: artifact(identifier, 'pm', 'emitted', row, {'emitted': raw.decode()}, raw + b'\n', 'qualified_after'))
    return dict(normal_groups=64, localized_host_targets=16, own_policy_groups=48,
                phase_summaries=summaries, retained_partial_failure=11,
                evidence_corruptions=rejected, artifact_pairs_per_phase=64,
                inverse='exact old/fixed source bodies at one private path; canonical SDK stays fixed',
                scope='finite historical native/fresh source guards and directly affected tests; overlapping source groups, no unique-source census, general SESSION17 isolation, full native-transitive custody or23.4 admission')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
