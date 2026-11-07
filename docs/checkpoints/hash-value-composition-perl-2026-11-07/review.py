"""Readonly independent Perl Hash-result guard proof and source preservation."""
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
BASE = Path('docs/checkpoints/hash-value-composition-perl-2026-11-07')
ACTIVATION = '8cf8ae3e129d082f6a30942a4990126e33a045cc'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = str(BASE / 'control-owner.pm')
PHASES = ('before', 'after', 'private_inverse', 'private_restored', 'direct')
SELECTION = Path('docs/checkpoints/hash-value-result-selection-2026-11-07')
selection = runpy.run_path(str(ROOT / SELECTION / 'review.py'))
prior = runpy.run_path(str(ROOT / 'docs/checkpoints/hash-value-result-guard-perl-2026-11-07/review_preflight.py'))
same, projection = selection['same'], prior['projection']
RED = selection['RED']


def frames(raw, prefix):
    found = {}
    for line in raw.decode().splitlines():
        line = line.lstrip(' #\t')
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in found
            found[identifier] = json.loads(body)
    return found


def recover(phase):
    directory = ROOT / BASE / phase
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    found = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in found
            raw = archive.extractfile(member).read()
            expected = identities[member.name]
            assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
            assert member.mode & 0o777 == expected['mode']
            found[member.name] = raw
    assert found.keys() == identities.keys()
    return found


def artifact(identifier, suffix, payload, row, supplied, actual, phase):
    expected = row['module_input' if suffix == 'pm' else 'handler_input']
    assert expected['path'] == str(BASE / phase / (identifier + '.' + suffix + '.gz'))
    assert len(actual) == expected['bytes'] and hashlib.sha256(actual).hexdigest() == expected['sha256']
    assert actual.decode() == supplied[payload]


def validate_target(row, case):
    assert row['native_callable'] == row['loaded'] == 1 and row['warnings'] == []
    assert all(row[k] is None for k in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error', 'load_error'))
    assert row['native_cursor'] == row['fresh_cursor'] == 0
    assert row['metadata'] == dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
        canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
    if case.get('expected_error'):
        assert row['native'] is row['fresh'] is None
        for channel, stage, kind in (('native_error', 'rule_handler_eval', 'runtime_handler'),
                                     ('fresh_error', 'execute_generated', 'generated_source_error')):
            error = row[channel]
            assert isinstance(error, dict) and error['stage'] == stage and error['type'] == kind
            assert error['rule_label'] == 'Value' and case['expected_error'] in error['detail']
        assert row['fresh_error']['code'] == 'generated_execution_failed'
    else:
        assert row['native_error'] is row['fresh_error'] is None
        assert same(row['native'], case['expected']) and same(row['fresh'], case['expected']), case['id']


def validate(rows, cases, profiles, phase, original32):
    identifiers = ['target_' + c['id'] for c in cases] + ['policy_' + p['case']['id'] for p in profiles]
    assert list(rows) == identifiers and len(identifiers) == 89
    old = phase in ('before', 'private_inverse')
    if old:
        selected = {c['id']: rows[('policy_' if c.get('profile_only') else 'target_') + c['id']] for c in original32}
        selection['validate'](selected, original32)
    for case in cases:
        if not old or case['id'] not in RED:
            validate_target(rows['target_' + case['id']], case)
    for profile in profiles:
        assert same(projection(rows['policy_' + profile['case']['id']]), profile['expected_observation']), 'all48 source policies preserved'


def main():
    for path, expected in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
    inputs = {phase: recover(phase) for phase in PHASES}
    body = subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'], cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(body)) as archive:
        baseline = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    original, fixed = inputs['before'][OWNER], inputs['after'][OWNER]
    assert original == baseline[OWNER] and original != fixed
    for phase in PHASES:
        assert {p for p in inputs[phase] if p.startswith(('perl/', 'specs/'))} == set(baseline)
        expected_owner = original if phase == 'before' else fixed
        assert all(inputs[phase][p] == (expected_owner if p == OWNER else raw) for p, raw in baseline.items())
    paths = ['t/hash_value_result_guard_composition.t'] + [str(Path('tests/fixtures') / name) for name in (
        'hash_value_result_guard_cases.json', 'hash_value_result_guard_perl_cases.json', 'hash_value_result_guard_perl_profiles.json')]
    assert all(inputs[phase][p] == inputs['before'][p] for phase in PHASES for p in paths)
    cases = json.loads(inputs['before'][paths[2]])
    profiles = json.loads(inputs['before'][paths[3]])
    assert len(cases) == 41 and len(profiles) == 48
    assert same(cases[:28], json.loads(inputs['before'][paths[1]]))
    original32 = json.loads((ROOT / SELECTION / 'cases.json').read_bytes())
    authored = {'target_' + c['id']: c for c in cases}
    authored.update({'policy_' + p['case']['id']: p['case'] for p in profiles})
    observations, artifacts, summaries = {}, {}, {}
    for phase in PHASES:
        directory = ROOT / BASE / phase
        old = phase in ('before', 'private_inverse')
        assert (directory / 'activation.txt').read_text().strip() == ACTIVATION
        assert (directory / 'exit.txt').read_text() == ('1\n' if old else '0\n')
        stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
        stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes())
        rows, supplied = frames(stderr, 'HASH_VALUE_COMPOSITION_PERL'), frames(stderr, 'HASH_VALUE_COMPOSITION_INPUT')
        validate(rows, cases, profiles, phase, original32)
        assert list(supplied) == list(rows) == list(authored)
        failed = [s.split(' - ', 1)[1] for s in stdout.decode().splitlines() if s.startswith('not ok ')]
        assert failed == (['target_' + c['id'] for c in cases if c['id'] in RED] if old else [])
        assert ('Result: FAIL' if old else 'Result: PASS') in stdout.decode()
        summary = re.search(r'Files=(\d+), Tests=(\d+),', stdout.decode())
        assert summary
        summaries[phase] = dict(files=int(summary[1]), tests=int(summary[2]), failures=len(failed))
        assert summaries[phase]['files'] == (4 if phase == 'direct' else 1)
        assert summaries[phase]['tests'] == (185 if phase == 'direct' else 89)
        artifacts[phase] = {}
        for identifier, case in authored.items():
            assert supplied[identifier]['source'] == case['source']
            for suffix, payload in (('pm', 'emitted'), ('handler.pl', 'handler')):
                actual = gzip.decompress((directory / (identifier + '.' + suffix + '.gz')).read_bytes())
                artifact(identifier, suffix, payload, rows[identifier], supplied[identifier], actual, phase)
                artifacts[phase][identifier, suffix] = actual
        if phase.startswith('private_'):
            image = original if old else fixed
            assert inputs[phase][PRIVATE] == image
            lines = [s.split(' ', 1)[1] for s in stderr.decode().splitlines() if s.startswith('HASH_VALUE_COMPOSITION_OWNER_IMAGE ')]
            assert len(lines) == 1
            assert json.loads(lines[0]) == dict(path=PRIVATE, bytes=len(image), sha256=hashlib.sha256(image).hexdigest())
            assert (ROOT / BASE / (phase + '-wrapper-exit.txt')).read_text() == '0\n'
            assert gzip.decompress((ROOT / BASE / (phase + '-wrapper-stderr.log.gz')).read_bytes()) == b''
        observations[phase] = rows
    assert artifacts['before'] == artifacts['private_inverse'], 'all89 old-source artifacts exact'
    assert artifacts['after'] == artifacts['private_restored'] == artifacts['direct'], 'all89 final artifacts exact'
    healthy = [i for i in authored if not (i.startswith('target_') and i.removeprefix('target_') in RED)]
    assert len(healthy) == 74
    for phase in PHASES:
        assert all(same(projection(observations['before'][i]), projection(observations[phase][i])) for i in healthy)
    for kind in ('source', 'value'):
        for route in ('native_error', 'fresh_error'):
            assert same(observations['after']['target_needed_' + kind + '_error_terminal'][route],
                        observations['after']['target_needed_' + kind + '_error_composed'][route])
    rejected = []

    def reject(name, action):
        try:
            action()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def damage(phase, identifier, action):
        rows = copy.deepcopy(observations[phase])
        action(rows[identifier])
        validate(rows, cases, profiles, phase, original32)

    reject('original failure silently green', lambda: damage('before', 'target_pick_keys_free_array_guard', lambda r: r.update(native=[None, ''])))
    reject('consumer operand or later body ran', lambda: damage('after', 'target_merge_later_with', lambda r: r.update(fresh=[None, 'W'])))
    reject('needed producer error masked', lambda: damage('after', 'target_needed_value_error_composed', lambda r: r.update(native_error=None)))
    reject('initial Array error suppressed', lambda: damage('after', 'target_initial_array_set_key_with', lambda r: r.update(fresh_error=None)))
    reject('initial Number fallback normalized', lambda: damage('after', 'target_initial_number_pick_keys_with', lambda r: r.update(native=[None, ''])))
    reject('Bool became Number', lambda: damage('after', 'target_nested_kinds_and_source', lambda r: r.update(fresh=[0, None, 8, 0, False])))
    lost = copy.deepcopy(observations['after'])
    lost.pop('policy_pick_keys_free_zero_keys_profile')
    reject('missing preservation member', lambda: validate(lost, cases, profiles, 'after', original32))
    identifier = 'target_pick_keys_free_array_guard'
    raw = artifacts['after'][identifier, 'handler.pl']
    reject('actual handler drift', lambda: artifact(identifier, 'handler.pl', 'handler', observations['after'][identifier],
           {'handler': raw.decode()}, raw + b'\n', 'after'))
    return dict(normal_groups=89, unchanged_shared_targets=28, own_added_targets=13, preserved_policy_groups=48,
                original_failures=15, healthy_public_projections_exact=74, phase_summaries=summaries,
                artifact_pairs_per_phase=89, evidence_corruptions=rejected,
                scope='finite ordinary Perl Hash-result guards; exact old/current private-image control, source0 barriers preserved; no peer/context/registered receiver/domain/arity/native custody or full23.4 admission')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2, sort_keys=True))
