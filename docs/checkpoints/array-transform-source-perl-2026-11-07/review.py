"""Readonly exact source, public native/fresh and private-image regression proof."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-source-perl-2026-11-07')
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = str(BASE / 'control-owner.pm')
ACTIVATION = 'df9dc784e368a66f16238caaa41142a649dde4dd'
PHASES = ('before', 'after', 'private_inverse', 'private_restored')
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
FIELDS = ('metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings').split()
ROLES = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
RED = {'target_literal_number_' + name + '_' + route + '_main' for name in ROLES for route in ('free', 'receiver')}


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
    stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes())
    rows = frames(stderr, 'ARRAY_TRANSFORM_SOURCE_PERL')
    supplied = frames(stderr, 'ARRAY_TRANSFORM_SOURCE_INPUT')
    assert list(rows) == list(supplied) and len(rows) == 189, 'case-membership'
    for identifier, row in rows.items():
        for field, payload, suffix in (('module_input', 'emitted', 'pm'), ('handler_input', 'handler', 'handler.pl')):
            artifact = row[field]
            assert artifact['path'] == str(BASE / phase / (identifier + '.' + suffix + '.gz'))
            raw = gzip.decompress((ROOT / artifact['path']).read_bytes())
            assert len(raw) == artifact['bytes'] and hashlib.sha256(raw).hexdigest() == artifact['sha256'], 'artifact-identity'
            assert raw.decode() == supplied[identifier][payload], 'artifact-channel'
    return inputs, rows, supplied, stderr


def validate(rows, cases, profiles, old):
    expected = ['target_' + c['id'] for c in cases] + ['policy_' + p['case']['id'] for p in profiles]
    assert list(rows) == expected and len(expected) == 189, 'case-membership'
    for case in cases:
        identifier = 'target_' + case['id']
        row = rows[identifier]
        assert row['metadata'] == META and row['native_callable'] == row['loaded'] == 1, 'metadata-readiness'
        assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error', 'load_error'))
        assert row['warnings'] == [] and row['native_cursor'] == row['fresh_cursor'] == 0
        assert same(row['host_before'], row['host_after']), 'host-mutation'
        if case.get('expected_error'):
            for route, stage in (('native', 'rule_handler_eval'), ('fresh', 'execute_generated')):
                error = row[route + '_error']
                assert isinstance(error, dict) and error['stage'] == stage, 'masked-needed-error'
                assert case['expected_error'] in error['detail'], 'masked-needed-error'
        else:
            assert row['native_error'] is row['fresh_error'] is None, 'unexpected-error'
            if old and identifier in RED:
                assert row['native'] != case['expected'] and row['native'] == row['fresh'] and '@3' in row['substitution'], 'hidden-original-host-read'
            else:
                assert same(row['native'], case['expected']) and same(row['fresh'], case['expected']), 'wrong-value-kind'
                if 'seed' in case and not old:
                    assert '@3' not in row['substitution'], 'numeric-shortcut-remains'
    for profile in profiles:
        assert same(projection(rows['policy_' + profile['case']['id']]), profile['expected_observation']), 'source-policy-drift'


def main():
    capsules = {phase: recover(phase) for phase in PHASES}
    before, after = capsules['before'][0], capsules['after'][0]
    old, new = before[OWNER], after[OWNER]
    assert old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    pattern = rb'\$array_symbol_expr_re\n +&& !_method_value_is_numeric_literal\(\$target_expr, \$deps\)\) \{'
    restored, count = re.subn(pattern, b'$array_symbol_expr_re) {', new)
    assert count == 8 and restored == old, 'bounded-eight-site-source'
    assert gzip.decompress((ROOT / BASE / 'owner-before.pm.gz').read_bytes()) == old
    cases = json.loads(before['tests/fixtures/array_transform_source_isolation_perl_cases.json'])
    profiles = json.loads(before['tests/fixtures/array_transform_result_guard_perl_profiles.json'])
    assert len(cases) == 66 and len(profiles) == 123
    for phase, (inputs, rows, supplied, stderr) in capsules.items():
        is_old = phase in ('before', 'private_inverse')
        assert inputs[OWNER] == (old if phase == 'before' else new)
        for path in before:
            if path.startswith(('perl/', 'specs/')) and path != OWNER:
                assert inputs[path] == before[path], 'unrelated-sdk-drift'
        for path in ('t/array_transform_source_isolation.t', 'tests/fixtures/array_transform_source_isolation_perl_cases.json', 'tests/fixtures/array_transform_result_guard_perl_profiles.json'):
            assert inputs[path] == before[path], 'normal-or-fixture-drift'
        validate(rows, cases, profiles, is_old)
        stdout = gzip.decompress((ROOT / BASE / phase / 'stdout.log.gz').read_bytes())
        failures = {s.decode() for s in re.findall(rb'^not ok \d+ - (\S+)', stdout, re.M)}
        assert failures == (RED if is_old else set()), 'actual-tap-failure-set'
        assert len(re.findall(rb'^(?:not )?ok \d+ - ', stdout, re.M)) == 189 and b'1..189' in stdout
        assert (ROOT / BASE / phase / 'exit.txt').read_text() == ('1\n' if is_old else '0\n')
        if phase.startswith('private_'):
            image_lines = [line for line in stderr.splitlines() if line.startswith(b'ARRAY_TRANSFORM_SOURCE_OWNER_IMAGE ')]
            assert len(image_lines) == 1, 'missing-private-image'
            image = json.loads(image_lines[0].split(b' ', 1)[1])
            selected = old if is_old else new
            assert inputs[PRIVATE] == selected and image == dict(path=PRIVATE, bytes=len(selected), sha256=hashlib.sha256(selected).hexdigest()), 'wrong-private-image'
        for case in cases:
            assert supplied['target_' + case['id']]['source'] == case['source']
    for identifier, row in capsules['before'][1].items():
        if identifier not in RED:
            assert same(projection(row), projection(capsules['after'][1][identifier])), 'healthy-projection-drift'
    for left, right in (('before', 'private_inverse'), ('after', 'private_restored')):
        for identifier, row in capsules[left][1].items():
            assert same(projection(row), projection(capsules[right][1][identifier])), 'private-observation-drift'
            for field in ('module_input', 'handler_input'):
                assert row[field]['sha256'] == capsules[right][1][identifier][field]['sha256'], 'private-artifact-drift'
    controls = []
    sample = capsules['after'][1]
    mutations = (
        ('host-read-restored', 'target_literal_number_take_free_main', 'native', ['MAIN'], 'wrong-value-kind'),
        ('host-mutation', 'target_literal_number_take_free_main', 'host_after', {}, 'host-mutation'),
        ('masked-needed-error', 'target_needed_source_error_composed', 'native_error', None, 'masked-needed-error'),
        ('healthy-order-drift', 'target_take_compatible', 'native', ['wrong'], 'wrong-value-kind'),
        ('policy-drift', 'policy_optional_take_free', 'native', [], 'source-policy-drift'),
        ('invented-readiness', 'target_literal_number_sorted_free_main', 'loaded', 0, 'metadata-readiness'),
    )
    for name, identifier, field, value, reason in mutations:
        changed = copy.deepcopy(sample)
        changed[identifier][field] = value
        try:
            validate(changed, cases, profiles, False)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error))
            controls.append(name)
        else:
            raise AssertionError('ineffective-control:' + name)
    print(json.dumps(dict(result='PASS', before='16 main-only host RED/173 healthy', after='189 PASS',
                          source='eight existing Number-AST fences only', policies='own123 exact',
                          private='exact old16RED/current189PASS; all module/handler pairs match', controls=controls,
                          limit='No Array result-guard completion or full source/context/native-transitive admission'), indent=2))


if __name__ == '__main__':
    main()
