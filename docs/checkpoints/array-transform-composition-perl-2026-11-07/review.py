"""Readonly independent Array-result behavior, material and source-boundary recovery."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-composition-perl-2026-11-07')
ACTIVATION = '4bfe17f75c20851bc9a634c151071b6d196de57d'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = str(BASE / 'control-owner.pm')
PHASES = ('before', 'after', 'private_inverse', 'private_restored', 'direct')
ROLES = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
RED = {'target_' + name + '_' + route + '_hash_guard' for name in ROLES for route in ('free', 'receiver')} | {'target_take_later_with', 'target_reverse_copy_later_with', 'target_sort_logical_later_with'}
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
FIELDS = ('metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings').split()


def same(a, b):
    return json.dumps(a, sort_keys=True, separators=(',', ':')) == json.dumps(b, sort_keys=True, separators=(',', ':'))


def normalize(value):
    if isinstance(value, list):
        return [normalize(v) for v in value]
    if isinstance(value, dict):
        return {k: normalize(v) for k, v in value.items()}
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def projection(row):
    return normalize({k: row[k] for k in FIELDS if k in row})


def frames(raw, tag):
    rows = {}
    for line in raw.decode().splitlines():
        line = line.lstrip(' #\t')
        if line.startswith(tag + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in rows, 'duplicate-frame'
            rows[identifier] = json.loads(body)
    return rows


def recover(phase):
    directory = ROOT / BASE / phase
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    inputs = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in inputs
            raw = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], 'archive-identity'
            assert member.mode & 0o777 == row['mode']
            inputs[member.name] = raw
    assert inputs.keys() == identities.keys()
    assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
    stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
    stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes())
    return inputs, stdout, stderr


def material(rows, supplied, cases, directory):
    assert list(rows) == list(supplied) == list(cases), 'case-membership'
    for identifier, row in rows.items():
        assert supplied[identifier]['source'] == cases[identifier]['source'], 'source-projection'
        for field, payload, suffix in (('module_input', 'emitted', 'pm'), ('handler_input', 'handler', 'handler.pl')):
            record = row[field]
            assert isinstance(record, dict) and record['path'] == str(directory / (identifier + '.' + suffix + '.gz')), 'artifact-path'
            raw = gzip.decompress((ROOT / record['path']).read_bytes())
            assert len(raw) == record['bytes'] and hashlib.sha256(raw).hexdigest() == record['sha256'], 'artifact-identity'
            assert raw.decode() == supplied[identifier][payload], 'artifact-channel'


def validate(rows, targets, profiles, old):
    identifiers = ['target_' + c['id'] for c in targets] + ['policy_' + p['case']['id'] for p in profiles]
    assert list(rows) == identifiers and len(identifiers) == 212, 'case-membership'
    for case in targets:
        identifier = 'target_' + case['id']
        row = rows[identifier]
        assert row['metadata'] == META and row['native_callable'] == 1, 'metadata-readiness'
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error'))
        assert row['host_before'] == row['host_after'], 'host-mutation'
        assert row['native_cursor'] == 0
        if old and identifier in RED:
            assert isinstance(row['native_error'], dict), 'missing-original-error'
            if '_receiver_hash_guard' in identifier:
                assert row['loaded'] == 0 and 'fresh_error' not in row and 'fresh' not in row, 'invented-fresh-execution'
                assert row['native_error']['stage'] == 'rule_handler_compile' and 'syntax error' in row['load_error']
                assert row['warnings']
            else:
                assert row['loaded'] == 1 and row['warnings'] == []
                assert isinstance(row['fresh_error'], dict) and 'Not a HASH reference' in row['native_error']['detail']
                assert 'Not a HASH reference' in row['fresh_error']['detail']
        else:
            assert row['loaded'] == 1 and row['load_error'] is None and row['warnings'] == []
            assert row['fresh_cursor'] == 0
            if case.get('expected_error'):
                for channel, stage in (('native_error', 'rule_handler_eval'), ('fresh_error', 'execute_generated')):
                    error = row[channel]
                    assert isinstance(error, dict) and error['stage'] == stage, 'masked-needed-error'
                    assert case['expected_error'] in error['detail'], 'masked-needed-error'
            else:
                assert row['native_error'] is row['fresh_error'] is None, 'unexpected-error'
                assert same(row['native'], case['expected']) and same(row['fresh'], case['expected']), 'wrong-value-kind'
    for profile in profiles:
        row = rows['policy_' + profile['case']['id']]
        assert same(projection(row), profile['expected_observation']), 'source-policy-drift'
        assert row['host_before'] == row['host_after'], 'host-mutation'
        seed = profile['case'].get('seed')
        if seed:
            assert row['host_before'] == dict(main=['MAIN', 'TAIL', 'END'] if seed == 'main' else [], outer=['OUTER', 'TAIL', 'END'] if seed == 'outer' else []), 'missing-host-seed'


def case_map(targets, profiles):
    return {**{'target_' + c['id']: c for c in targets}, **{'policy_' + p['case']['id']: p['case'] for p in profiles}}


def main():
    captures = {phase: recover(phase) for phase in PHASES}
    before, after = captures['before'][0], captures['after'][0]
    old, new = before[OWNER], after[OWNER]
    git_tar = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'], cwd=ROOT)
    git_names = set()
    with tarfile.open(fileobj=io.BytesIO(git_tar)) as archive:
        for member in archive:
            if member.isdir():
                continue
            assert member.isfile()
            git_names.add(member.name)
            assert before[member.name] == archive.extractfile(member).read(), 'activation-sdk-input'
    assert git_names == {p for p in before if p.startswith(('perl/', 'specs/'))}
    assert gzip.decompress((ROOT / BASE / 'owner-before.pm.gz').read_bytes()) == old
    expected_patch = ''.join(difflib.unified_diff(old.decode().splitlines(True), new.decode().splitlines(True), fromfile=OWNER, tofile=OWNER)).encode()
    assert gzip.decompress((ROOT / BASE / 'source.patch.gz').read_bytes()) == expected_patch
    assert new.count(b'&& !_method_value_is_numeric_literal($target_expr, $deps)') == old.count(b'&& !_method_value_is_numeric_literal($target_expr, $deps)')
    fixture_paths = ('tests/fixtures/array_transform_result_guard_cases.json', 'tests/fixtures/array_transform_result_guard_perl_profiles.json', 'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json')
    targets = json.loads(before[fixture_paths[0]])
    profiles = json.loads(before[fixture_paths[1]]) + json.loads(before[fixture_paths[2]])
    assert len(targets) == 37 and len(profiles) == 175
    maps = case_map(targets, profiles)
    all_rows = {}
    for phase, (inputs, stdout, stderr) in captures.items():
        is_old = phase in ('before', 'private_inverse')
        assert inputs[OWNER] == (old if phase == 'before' else new)
        for path in git_names - {OWNER}:
            assert inputs[path] == before[path], 'unrelated-sdk-drift'
        for path in (*fixture_paths, 't/array_transform_result_guard_composition.t'):
            assert inputs[path] == before[path], 'normal-or-fixture-drift'
        rows = frames(stderr, 'ARRAY_TRANSFORM_COMPOSITION_PERL')
        supplied = frames(stderr, 'ARRAY_TRANSFORM_COMPOSITION_INPUT')
        validate(rows, targets, profiles, is_old)
        material(rows, supplied, maps, BASE / phase)
        all_rows[phase] = rows
        assert (ROOT / BASE / phase / 'exit.txt').read_text() == ('1\n' if is_old else '0\n')
        failures = {s.decode() for s in re.findall(rb'^not ok \d+ - (\S+)', stdout, re.M)}
        assert failures == (RED if is_old else set()), 'actual-tap-failure-set'
        expected_count = 490 if phase == 'direct' else 212
        assert len(re.findall(rb'^(?:not )?ok \d+ - ', stdout, re.M)) == expected_count
        if phase.startswith('private_'):
            lines = [line for line in stderr.splitlines() if line.startswith(b'ARRAY_TRANSFORM_COMPOSITION_OWNER_IMAGE ')]
            assert len(lines) == 1
            image = json.loads(lines[0].split(b' ', 1)[1])
            selected = old if is_old else new
            assert inputs[PRIVATE] == selected and image == dict(path=PRIVATE, bytes=len(selected), sha256=hashlib.sha256(selected).hexdigest()), 'private-image'
    for identifier, row in all_rows['before'].items():
        if identifier not in RED:
            assert same(projection(row), projection(all_rows['after'][identifier])), 'healthy-projection-drift'
    for left, right in (('before', 'private_inverse'), ('after', 'private_restored'), ('after', 'direct')):
        for identifier, row in all_rows[left].items():
            assert same(projection(row), projection(all_rows[right][identifier])), 'private-or-direct-observation-drift'
            for field in ('module_input', 'handler_input'):
                assert row[field]['sha256'] == all_rows[right][identifier][field]['sha256'], 'private-or-direct-artifact-drift'
    direct_inputs, _, direct_stderr = captures['direct']
    locations = json.loads((ROOT / BASE / 'direct/artifact-locations.json').read_bytes())
    for key, prefix, target_fixture, profile_fixture, count in (
        ('source', 'ARRAY_TRANSFORM_SOURCE', 'array_transform_source_isolation_perl_cases.json', 'array_transform_result_guard_perl_profiles.json', 189),
        ('hash', 'HASH_VALUE_COMPOSITION', 'hash_value_result_guard_perl_cases.json', 'hash_value_result_guard_perl_profiles.json', 89),
    ):
        cases = json.loads(direct_inputs['tests/fixtures/' + target_fixture])
        policies = json.loads(direct_inputs['tests/fixtures/' + profile_fixture])
        rows = frames(direct_stderr, prefix + '_PERL')
        supplied = frames(direct_stderr, prefix + '_INPUT')
        assert len(rows) == count
        material(rows, supplied, case_map(cases, policies), Path(locations[key]))
        marker = json.loads((ROOT / locations[key] / 'owner.json').read_bytes())
        assert marker['owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1'
        for profile in policies:
            assert same(projection(rows['policy_' + profile['case']['id']]), profile['expected_observation']), 'direct-source-policy-drift'
        for case in cases:
            row = rows['target_' + case['id']]
            if case.get('expected_error'):
                assert all(case['expected_error'] in row[channel]['detail'] for channel in ('native_error', 'fresh_error'))
            else:
                assert row['native_error'] is row['fresh_error'] is None
                assert same(row['native'], case['expected']) and same(row['fresh'], case['expected']), 'direct-target-drift'
    qualification = json.loads((ROOT / BASE / 'writer-qualification.json').read_bytes())
    original_writer = (ROOT / BASE / 'repair.py').read_bytes()
    qualified_writer = (ROOT / BASE / 'repair_qualified.py').read_bytes()
    assert qualified_writer == original_writer.replace(b"helper = '''", b"helper = r'''", 1)
    assert hashlib.sha256(original_writer).hexdigest() == qualification['original_sha256']
    assert hashlib.sha256(qualified_writer).hexdigest() == qualification['qualified_sha256']
    assert qualification['python_ast_identical'] is True and qualification['qualified_warnings'] == [] and qualification['observed_warning_replay']
    controls = []
    mutations = (
        ('rejection-lost', 'target_take_free_hash_guard', 'native', [{'k': 1}, 'KV'], 'wrong-value-kind'),
        ('with-ran-after-rejection', 'target_take_later_with', 'fresh', [None, 'W'], 'wrong-value-kind'),
        ('masked-needed-error', 'target_needed_source_error_composed', 'native_error', None, 'masked-needed-error'),
        ('healthy-order-drift', 'target_take_compatible', 'native', ['wrong'], 'wrong-value-kind'),
        ('prefix-policy-drift', 'policy_prefix_number_take_main', 'native', None, 'source-policy-drift'),
        ('host-mutation', 'policy_prefix_number_take_main', 'host_after', {}, 'host-mutation'),
    )
    for name, identifier, field, value, reason in mutations:
        changed = copy.deepcopy(all_rows['after'])
        changed[identifier][field] = value
        try:
            validate(changed, targets, profiles, False)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error))
            controls.append(name)
        else:
            raise AssertionError('ineffective-control:' + name)
    changed = copy.deepcopy(all_rows['before'])
    changed['target_take_receiver_hash_guard']['fresh_error'] = None
    try:
        validate(changed, targets, profiles, True)
    except AssertionError as error:
        assert str(error) == 'invented-fresh-execution'
        controls.append('invented-fresh-execution')
    else:
        raise AssertionError('ineffective-unloaded-control')
    print(json.dumps(dict(result='PASS', before='19 selected RED/193 healthy', after='212 PASS', direct='three normals490 PASS',
                          policies='original123 and own52 prefix/arity exact', private='exact old19RED/current212PASS; all212 paired artifacts agree',
                          controls=controls, writer='original warning retained; qualified raw-string source/identical AST record bound',
                          limit='No peer policy, full source/context/native-cache-transitive/toolchain or admission credit'), indent=2))


if __name__ == '__main__':
    main()
