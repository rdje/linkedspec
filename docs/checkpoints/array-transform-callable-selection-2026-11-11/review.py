"""Independent readonly recovery of original44, qualified45 and their full inputs."""
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
ACTIVATION = 'e29638a99224be51fe454a1935a428c2a1a9a270'
META = {'language_agnostic_action_ir_ready', 'raw_perl_dependency_count',
        'canonical_action_ir_fallback_count', 'unresolved_helper_count', 'unresolved_helpers'}
RECEIVERS = {name + '_receiver_hash_guard' for name in
    ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')}
TARGETS = RECEIVERS | {'take_later_with', 'reverse_copy_later_with', 'drop_logical_later_with',
                     'needed_count_composed', 'source_effect_before_rejection'}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(raw):
    rows, inputs = {}, {}
    for line in raw.decode().splitlines():
        if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows, 'duplicate record'
            rows[key] = json.loads(value)
        elif line.startswith('ARRAY_TRANSFORM_CALLABLE_INPUT '):
            _, key, value = line.split(' ', 2)
            assert key not in inputs, 'duplicate input'
            inputs[key] = json.loads(value)
    return rows, inputs


def ready(row):
    m = row['metadata']
    return m['language_agnostic_action_ir_ready'] == 1 and all(m[name] == 0 for name in
        ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')) and not m['unresolved_helpers']


def semantics(cases, rows):
    assert set(rows) == {case['id'] for case in cases}, 'question population'
    for case in cases:
        key = case['id']
        row = rows[key]
        assert set(row['metadata']) == META, 'metadata field scope'
        if case.get('profile_only'):
            continue
        if key in RECEIVERS | {'drop_logical_later_with', 'needed_count_composed'}:
            assert ready(row), 'actual compile-target readiness'
            assert row['native_callable'] == 1 and row['native_error']['stage'] == 'rule_handler_compile', 'actual handler compile error'
            assert not row['loaded'] and 'fresh' not in row and 'fresh_error' not in row, 'failed-load field absence'
            assert 'syntax error' in row['load_error'], 'actual module compile error'
        elif key in {'take_later_with', 'reverse_copy_later_with', 'source_effect_before_rejection'}:
            assert not ready(row), 'actual readiness-only boundary'
            expected_helper = 'copy' if key == 'reverse_copy_later_with' else 'with'
            assert row['metadata']['unresolved_helpers'] == [expected_helper], 'actual unresolved helper'
            expected = ['ran', 'W'] if key == 'reverse_copy_later_with' else [None, '']
            for route in ('native', 'fresh'):
                assert not row[route + '_error'], 'actual tail error absence'
                assert wire(row[route]) == wire(expected), 'actual tail/source effects'
        else:
            assert key not in TARGETS and ready(row), 'healthy readiness'
            for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
                assert row[usable] == 1 and route in row, 'healthy route presence'
                error = row[route + '_error']
                if 'expected_error' in case:
                    assert error and case['expected_error'] in wire(error), 'healthy needed error'
                else:
                    assert not error and wire(row[route]) == wire(case['expected']), 'healthy value/error'


def qualification(original, qualified):
    assert len(original) == 44 and len(qualified) == 45, 'question lengths'
    for old, new in zip(original, qualified):
        expected = copy.deepcopy(old)
        if old['id'] == 'constructor_rejection_oracle':
            assert expected.pop('expected') == [None, ''], 'original unsupported expectation'
            expected['profile_only'] = True
        assert new == expected, 'qualification changed original question'
    source = json.loads(gzip.decompress((HERE / 'oracle-template.json.gz').read_bytes()))
    oracle = copy.deepcopy(next(case for case in source if case['id'] == 'constructor_array_guard'))
    oracle['id'] = 'established_constructor_guard'
    oracle['source'] = 'fn supply(seed) {return(seed)}\n\nValue:: I {' + oracle['body'] + '}\n'
    assert qualified[-1] == oracle, 'established constructor oracle'


def record_binding(rows, raw_rows):
    assert rows == raw_rows, 'full raw record binding'


def input_binding(cases, rows, inputs):
    assert set(inputs) == {case['id'] for case in cases}, 'input population'
    for case in cases:
        key = case['id']
        assert inputs[key]['source'] == case['source'], 'authored source binding'
        for field, name in (('module_input', 'emitted'), ('handler_input', 'handler')):
            row, source = rows[key][field], inputs[key][name]
            assert row is not None and source is not None, 'actual pair presence'
            raw = source.encode()
            assert sha(raw) == row['sha256'] and len(raw) == row['bytes'], 'artifact source identity'
            assert gzip.decompress((ROOT / row['path']).read_bytes()) == raw, 'actual artifact bytes'


def command(row, argv):
    assert row['command'] == dict(argv=argv, cwd='.'), 'physical command'
    assert row['exit'] == '0\n' and row['stderr'] == b'', 'actual command outcome'


def channel_row(folder, tag):
    return dict(command=json.loads((folder / (tag + '-command.json')).read_bytes()),
        exit=(folder / (tag + '-exit.txt')).read_text(),
        stdout=gzip.decompress((folder / (tag + '-stdout.log.gz')).read_bytes()),
        stderr=gzip.decompress((folder / (tag + '-stderr.log.gz')).read_bytes()))


def archive(phase):
    folder = HERE / phase
    identities = json.loads((folder / 'input-identities.json').read_bytes())
    assert (folder / 'activation.txt').read_text().strip() == ACTIVATION, 'activation identity'
    with tarfile.open(folder / 'inputs-before-first-run.tar.gz') as bundle:
        assert set(bundle.getnames()) == set(identities), 'archive population'
        for member in bundle:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            raw = bundle.extractfile(member).read()
            row = identities[member.name]
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'archive body identity'
            assert member.mode & 0o777 == row['mode'], 'archive mode'
            if member.name.startswith(('perl/', 'specs/')):
                original = subprocess.check_output(['git', 'show', ACTIVATION + ':' + member.name], cwd=ROOT)
                assert raw == original, 'unchanged SDK at activation'
    for tag in ('version', 'observer'):
        row = channel_row(folder, tag)
        if tag == 'version':
            argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V']
        else:
            script = 'observer.pl' if phase == 'intake' else 'qualified_observer.pl'
            fixture = 'cases.json' if phase == 'intake' else 'qualified-cases.json'
            argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
                    str(BASE / script), str(BASE / fixture), str(BASE / phase)]
        command(row, argv)
    return identities


def producer_images():
    for path in HERE.glob('*-producer-images.json.gz'):
        for name, row in json.loads(gzip.decompress(path.read_bytes())).items():
            raw = base64.b64decode(row['base64'], validate=True)
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'producer image'
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
            assert (ROOT / name).read_bytes() == raw, 'producer changed'
            assert (ROOT / name).stat().st_mode & 0o777 == row['mode'], 'producer mode changed'


def pointers():
    report = json.loads((HERE / 'pointer-repairs.json').read_bytes())
    assert report['activation'] == ACTIVATION and len(report['repairs']) == 3
    for index, row in enumerate(report['repairs']):
        before = gzip.decompress((HERE / ('pointer-' + str(index) + '-before.gz')).read_bytes())
        original = gzip.decompress((HERE / ('pointer-' + str(index) + '-activation.gz')).read_bytes())
        assert sha(before) == row['before_sha256'] and sha(original) == row['activation_sha256']
        assert subprocess.check_output(['git', 'show', ACTIVATION + ':' + row['path']], cwd=ROOT) == original
        after = before.decode()
        for old, new in row['replacements']:
            assert after.count(old) == 1, 'exact pointer substitution'
            after = after.replace(old, new)
        assert sha(after.encode()) == row['after_sha256'], 'pointer repair identity'
        if index == 0:
            assert before == original, 'helper activation source'


def red_controls(cases, rows, inputs, raw_rows, old_cases, physical):
    rejected = []

    def red(label, action, reason):
        try:
            action()
        except AssertionError as error:
            assert str(error) == reason, (label, str(error), reason)
            rejected.append(dict(control=label, observed_red=reason))
        else:
            raise AssertionError('ineffective control: ' + label)

    for label, key, edit, reason in (
        ('hide-readiness-only', 'take_later_with', 'ready', 'actual readiness-only boundary'),
        ('hide-handler-error', 'take_receiver_hash_guard', 'error', 'actual handler compile error'),
        ('invent-fresh-after-failed-load', 'take_receiver_hash_guard', 'fresh', 'failed-load field absence'),
        ('hide-copy-body-effect', 'reverse_copy_later_with', 'copy', 'actual tail/source effects'),
        ('invent-source-effect', 'source_effect_before_rejection', 'source', 'actual tail/source effects'),
        ('wrong-healthy-value', 'take_free_hash_guard', 'value', 'healthy value/error'),
        ('mask-needed-error', 'needed_source_terminal', 'needed', 'healthy needed error'),
    ):
        changed = copy.deepcopy(rows)
        row = changed[key]
        if edit == 'ready': row['metadata'].update(language_agnostic_action_ir_ready=1, unresolved_helper_count=0, unresolved_helpers=[])
        elif edit == 'error': row['native_error']['stage'] = 'not_compile'
        elif edit == 'fresh': row['fresh'] = None
        elif edit == 'copy': row['native'] = [None, '']
        elif edit == 'source': row['native'] = [None, 'S']
        elif edit == 'value': row['native'] = [['head'], 'KV']
        else: row['native_error'] = None
        red(label, lambda: semantics(cases, changed), reason)
    changed = copy.deepcopy(rows)
    changed['take_receiver_hash_guard']['native_error']['detail'] += ' altered'
    red('changed-full-error-field', lambda: record_binding(changed, raw_rows), 'full raw record binding')
    changed = copy.deepcopy(rows)
    del changed['source_once']
    red('missing-healthy-member', lambda: semantics(cases, changed), 'question population')
    changed_inputs = copy.deepcopy(inputs)
    changed_inputs['take_receiver_hash_guard']['handler'] += ' changed'
    red('handler-byte', lambda: input_binding(cases, rows, changed_inputs), 'artifact source identity')
    changed_cases = copy.deepcopy(cases)
    changed_cases[0]['source'] += ' changed'
    red('authored-source-byte', lambda: input_binding(changed_cases, rows, inputs), 'authored source binding')
    changed_cases = copy.deepcopy(cases)
    literal = next(case for case in changed_cases if case['id'] == 'constructor_rejection_oracle')
    literal.pop('profile_only')
    literal['expected'] = [None, '']
    red('credit-unsupported-literal-expectation', lambda: qualification(old_cases, changed_cases), 'qualification changed original question')
    changed_cases = copy.deepcopy(cases)
    changed_cases[-1]['body'] = '["head"].set_key("k",1)'
    red('substitute-literal-for-constructor', lambda: qualification(old_cases, changed_cases), 'established constructor oracle')
    argv = physical['command']['argv']
    changed = copy.deepcopy(physical)
    changed['command']['argv'][-1] = 'wrong-output'
    red('wrong-physical-command', lambda: command(changed, argv), 'physical command')
    changed = copy.deepcopy(physical)
    changed['exit'] = '1\n'
    red('wrong-actual-exit', lambda: command(changed, argv), 'actual command outcome')
    return rejected


def review():
    seal = json.loads((HERE / 'sealed-identities.json').read_bytes())
    for name, row in seal.items():
        path = ROOT / name
        raw = path.read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], 'sealed input identity'
        assert path.stat().st_mode & 0o777 == row['mode'], 'sealed input mode'
    producer_images()
    pointers()
    for phase in ('intake', 'qualified'): archive(phase)
    old = json.loads((HERE / 'cases.json').read_bytes())
    cases = json.loads((HERE / 'qualified-cases.json').read_bytes())
    qualification(old, cases)
    old_rows, old_inputs = frames(gzip.decompress((HERE / 'intake/observer-stdout.log.gz').read_bytes()))
    rows, inputs = frames(gzip.decompress((HERE / 'qualified/observer-stdout.log.gz').read_bytes()))
    assert old_rows == json.loads((HERE / 'observations.json').read_bytes())
    record_binding(json.loads((HERE / 'qualified-observations.json').read_bytes()), rows)
    assert inputs == json.loads((HERE / 'qualified-input-records.json').read_bytes())
    assert set(old_rows) == set(old_inputs) == {case['id'] for case in old}
    for key in old_rows:
        normalized = copy.deepcopy(rows[key])
        for field in ('module_input', 'handler_input'):
            normalized[field]['path'] = normalized[field]['path'].replace('/qualified/', '/intake/')
        assert normalized == old_rows[key], 'original full record preservation'
        assert inputs[key] == old_inputs[key], 'original source/module/handler preservation'
    input_binding(old, old_rows, old_inputs)
    input_binding(cases, rows, inputs)
    semantics(cases, rows)
    profile = {case['id'] for case in cases if case.get('profile_only')}
    assert len(profile) == 7 and len(cases) - len(TARGETS) - len(profile) == 25
    actual = json.loads((HERE / 'qualified-assessment.json').read_bytes())
    assert set(actual['summary']['target']) == TARGETS and set(actual['summary']['profile']) == profile
    assert actual['summary']['readiness_only'] == ['take_later_with']
    physical = channel_row(HERE / 'qualified', 'observer')
    rejected = red_controls(cases, rows, inputs, rows, old, physical)
    return dict(result='PASS', original_questions=44, qualified_questions=45,
        supported_targets=len(TARGETS), healthy=25, profiles=len(profile), original_full_records_preserved=len(old_rows),
        actual_source_pairs=len(old) + len(cases), metadata_fields=sorted(META), rejected_controls=rejected,
        limits='Finite original/qualified source and full-record recovery; source profiles are not semantic PASS. Initial literal policy1.2.1.3.1 and complete native/cache/transitive/toolchain/OS custody4.2/SESSION5 remain open. Qualification composition retained only actual combined exec output, not separated original stdout/stderr.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
