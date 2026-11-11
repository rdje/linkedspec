"""Independent readonly recovery of acquired policies and bounded valid-result intents."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
ACTIVATION = '51e1eb3522d2e7b963841be4388144437265ac44'
META = {'language_agnostic_action_ir_ready', 'raw_perl_dependency_count', 'canonical_action_ir_fallback_count',
        'unresolved_helper_count', 'unresolved_helpers'}


def sha(raw): return hashlib.sha256(raw).hexdigest()


def wire(value): return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(raw):
    rows, inputs = {}, {}
    for line in raw.decode().splitlines():
        if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
        elif line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_INPUT '):
            _, key, value = line.split(' ', 2)
            assert key not in inputs
            inputs[key] = json.loads(value)
    return rows, inputs


def matches(row, desired):
    m = row['metadata']
    if m['language_agnostic_action_ir_ready'] != 1 or any(m[name] != 0 for name in
        ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')) or m['unresolved_helpers']:
        return False
    for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row.get(usable) != 1 or route not in row: return False
        error = row.get(route + '_error')
        if desired['kind'] == 'value':
            if error or wire(row[route]) != wire(desired['value']): return False
        elif not error or desired['code'] not in wire(error) or (desired.get('identifier') and 'identifier=' + desired['identifier'] not in wire(error)):
            return False
    return True


def semantics(rows, policy):
    assert len(policy['targets']) == 35 and len(policy['healthy_intents']) == 74
    assert len(policy['protected_records']) == 253
    assert set(rows) == set(policy['targets']) | set(policy['protected_records']), 'policy population'
    assert not set(policy['targets']) & set(policy['protected_records'])
    assert all(not matches(rows[key], value) for key, value in policy['targets'].items()), 'actual result target boundary'
    assert all(matches(rows[key], value) for key, value in policy['healthy_intents'].items()), 'healthy contract intent'
    for key in ('take_later_with', 'own_signature_variadic_empty_composed'):
        row = rows[key]
        assert row['metadata']['language_agnostic_action_ir_ready'] == 0, 'readiness hidden by values'
        assert row['native'] == row['fresh'] == [None, ''] and not row['native_error'] and not row['fresh_error']
    for key in ('own_extra_take_receiver_terminal_probe', 'own_extra_sorted_receiver_terminal_probe'):
        row = rows[key]
        assert row['metadata']['language_agnostic_action_ir_ready'] == 1 and not row['metadata']['unresolved_helpers'], 'excluded null-fold policy'
        assert row['native'] == row['fresh'] == [None, ''] and not row['native_error'] and not row['fresh_error']
        assert key in policy['protected_records'], 'excluded shape promoted'
    for key in ('own_initial_number_sorted_receiver', 'own_initial_hash_sorted_receiver',
                'own_initial_number_reversed_receiver', 'own_initial_hash_reversed_receiver'):
        assert 'binding_kind_mismatch' in wire(rows[key]['native_error']) and '<receiver>' in wire(rows[key]['native_error']), 'receiver source policy'
    for key in ('own_function_arity_missing_terminal', 'own_function_arity_extra_terminal'):
        row = rows[key]
        assert row['metadata']['language_agnostic_action_ir_ready'] == 0 and row['metadata']['unresolved_helpers'] == ['supply'], 'fixed signature rejection'


def full_binding(rows, raw_rows):
    assert rows == raw_rows, 'full raw record binding'


def artifact_binding(cases, rows, inputs):
    assert set(rows) == set(inputs) == {case['id'] for case in cases}, 'question/source population'
    for case in cases:
        key = case['id']
        assert inputs[key]['source'] == case['source'], 'authored source binding'
        assert set(rows[key]['metadata']) == META, 'five metadata fields'
        for field, source_field in (('module_input', 'emitted'), ('handler_input', 'handler')):
            row, source = rows[key][field], inputs[key][source_field]
            assert row is not None and source is not None, 'actual pair presence'
            raw = source.encode()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'artifact input identity'
            assert gzip.decompress((ROOT / row['path']).read_bytes()) == raw, 'artifact bytes'


def check_command(row, argv):
    assert row['command'] == dict(argv=argv, cwd='.'), 'physical command'
    assert row['exit'] == '0\n' and row['stderr'] == b'', 'actual exit/channels'


def channels(folder, tag):
    return dict(command=json.loads((folder / (tag + '-command.json')).read_bytes()),
        exit=(folder / (tag + '-exit.txt')).read_text(),
        stdout=gzip.decompress((folder / (tag + '-stdout.log.gz')).read_bytes()),
        stderr=gzip.decompress((folder / (tag + '-stderr.log.gz')).read_bytes()))


def inputs_and_commands(phase):
    folder = HERE / phase
    ids = json.loads((folder / 'input-identities.json').read_bytes())
    assert (folder / 'activation.txt').read_text().strip() == ACTIVATION
    with tarfile.open(folder / 'inputs-before-first-run.tar.gz') as archive:
        assert set(archive.getnames()) == set(ids), 'archive population'
        for member in archive:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            raw = archive.extractfile(member).read()
            row = ids[member.name]
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'archive byte identity'
            assert member.mode & 0o777 == row['mode'], 'archive full mode'
            if member.name.startswith(('perl/', 'specs/')):
                assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + member.name], cwd=ROOT), 'unchanged own SDK'
    check_command(channels(folder, 'version'), ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'])
    script, fixture = ('observer.pl', 'cases.json') if phase == 'intake' else ('terminal_observer.pl', 'terminal-cases.json')
    check_command(channels(folder, 'observer'), ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
        str(BASE / script), str(BASE / fixture), str(BASE / phase)])


def producer_images():
    for path in HERE.glob('*-producer-images.json.gz'):
        for name, row in json.loads(gzip.decompress(path.read_bytes())).items():
            raw = base64.b64decode(row['base64'], validate=True)
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'producer image'
            assert (ROOT / name).read_bytes() == raw, 'producer changed'
            assert (ROOT / name).stat().st_mode & 0o777 == row['mode'], 'producer mode'


def controls(rows, policy, raw_rows, cases, inputs, physical):
    rejected = []

    def red(label, action, reason):
        try: action()
        except AssertionError as error:
            assert str(error) == reason, (label, str(error), reason)
            rejected.append(dict(control=label, observed_red=reason))
        else: raise AssertionError('ineffective control: ' + label)

    changed = copy.deepcopy(rows)
    changed['take_later_with']['metadata'].update(language_agnostic_action_ir_ready=1, unresolved_helper_count=0, unresolved_helpers=[])
    red('hide-readiness-only', lambda: semantics(changed, policy), 'actual result target boundary')
    changed = copy.deepcopy(rows)
    changed['own_extra_take_receiver_terminal_probe']['metadata']['language_agnostic_action_ir_ready'] = 0
    red('normalize-excluded-null-policy', lambda: semantics(changed, policy), 'excluded null-fold policy')
    changed = copy.deepcopy(rows)
    changed['own_initial_number_sorted_receiver']['native_error'] = None
    red('normalize-sorted-source-error', lambda: semantics(changed, policy), 'receiver source policy')
    changed = copy.deepcopy(rows)
    changed['own_function_arity_missing_terminal']['metadata']['unresolved_helpers'] = []
    red('admit-invalid-function-signature', lambda: semantics(changed, policy), 'fixed signature rejection')
    changed = copy.deepcopy(rows)
    changed['own_needed_count_take_free_terminal_probe']['native_error'] = None
    red('mask-needed-terminal-error', lambda: semantics(changed, policy), 'healthy contract intent')
    changed = copy.deepcopy(rows)
    changed['take_compatible']['native'] = []
    red('wrong-healthy-value', lambda: semantics(changed, policy), 'healthy contract intent')
    changed = copy.deepcopy(rows)
    changed['own_initial_hash_sorted_receiver']['native_error']['detail'] += ' altered'
    red('changed-full-error-field', lambda: full_binding(changed, raw_rows), 'full raw record binding')
    changed = copy.deepcopy(rows)
    changed['take_receiver_hash_guard']['fresh'] = None
    red('invent-fresh-after-failed-load', lambda: full_binding(changed, raw_rows), 'full raw record binding')
    changed = copy.deepcopy(rows)
    del changed['source_once']
    red('missing-question', lambda: semantics(changed, policy), 'policy population')
    changed_inputs = copy.deepcopy(inputs)
    changed_inputs['take_compatible']['handler'] += ' changed'
    red('handler-source-byte', lambda: artifact_binding(cases, rows, changed_inputs), 'artifact input identity')
    changed_cases = copy.deepcopy(cases)
    changed_cases[0]['source'] += ' changed'
    red('authored-source-byte', lambda: artifact_binding(changed_cases, rows, inputs), 'authored source binding')
    changed = copy.deepcopy(physical)
    changed['exit'] = '1\n'
    red('wrong-actual-exit', lambda: check_command(changed, physical['command']['argv']), 'actual exit/channels')
    changed = copy.deepcopy(physical)
    changed['command']['argv'][-1] = 'wrong-output'
    red('wrong-physical-command', lambda: check_command(changed, physical['command']['argv']), 'physical command')
    return rejected


def review():
    seal = json.loads((HERE / 'sealed-identities.json').read_bytes())
    for name, row in seal.items():
        path = ROOT / name
        raw = path.read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'sealed input identity'
        assert path.stat().st_mode & 0o777 == row['mode'], 'sealed input mode'
    producer_images()
    all_cases, all_rows, all_inputs = [], {}, {}
    for phase, fixture, observed, recorded_inputs in (
        ('intake', 'cases.json', 'observations.json', 'input-records.json'),
        ('terminal', 'terminal-cases.json', 'terminal-observations.json', 'terminal-input-records.json')):
        inputs_and_commands(phase)
        cases = json.loads((HERE / fixture).read_bytes())
        rows, inputs = frames(channels(HERE / phase, 'observer')['stdout'])
        full_binding(json.loads((HERE / observed).read_bytes()), rows)
        assert inputs == json.loads((HERE / recorded_inputs).read_bytes())
        artifact_binding(cases, rows, inputs)
        assert not set(all_rows) & set(rows)
        all_cases += cases
        all_rows.update(rows)
        all_inputs.update(inputs)
    shared = json.loads((ROOT / 'tests/fixtures/array_transform_callable_result_guard_cases.json').read_bytes())
    assert all_cases[:45] == shared, 'unchanged shared45'
    assert len(all_cases) == len(all_rows) == 288
    policy = json.loads((HERE / 'policy-contract.json').read_bytes())
    semantics(all_rows, policy)
    rejected = controls(all_rows, policy, all_rows, all_cases, all_inputs, channels(HERE / 'intake', 'observer'))
    return dict(result='PASS', original_questions=240, terminal_questions=48, actual_source_pairs=288,
        valid_result_targets=35, healthy_contract_intents=74, protected_observations=253, rejected_controls=rejected,
        limits='Finite acquired compatibility, not profile semantic PASS or portable initial/invalid-shape policy. Receiver null-fold/free-diagnostic reconciliation1.2.1.4.3, open concat selection42, literal policy1.2.1.3.1 and complete native/cache/transitive/toolchain/OS custody4.2/SESSION5 remain open. Direct intent-freeze composition retains combined exec observation without original separated channels.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
