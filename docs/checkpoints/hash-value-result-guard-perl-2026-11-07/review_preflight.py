"""Readonly original Perl preflight and ten localized host-read oracles."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import runpy
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/hash-value-result-guard-perl-2026-11-07')
SELECTION = Path('docs/checkpoints/hash-value-result-selection-2026-11-07')
ACTIVATION = '37035461c8b1c6838e31982000e4f7aa9a473809'
oracle = runpy.run_path(str(ROOT / SELECTION / 'review.py'))
same, frames = oracle['same'], oracle['frames']


def projection(row):
    keys = ('metadata', 'native_callable', 'loaded', 'substitution_error', 'descriptor_error',
            'emission_error', 'build_error', 'load_error', 'native', 'fresh',
            'native_error', 'fresh_error', 'native_cursor', 'fresh_cursor', 'warnings')
    result = {k: copy.deepcopy(row[k]) for k in keys if k in row}
    # Generated eval serials identify loads, not a public error-policy difference.
    import re
    def normalize(value):
        if isinstance(value, str):
            return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value)
        if isinstance(value, list):
            return [normalize(v) for v in value]
        if isinstance(value, dict):
            return {k: normalize(v) for k, v in value.items()}
        return value
    return normalize(result)


def validate_profiles(rows, cases):
    profiles = [c for c in cases if c.get('policy_profile')]
    assert len(profiles) == 48
    for case in profiles:
        identifier, row = case['id'], rows[case['id']]
        assert row['native_callable'] == row['loaded'] == 1
        assert row['native_cursor'] == row['fresh_cursor'] == 0 and row['warnings'] == []
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error', 'load_error'))
        if identifier.startswith('initial_array_'):
            assert row['native'] is row['fresh'] is None
            for channel, stage in (('native_error', 'rule_handler_eval'), ('fresh_error', 'execute_generated')):
                error = row[channel]
                assert isinstance(error, dict) and error['stage'] == stage
                assert 'Not a HASH reference' in error['detail']
            expected = None
        else:
            assert row['native_error'] is row['fresh_error'] is None
            if identifier.startswith('initial_null_') and identifier.endswith('_with'):
                expected = ['ran', 'W']
            elif identifier.startswith('extra_'):
                expected = ['ran', 'SAW' if 'merge_hash' in identifier else 'W']
            elif identifier.startswith('produced_'):
                expected = [None, '']
            elif identifier.endswith('_zero_keys_profile'):
                expected = None
            else:
                expected = {'b': 2} if any(h in identifier for h in ('merge_hash', 'set_key')) else {}
            assert same(row['native'], expected) and same(row['fresh'], expected), identifier
        unready = identifier.startswith(('extra_set_key_', 'extra_rename_key_')) or identifier.endswith('_zero_keys_profile')
        helper = next((h for h in ('merge_hash', 'set_key', 'rename_key', 'drop_keys', 'pick_keys') if h in identifier), None)
        assert row['metadata'] == dict(language_agnostic_action_ir_ready=0 if unready else 1,
            raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
            unresolved_helper_count=1 if unready else 0, unresolved_helpers=[helper] if unready else [])


def validate_seed(rows, cases):
    assert list(rows) == [c['id'] for c in cases] and len(cases) == 10
    for case in cases:
        identifier, row = case['id'], rows[case['id']]
        assert identifier.startswith('initial_number_')
        assert row['native_callable'] == row['loaded'] == 1 and row['warnings'] == []
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error', 'load_error'))
        assert row['metadata'] == dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
            canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
        helper = next(h for h in ('merge_hash', 'set_key', 'rename_key', 'drop_keys', 'pick_keys') if h in identifier)
        empty = {'b': 2} if helper in ('merge_hash', 'set_key') else {}
        main = ({'a': 'HOST_MAIN', 'b': 2, 'host_main': 'MAIN'} if helper in ('merge_hash', 'set_key')
                else {'b': 'HOST_MAIN', 'host_main': 'MAIN'} if helper == 'rename_key'
                else {'host_main': 'MAIN'} if helper == 'drop_keys' else {'a': 'HOST_MAIN'})
        assert set(row['runs']) == {'empty', 'outer', 'main'}
        for state, run in row['runs'].items():
            hosts = dict(main={'a': 'HOST_MAIN', 'host_main': 'MAIN'} if state == 'main' else {},
                         outer={'a': 'HOST_OUTER', 'host_outer': 'OUTER'} if state == 'outer' else {})
            assert same(run['host_before'], hosts) and same(run['host_after'], hosts)
            assert run['native_error'] is run['fresh_error'] is None
            assert run['native_cursor'] == run['fresh_cursor'] == 0
            assert same(run['native'], main if state == 'main' else empty)
            assert same(run['fresh'], main if state == 'main' else empty)


def recover(phase):
    directory = ROOT / BASE / phase
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in found
            raw = archive.extractfile(member).read()
            row = identities[member.name]
            assert hashlib.sha256(raw).hexdigest() == row['sha256'] and len(raw) == row['bytes']
            assert member.mode & 0o777 == row['mode']
            found[member.name] = raw
    assert found.keys() == identities.keys()
    return found


def artifact(identifier, suffix, payload, row, supplied, raw, phase):
    field = 'module_input' if suffix == 'pm' else 'handler_input'
    expected = row[field]
    assert expected['path'] == str(BASE / phase / (identifier + '.' + suffix + '.gz'))
    assert len(raw) == expected['bytes'] and hashlib.sha256(raw).hexdigest() == expected['sha256']
    assert raw.decode() == supplied[payload]


def main():
    for path, expected in json.loads((ROOT / BASE / 'preflight-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    inputs = {phase: recover(phase) for phase in ('before', 'seed_before')}
    archive = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl',
                                      'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'])
    with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
        owned = {m.name: stream.extractfile(m).read() for m in stream if m.isfile()}
    for phase in inputs:
        assert set(owned) == {p for p in inputs[phase] if p.startswith(('perl/', 'specs/'))}
        assert all(inputs[phase][p] == raw for p, raw in owned.items())
    cases = json.loads(inputs['before'][str(BASE / 'cases.json')])
    seed_cases = json.loads(inputs['seed_before'][str(BASE / 'seed-cases.json')])
    assert len(cases) == 76 and same(seed_cases, [c for c in cases if c['id'].startswith('initial_number_')])
    shared = json.loads((ROOT / 'tests/fixtures/hash_value_result_guard_cases.json').read_bytes())
    assert same(cases[:28], shared)
    observations = {}
    for phase, authored, prefix in (('before', cases, 'HASH_VALUE_GUARD'), ('seed_before', seed_cases, 'HASH_VALUE_SEED')):
        directory = ROOT / BASE / phase
        assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert (directory / 'exit.txt').read_text() == '0\n'
        assert gzip.decompress((directory / 'stderr.log.gz').read_bytes()) == b''
        raw = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
        rows, supplied = frames(raw, prefix + '_PERL'), frames(raw, prefix + '_INPUT')
        assert list(rows) == list(supplied) == [c['id'] for c in authored]
        observations[phase] = rows
        for case in authored:
            identifier = case['id']
            assert supplied[identifier]['source'] == case['source']
            for suffix, payload in (('pm', 'emitted'), ('handler.pl', 'handler')):
                actual = gzip.decompress((directory / (identifier + '.' + suffix + '.gz')).read_bytes())
                artifact(identifier, suffix, payload, rows[identifier], supplied[identifier], actual, phase)
    original32 = json.loads((ROOT / SELECTION / 'cases.json').read_bytes())
    # A source-preserving projection of this actual76, not an original32 rerun.
    projected32 = {c['id']: observations['before'][c['id']] for c in original32}
    oracle['validate'](projected32, original32)
    validate_profiles(observations['before'], cases)
    validate_seed(observations['seed_before'], seed_cases)
    profiles = json.loads((ROOT / 'tests/fixtures/hash_value_result_guard_perl_profiles.json').read_bytes())
    assert same(profiles, [dict(case=c, expected_observation=projection(observations['before'][c['id']]))
                           for c in cases if c.get('policy_profile')])
    targets = json.loads((ROOT / 'tests/fixtures/hash_helper_source_isolation_perl_cases.json').read_bytes())
    assert same(targets, [dict(c, expected={'b': 2} if any(h in c['id'] for h in ('merge_hash', 'set_key')) else {}) for c in seed_cases])
    rejected = []

    def reject(name, action):
        try:
            action()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def damage_seed(identifier, action):
        rows = copy.deepcopy(observations['seed_before'])
        action(rows[identifier])
        validate_seed(rows, seed_cases)

    def damage_profile(identifier, action):
        rows = copy.deepcopy(observations['before'])
        action(rows[identifier])
        validate_profiles(rows, cases)

    identifier = seed_cases[0]['id']
    reject('original host defect hidden', lambda: damage_seed(identifier, lambda r: r['runs']['main'].update(native={'b': 2})))
    reject('outer namespace contamination', lambda: damage_seed(identifier, lambda r: r['runs']['outer'].update(fresh={'host_outer': 'OUTER'})))
    reject('host mutated by probe', lambda: damage_seed(identifier, lambda r: r['runs']['main']['host_after']['main'].clear()))
    reject('Array source error suppressed', lambda: damage_profile('initial_array_set_key_free', lambda r: r.update(native_error=None)))
    reject('legitimate null-source with skipped', lambda: damage_profile('initial_null_pick_keys_with', lambda r: r.update(native=[None, ''])))
    reject('merge extra shape normalized', lambda: damage_profile('extra_merge_hash_free', lambda r: r['metadata'].update(language_agnostic_action_ir_ready=0)))
    lost = copy.deepcopy(observations['seed_before'])
    lost.pop(identifier)
    reject('missing source member', lambda: validate_seed(lost, seed_cases))
    row = observations['seed_before'][identifier]
    actual = gzip.decompress((ROOT / BASE / 'seed_before' / (identifier + '.pm.gz')).read_bytes())
    reject('actual module drift', lambda: artifact(identifier, 'pm', 'emitted', row, {'emitted': actual.decode()}, actual + b'\n', 'seed_before'))
    return dict(original_programs=76, unchanged_shared_targets=28, composition_failures=15, healthy_shared_controls=13,
                own_policy_profiles=48, localized_sources=10, host_states=['empty', 'outer', 'main'],
                main_only_host_read_failures=10, actual_artifact_pairs=86, evidence_corruptions=rejected,
                production_changes=0, immediate_repair='TYPE-REFERENCE-BOOK.1.2.23.3.77.0',
                limits='historical finite Perl public native/fresh preflight only; no general isolation, peer verdict, native-transitive custody or full23.4 admission')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
