"""Readonly recovery of original Perl Array targets, source policies and host RED."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
ACTIVATION = '4f31a7ea604098bbec159cfe2a1d6462722f113d'
HELPERS = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
RED = {n + '_' + r + '_hash_guard' for n in HELPERS for r in ('free', 'receiver')} | {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
            canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
FIELDS = ('metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings').split()


def normalize(value):
    if isinstance(value, list):
        return [normalize(v) for v in value]
    if isinstance(value, dict):
        return {k: normalize(v) for k, v in value.items()}
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def same(a, b):
    return json.dumps(a, sort_keys=True, separators=(',', ':')) == json.dumps(b, sort_keys=True, separators=(',', ':'))


def frames(raw, tag):
    result = {}
    for line in raw.decode().splitlines():
        if line.startswith(tag + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in result, 'duplicate-frame'
            result[identifier] = json.loads(body)
    return result


def recover(phase, fixture):
    directory = ROOT / BASE / phase
    assert (directory / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((directory / 'stderr.log.gz').read_bytes()) == b''
    assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
    records = json.loads((directory / 'input-identities.json').read_bytes())
    inputs = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in inputs
            raw = archive.extractfile(member).read()
            identity = records[member.name]
            assert hashlib.sha256(raw).hexdigest() == identity['sha256'] and len(raw) == identity['bytes'], 'input-identity'
            assert member.mode & 0o777 == identity['mode']
            inputs[member.name] = raw
    assert inputs.keys() == records.keys()
    own = [p for p in inputs if p.startswith('perl/') or p.startswith('specs/')]
    for path in own:
        assert inputs[path] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + path], cwd=ROOT), 'activation-source'
    cases = json.loads(inputs[str(BASE / fixture)])
    stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
    rows, supplied = frames(stdout, 'ARRAY_TRANSFORM_PERL'), frames(stdout, 'ARRAY_TRANSFORM_INPUT')
    assert list(rows) == list(supplied) == [c['id'] for c in cases], 'case-membership'
    for case in cases:
        identifier = case['id']
        assert supplied[identifier]['source'] == case['source']
        for suffix, field, payload in (('pm', 'module_input', 'emitted'), ('handler.pl', 'handler_input', 'handler')):
            artifact = rows[identifier][field]
            assert artifact['path'] == str(BASE / phase / (identifier + '.' + suffix + '.gz'))
            raw = gzip.decompress((ROOT / artifact['path']).read_bytes())
            assert len(raw) == artifact['bytes'] and hashlib.sha256(raw).hexdigest() == artifact['sha256'], 'artifact-identity'
            assert raw.decode() == supplied[identifier][payload], 'artifact-channel'
    return cases, rows


def targets(cases, rows):
    for case in cases:
        identifier = case['id']
        row = rows[identifier]
        assert row['metadata'] == META and row['native_callable'] == 1
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error'))
        if identifier in RED:
            assert isinstance(row['native_error'], dict), 'missing-original-error'
            if '_receiver_hash_guard' in identifier:
                assert row['loaded'] == 0 and 'fresh_error' not in row, 'invented-fresh-execution'
                assert row['native_error']['stage'] == 'rule_handler_compile' and 'syntax error' in row['load_error']
            else:
                assert row['loaded'] == 1 and isinstance(row['fresh_error'], dict)
                assert 'Not a HASH reference' in row['native_error']['detail'] and 'Not a HASH reference' in row['fresh_error']['detail']
        elif case.get('expected_error'):
            assert isinstance(row.get('native_error'), dict) and isinstance(row.get('fresh_error'), dict), 'masked-needed-error'
            assert all(case['expected_error'] in row[r + '_error']['detail'] for r in ('native', 'fresh'))
        else:
            assert row['native_error'] is row['fresh_error'] is None
            assert same(row['native'], case['expected']) and same(row['fresh'], case['expected']), 'healthy-value-kind'


def host(cases, rows):
    assert len(cases) == 48 and list(rows) == [c['id'] for c in cases]
    for case in cases:
        row = rows[case['id']]
        assert row['metadata'] == META and row['loaded'] == row['native_callable'] == 1
        assert row['native_error'] is row['fresh_error'] is None and not row['warnings']
        assert row['host_before'] == row['host_after'], 'host-mutation'
        assert '@3' in row['substitution'], 'lost-numeric-shortcut'
        expected_empty = ['extra'] if 'concat_arrays' in case['id'] else []
        if case['seed'] == 'main':
            assert row['native'] != expected_empty and row['native'] == row['fresh'], 'hidden-host-read'
        else:
            assert row['native'] == row['fresh'] == expected_empty, 'wrong-host-namespace'


def main():
    initial, rows = recover('preflight', 'cases.json')
    original = json.loads((ROOT / 'tests/fixtures/array_transform_result_guard_cases.json').read_bytes())
    assert initial[:37] == original
    targets(original, rows)
    supplement, extra = recover('supplement', 'supplement_cases.json')
    profiles = json.loads((ROOT / 'tests/fixtures/array_transform_result_guard_perl_profiles.json').read_bytes())
    expected = [(c, rows[c['id']]) for c in initial if c.get('profile_only')] + [(c, extra[c['id']]) for c in supplement]
    assert len(profiles) == len(expected) == 123
    for profile, (case, row) in zip(profiles, expected):
        assert profile['case'] == case
        assert same(profile['expected_observation'], normalize({k: row[k] for k in FIELDS if k in row})), 'original-profile'
    seeded, observed = recover('host_before', 'host_cases.json')
    host(seeded, observed)
    failed = ROOT / BASE / 'before'
    assert (failed / 'exit.txt').read_text() == '2\n'
    assert b"observer.pl" in gzip.decompress((failed / 'stderr.log.gz').read_bytes())
    controls = []
    for name, validator, cases, original_rows, identifier, field, value, reason in (
        ('hidden-runtime-error', targets, original, rows, 'take_free_hash_guard', 'native_error', None, 'missing-original-error'),
        ('invented-fresh-call', targets, original, rows, 'take_receiver_hash_guard', 'fresh_error', None, 'invented-fresh-execution'),
        ('masked-needed-error', targets, original, rows, 'needed_source_error_composed', 'native_error', None, 'masked-needed-error'),
        ('healthy-order-drift', targets, original, rows, 'take_compatible', 'native', ['wrong'], 'healthy-value-kind'),
        ('hidden-host-read', host, seeded, observed, 'literal_number_take_free_main', 'native', [], 'hidden-host-read'),
        ('host-mutation', host, seeded, observed, 'literal_number_take_free_main', 'host_after', {}, 'host-mutation'),
    ):
        changed = copy.deepcopy(original_rows)
        changed[identifier][field] = value
        try:
            validator(cases, changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error))
            controls.append(name)
        else:
            raise AssertionError('ineffective-control:' + name)
    print(json.dumps(dict(result='PASS', targets='original37:19RED/18healthy', profiles='own123 unchanged',
                         host='eight producers/free+receiver:16 main-only reads;48 authored localized controls',
                         controls=controls, limit='No production repair or source/context/native-transitive admission'), indent=2))


if __name__ == '__main__':
    main()
