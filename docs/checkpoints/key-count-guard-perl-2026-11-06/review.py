"""Readonly recovery of original, calibrated and repaired CountKeys guard epochs."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
ACTIVATION = '6a0667cd54be4471f855357776a9947d46e6d226'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = 't/key_count_result_guard_composition.t'
SHARED = 'tests/fixtures/key_count_result_guard_cases.json'
LOCAL = 'tests/fixtures/key_count_perl_source_owner_cases.json'
PROFILES = 'tests/fixtures/key_count_perl_source_profiles.json'
RED = {'key_count_free_guard', 'key_count_receiver_guard', 'function_guard',
       'copy_guard', 'logical_guard', 'seeded_hash', 'count_contrast',
       'free_keys_count', 'receiver_keys_count', 'keys_count_with',
       'keys_count_copy_logical', 'produced_zero_keys', 'initial_scalar_continuations'}
PHASES = ('intake', 'function-controls', 'before', 'before-qualified', 'after', 'nearest')


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def raw(path):
    return gzip.decompress(Path(str(ROOT / path) + '.gz').read_bytes())


def recover(phase):
    folder = BASE / phase
    records = json.loads((folder / 'input-identities.json').read_text())
    name = 'inputs-before-first-get.tar.gz' if phase in PHASES[:2] else 'inputs-before-first-run.tar.gz'
    bodies = {}
    with tarfile.open(folder / name) as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in bodies
            body = archive.extractfile(member).read()
            item = records[member.name]
            assert digest(body) == item['sha256'] and len(body) == item['bytes']
            assert member.mode & 0o777 == item['mode']
            bodies[member.name] = body
    assert bodies.keys() == records.keys()
    assert (folder / 'activation.txt').read_text().strip() == ACTIVATION
    return bodies


def frame(phase, count):
    frames = []
    for line in raw(BASE / phase / 'stdout.log').decode().splitlines():
        try:
            value = json.loads(line)
        except ValueError:
            continue
        if isinstance(value, list) and len(value) == count and all(isinstance(r, dict) and 'id' in r for r in value):
            frames.append(value)
    assert len(frames) == 1, 'one complete actual frame after any retained Trace'
    return frames[0]


def observations(phase):
    rows = {}
    for line in raw(BASE / phase / 'normal-stderr.log').decode().splitlines():
        prefix = '# KEY_COUNT_GUARD_ACTUAL '
        line = line.lstrip()
        if line.startswith(prefix):
            name, body = line[len(prefix):].split(' ', 1)
            assert name not in rows
            rows[name] = json.loads(body)
    return rows


def cases(inputs):
    rows = json.loads(inputs[SHARED]) + json.loads(inputs[LOCAL])
    profile = json.loads(inputs[PROFILES])
    for row in rows:
        if row['id'] == 'source_domain':
            row['expected'] = profile['source_domain']
        if row['id'] == 'seeded_hash':
            row['seed_namespace'] = '2'
    return rows


def target(case, row):
    if not row['native_callable'] or not row['loaded'] or row['warnings']:
        return False
    if any(row[k] for k in ('build_error', 'emission_error', 'load_error', 'descriptor_error')):
        return False
    meta = row['metadata']
    expected_unresolved = case.get('expected_unresolved', [])
    if any(meta[k] for k in ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count')):
        return False
    if meta['unresolved_helper_count'] != len(expected_unresolved) or meta['unresolved_helpers'] != expected_unresolved:
        return False
    if meta['language_agnostic_action_ir_ready'] != (0 if expected_unresolved else 1):
        return False
    for route in ('native', 'fresh'):
        error = row[route + '_error']
        if case.get('expected_error'):
            if not isinstance(error, dict) or case['expected_error'] not in error.get('detail', ''):
                return False
            if error.get('stage') != ('rule_handler_eval' if route == 'native' else 'execute_generated') or row[route] is not None:
                return False
        elif error or not same(row[route], case['expected']):
            return False
        if row[route + '_cursor'] != 0:
            return False
    if case.get('seed_namespace'):
        seeds = row['seeds']
        if seeds['lowering_error'] or seeds['carrier_error']:
            return False
        if [(r['route'], r['seed']) for r in seeds['rows']] != [(route, seed) for route in ('public', 'fresh') for seed in ('empty', 'outer', 'main')]:
            return False
        for item in seeds['rows']:
            host = dict(outer={'outer': 'OUTER'} if item['seed'] == 'outer' else {}, main={'main': 'MAIN'} if item['seed'] == 'main' else {})
            if item['value'] is not None or item['error'] or item['warnings'] or item['host_before'] != host or item['host_after'] != host:
                return False
    return True


def validate(rows, authored, failing):
    assert list(rows) == [c['id'] for c in authored], 'complete ordered observations'
    assert {c['id'] for c in authored if not target(c, rows[c['id']])} == failing, 'exact authored values/kinds/effects/profiles'


def apply_patch(before, patch):
    lines = patch.decode().splitlines(keepends=True)
    assert lines[:4] == [f'diff --git a/{OWNER} b/{OWNER}\n', lines[1], f'--- a/{OWNER}\n', f'+++ b/{OWNER}\n']
    assert re.fullmatch(r'index [0-9a-f]{40}\.\.[0-9a-f]{40} 100644\n', lines[1])
    original = before.decode().splitlines(keepends=True)
    result = []
    cursor = 0
    index = 4
    while index < len(lines):
        match = re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@', lines[index])
        assert match, 'retained single-owner unified diff'
        start = int(match[1]) - 1
        assert cursor <= start
        result.extend(original[cursor:start]); cursor = start
        old_count = new_count = 0
        index += 1
        while index < len(lines) and not lines[index].startswith('@@ '):
            line = lines[index]; index += 1
            assert line[0] in ' +-'
            if line[0] in ' -':
                assert original[cursor] == line[1:]
                cursor += 1; old_count += 1
            if line[0] in ' +':
                result.append(line[1:]); new_count += 1
        assert old_count == int(match[2] or 1) and new_count == int(match[4] or 1)
    result.extend(original[cursor:])
    return ''.join(result).encode()


def source_boundary(before, after):
    assert before == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER]), 'actual historical Git source'
    assert apply_patch(before, (BASE / 'producer-change.patch').read_bytes()) == after


def check_modules(bodies, frames):
    assert bodies.keys() == frames.keys()
    assert all(bodies[k] == frames[k] for k in bodies), 'actual persisted module/carrier matches pre-execution producer frame'


def modules(phase):
    records = json.loads((BASE / phase / 'module-identities.json').read_text())
    bodies = {}
    for name, item in records.items():
        path = ROOT / name
        capsule = path.read_bytes(); body = gzip.decompress(capsule)
        assert digest(capsule) == item['sha256'] and path.stat().st_mode & 0o777 == item['mode']
        assert digest(body) == item['raw_sha256'] and len(body) == item['raw_bytes']
        bodies[path.name] = body
    return bodies


def normal_frames(phase, authored):
    frames = {}
    for line in raw(BASE / phase / 'normal-stdout.log').decode().splitlines():
        line = line.strip()
        for tag, prefix, suffix, field in [('KEY_COUNT_GUARD_INPUT ', 'module-', '.pm.gz', 'emitted'), ('KEY_COUNT_GUARD_PUBLIC ', 'public-', '.pl.gz', 'carrier')]:
            if line.startswith(tag):
                number, body = line[len(tag):].split(' ', 1)
                name = prefix + number + suffix
                assert name not in frames
                payload = json.loads(body)
                if field == 'emitted':
                    assert payload['source'] == authored[int(number) - 1]['source']
                else:
                    assert authored[int(number) - 1]['id'] == 'seeded_hash'
                frames[name] = payload[field].encode()
    return frames


def main():
    epochs = {p: recover(p) for p in PHASES}
    baseline = epochs['before-qualified']
    authored = cases(baseline)
    assert len(authored) == 26 and len({r['id'] for r in authored}) == 26
    assert all(e[SHARED] == baseline[SHARED] for e in epochs.values())
    assert baseline[SHARED] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + SHARED])
    assert all(epochs[p][OWNER] == baseline[OWNER] for p in ('intake', 'function-controls', 'before'))
    source_boundary(baseline[OWNER], epochs['after'][OWNER])
    assert epochs['after'][OWNER] == epochs['nearest'][OWNER]
    for phase in ('after', 'nearest'):
        assert epochs[phase].keys() == baseline.keys()
        assert all(body == baseline[name] for name, body in epochs[phase].items() if name != OWNER)
    assert epochs['before'][NORMAL] == baseline[NORMAL]
    original_cases = cases(epochs['before'])
    corrected_cases = copy.deepcopy(original_cases)
    corrected_cases[24]['expected_unresolved'] = ['count_keys']
    assert corrected_cases == authored, 'only the actual descriptor name changes after first normal'
    original_profile = json.loads(epochs['before'][PROFILES])
    original_profile['function_initial_source']['expected_unresolved'] = ['count_keys']
    assert original_profile == json.loads(baseline[PROFILES])
    intake = frame('intake', 26)
    intake_cases = json.loads(epochs['intake'][str(BASE / 'intake-cases.json')])
    assert intake_cases == json.loads(baseline[SHARED]) + json.loads(epochs['intake'][LOCAL])
    assert intake_cases[24]['expected'] == 1, 'original overbroad function-source hypothesis retained'
    observations_by_phase = {p: observations(p) for p in PHASES[2:]}
    validate(observations_by_phase['before'], original_cases, RED | {'function_initial_source'})
    validate(observations_by_phase['before-qualified'], authored, RED)
    validate(observations_by_phase['after'], authored, set())
    validate(observations_by_phase['nearest'], authored, set())
    assert same(observations_by_phase['before'], observations_by_phase['before-qualified'])
    assert same(observations_by_phase['after'], observations_by_phase['nearest'])
    healthy = [r['id'] for r in authored if r['id'] not in RED]
    assert len(healthy) == 13
    assert all(same(observations_by_phase['before-qualified'][k], observations_by_phase['after'][k]) for k in healthy)
    expected_domain = [0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 2]
    assert same(json.loads(baseline[PROFILES])['source_domain'], expected_domain)
    for row, case in zip(intake, intake_cases):
        assert row['id'] == case['id'] and row['source'] == case['source']
        original = observations_by_phase['before-qualified'][row['id']]
        assert same(row['native'], original['native']) and same(row['fresh'], original['fresh'])
        assert all(same(value, original['metadata'][key]) for key, value in row['metadata'].items())
        assert not row['warnings'] and row['loaded'] and row['native_callable']
        if row['id'] != 'needed_source_error':
            assert not row['native_error'] and not row['fresh_error']
    functions = frame('function-controls', 4)
    controls = json.loads(epochs['function-controls'][str(BASE / 'function-controls.json')])
    for row, case in zip(functions, controls):
        assert row['id'] == case['id'] and row['source'] == case['source']
        assert same(row['native'], case['expected']) and same(row['fresh'], case['expected'])
        assert row['native_callable'] and row['loaded'] and not row['warnings']
        assert not any(row[k] for k in ('native_build_error', 'native_error', 'emission_error', 'load_error', 'fresh_error', 'descriptor_error'))
        assert row['metadata']['language_agnostic_action_ir_ready'] == 1
        assert not any(row['metadata'][k] for k in ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count'))
    for phase, rows in [('intake', intake), ('function-controls', functions)]:
        assert (BASE / phase / 'exit.txt').read_text().strip() == '0'
        bodies = modules(phase)
        assert len(bodies) == len(rows)
        check_modules(bodies, {r['id'] + '.pm.gz': r['emitted_before_load'].encode() for r in rows})
    for phase in PHASES[2:]:
        assert int((BASE / phase / 'normal-exit.txt').read_text()) == (1 if phase.startswith('before') else 0)
        output = raw(BASE / phase / 'normal-stdout.log').decode()
        assert ('Tests=71' if phase == 'nearest' else 'Tests=26') in output
        bodies = modules(phase)
        assert len(bodies) == 27
        frames = normal_frames(phase, authored)
        check_modules(bodies, frames)
    assert modules('before') == modules('before-qualified'), 'metadata calibration never changes emitted code'
    assert (BASE / 'after/owner-syntax-exit.txt').read_text().strip() == '0'
    records = json.loads((BASE / 'raw-identities.json').read_text())
    assert len(records) == 14
    for name, item in records.items():
        capsule = (ROOT / item['capsule']).read_bytes()
        body = raw(Path(name))
        assert digest(capsule) == item['capsule_sha256'] and digest(body) == item['sha256'] and len(body) == item['bytes']
    rejected = []

    def rejects(name, operation):
        try:
            operation()
        except (AssertionError, KeyError, ValueError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective control ' + name)

    rows = copy.deepcopy(observations_by_phase['after']); rows.pop('source_domain')
    rejects('missing-row', lambda: validate(rows, authored, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['source_domain']['native'][0] = False
    rejects('false-as-number', lambda: validate(rows, authored, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['key_count_receiver_guard']['native'][1] = 'SW'
    rejects('post-rejection-effect', lambda: validate(rows, authored, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['seeded_hash']['seeds']['rows'][2]['value'] = {'k': 1, 'main': 'MAIN'}
    rejects('numeric-host-read', lambda: validate(rows, authored, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['function_initial_source']['metadata']['language_agnostic_action_ir_ready'] = 1
    rejects('excluded-function-promotion', lambda: validate(rows, authored, set()))
    changed = dict(bodies); changed['module-1.pm.gz'] += b'\n'
    rejects('changed-module', lambda: check_modules(changed, frames))
    rejects('forged-source-boundary', lambda: source_boundary(baseline[OWNER] + b'\n', epochs['after'][OWNER]))
    print(json.dumps(dict(original='12PASS/14RED including metadata-label error', qualified='13PASS/13RED', after='26PASS:25ready/1excluded', nearest='71PASS', healthy_exact=13, localized_seed_rows=6, rejected_controls=rejected, result='PASS'), sort_keys=True))


if __name__ == '__main__':
    main()
