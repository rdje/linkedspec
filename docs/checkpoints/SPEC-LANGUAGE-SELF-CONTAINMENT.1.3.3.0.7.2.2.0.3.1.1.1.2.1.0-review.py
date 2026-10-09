"""Independent authored-interval/reference oracle and evidence RED controls."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
fixtures = json.loads((ROOT / (PREFIX + 'cases.json')).read_text())

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def validate(report):
    assert report['returncode'] == 0, 'successful actual exit'
    assert base64.b64decode(report['stderr_base64']) == b'', 'empty actual stderr'
    assert report['unchanged'] and report['production_matches_base'], 'unchanged production'
    assert report['command'] == ['perl', '-Iperl', PREFIX + 'probe.pl'], 'actual command'
    parent = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
    parent = {p for p in parent if p and (ROOT / p).is_file()}
    assert set(report['inputs']) == parent | {PREFIX + s for s in ('probe.pl', 'cases.json', 'capture.py')}, 'complete parent source superset'
    for p, h in report['inputs'].items():
        assert digest((ROOT / p).read_bytes()) == h, 'actual input identity'
    assert all(PREFIX + suffix in report['inputs'] for suffix in ('probe.pl', 'cases.json', 'capture.py')), 'complete producer inputs'
    observed = json.loads(base64.b64decode(report['stdout_base64']))
    assert len(observed['cases']) == len(fixtures), 'complete case population'
    for wanted, case in zip(fixtures, observed['cases']):
        assert case['id'] == wanted['id'] and case['source'] == wanted['source'], 'authored case identity'
        assert case['ordinary'] == case['ast'], 'unchanged public AST'
        assert len({case['root_id'], case['copy_id'], case['foreign_id']}) == 3, 'actual distinct node identities'
        constructors = {row['id']: row for row in case['nodes']}
        assert len(constructors) == len(case['nodes']), 'unique retained constructors'
        assert constructors[case['root_id']]['node'] == case['ast'], 'actual root construction'
        assert len(case['ast']['args']) == len(wanted['arguments']) == len(case['frames']), 'retained argument population'
        for index, (expected, argument, frame) in enumerate(zip(wanted['arguments'], case['ast']['args'], case['frames'])):
            assert argument['source'] == expected['raw'] and argument['source_span'] == expected['source_span'], 'independent authored AST interval'
            assert frame['raw'] == expected['raw'] and frame['source_span'] == expected['source_span'] and frame['source'] == wanted['source'], 'independent original argument frame'
            assert constructors[case['argument_ids'][index]]['node'] == argument, 'actual child construction'
        if wanted['id'] != 'empty-slots':
            assert isinstance(case['lowered'], str) and case['lowered'] != 'return(' + wanted['source'] + ')', 'actual Toolbox lowering'
        else:
            assert case['lowered'] is None, 'empty slots parser-only scope'
    callbacks = {row['mode']: row for row in observed['callbacks']}
    assert set(callbacks) == {'actual', 'copied', 'changed', 'foreign', 'opaque', 'nested', 'fatal'}, 'complete callback population'
    for mode, row in callbacks.items():
        assert row['count'] == 1 and row['context'] == 'scalar', 'callback count/context'
        if mode == 'fatal':
            assert row['same_exception'] == 1 and row['error'] == 'exception-object', 'actual exception identity'
            continue
        assert row['error'] == 'caller-error', 'successful caller error preservation'
        frames = row['result']['source_frames']
        if mode in ('copied', 'foreign', 'opaque'):
            assert frames == [], 'copied foreign opaque frames declined'
        if mode in ('actual', 'changed', 'foreign', 'nested'):
            assert row['actual_id'] == row['returned_id'], 'actual callback return retained'
        if mode == 'copied':
            assert row['actual_id'] != row['returned_id'], 'copied callback return preserved'
        if mode == 'opaque':
            assert row['result']['call'] == 'opaque-result', 'opaque callback result preserved'
        if mode in ('actual', 'nested'):
            assert len(frames) == 2 and all(frames), 'actual frames selected'
        if mode == 'changed':
            assert len(frames) == 2 and frames[0] is None and frames[1] is not None, 'changed entry declines individually'
        if mode == 'nested':
            assert frames[0]['raw'] == '"λ"' and row['nested']['source_frames'][0]['raw'] == '"nested"', 'nested collector restores outer'
    unguarded, guarded = observed['dependency']
    assert [unguarded['barrier'], guarded['barrier']] == [0, 1], 'actual dependency intervention'
    for row in (unguarded, guarded):
        assert row['value'] == 'sentinel' and row['effects'] == ['opaque', 'builder'] and row['context'] == 'scalar', 'dependency behavior preserved'
    assert unguarded['has_packet'] == 1 and guarded['has_packet'] == 0, 'nested opaque capture barrier distinguishes equal text'
    return observed

actual = json.loads((ROOT / (PREFIX + 'actual.json')).read_text())
observed = validate(actual)
for p, h in actual['inputs'].items():
    if p.startswith(('perl/', 'specs/')):
        assert digest(subprocess.check_output(['git', 'show', actual['base'] + ':' + p], cwd=ROOT)) == h, 'immutable unchanged production'
freeze = json.loads((ROOT / (PREFIX + 'freeze.json')).read_text())
for row in freeze['records']:
    before = (ROOT / row['before']).read_bytes()
    assert digest(before) == row['original_sha256']
    original = json.loads(before)
    for claim in original['claims']:
        for entry in claim['durability']['inputs']:
            assert digest(subprocess.check_output(['git', 'show', freeze['revision'] + ':' + entry['path']], cwd=ROOT)) == entry['sha256']
        claim['durability'].update(mode='historical', revision=freeze['revision'])
    assert original == json.loads((ROOT / row['path']).read_text()), 'historical mode/revision only'
controls = []
def red(name, mutate, reason):
    candidate = copy.deepcopy(actual)
    mutate(candidate)
    try:
        validate(candidate)
    except AssertionError as exc:
        assert str(exc) == reason, (name, str(exc))
        controls.append({'name': name, 'result': 'RED', 'reason': str(exc)})
        return
    raise AssertionError('ineffective evidence control: ' + name)

def observation_edit(change):
    def apply(report):
        value = json.loads(base64.b64decode(report['stdout_base64']))
        change(value)
        report['stdout_base64'] = base64.b64encode(json.dumps(value, ensure_ascii=False).encode()).decode()
    return apply

red('failed-exit', lambda r: r.update(returncode=1), 'successful actual exit')
red('forged-source', lambda r: r['inputs'].update({PREFIX + 'probe.pl': '0' * 64}), 'actual input identity')
red('missing-case', observation_edit(lambda r: r['cases'].pop()), 'complete case population')
red('copied-node-as-actual', observation_edit(lambda r: r['cases'][0].update(copy_id=r['cases'][0]['root_id'])), 'actual distinct node identities')
red('shifted-original-frame', observation_edit(lambda r: r['cases'][0]['frames'][0]['source_span'].update(start=1)), 'independent original argument frame')
red('extra-callback', observation_edit(lambda r: r['callbacks'][0].update(count=2)), 'callback count/context')
red('opaque-packet-inheritance', observation_edit(lambda r: r['dependency'][1].update(has_packet=1)), 'nested opaque capture barrier distinguishes equal text')
result = {'result': 'PASS', 'cases': len(fixtures), 'authored_arguments': sum(len(c['arguments']) for c in fixtures),
          'callback_modes': len(observed['callbacks']), 'dependency_interventions': len(observed['dependency']),
          'evidence_red_controls': controls, 'actual_sha256': digest((ROOT / (PREFIX + 'actual.json')).read_bytes()),
          'reviewer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Unchanged-production diagnosis and selected future private protocol; not implemented AST authority or production producer integration.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(result, indent=2) + '\n')
print('Input diagnosis PASS:', result['cases'], 'cases,', result['authored_arguments'], 'authored arguments,', len(controls), 'reason-sensitive evidence REDs.')
