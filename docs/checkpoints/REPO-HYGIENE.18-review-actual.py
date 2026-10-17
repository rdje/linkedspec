"""Independently validate actual census/review channels and preservation."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.18-'
BASE = 'e2ec1e96bc47633599f0935ed6828c1a0b99e40a'
assert sys.argv[1:] in ([], ['--capture'])


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(value):
    raw = gzip.decompress(base64.b64decode(value['gzip_base64'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'channel identity'
    return raw


def verify_actual(record):
    assert record['complete'] and record['revision'] == BASE and len(record['runs']) == 2, 'complete actual capture'
    for path, digest in record['inputs'].items():
        assert sha((ROOT / path).read_bytes()) == digest, 'producer identity'
    for run, source, args, output in zip(record['runs'], ('census.py', 'review.py'),
                                       ([], ['--live']), ('artifact-review.json', 'verification.json')):
        assert run['command'] == ['bash', 'tools/run_python_project_data.sh', PREFIX + source] + args, 'actual command'
        assert run['exit'] == 0, 'actual exit'
        assert run['inputs_before'] == run['inputs_after'] == record['inputs'], 'source guards'
        assert decode(run['stdout']) == (ROOT / (PREFIX + output)).read_bytes(), 'published stdout'
        assert decode(run['stderr']) == b'', 'actual stderr'


actual = json.loads((ROOT / (PREFIX + 'actual.json')).read_bytes())
verify_actual(actual)
controls = []
for name, change, reason in (
    ('incomplete capture', lambda d: d.update(complete=False), 'complete actual capture'),
    ('forged producer', lambda d: d['inputs'].update({PREFIX + 'capture.py': '0' * 64}), 'producer identity'),
    ('failed review', lambda d: d['runs'][1].update(exit=1), 'actual exit'),
    ('forged stdout', lambda d: d['runs'][0]['stdout'].update(sha256='0' * 64), 'channel identity')):
    candidate = copy.deepcopy(actual)
    change(candidate)
    try:
        verify_actual(candidate)
    except AssertionError as error:
        assert str(error) == reason, (name, str(error))
        controls.append({'name': name, 'rejected': True, 'reason': reason})
    else:
        raise AssertionError('accepted corruption: ' + name)

census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
review = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
assert census['owner'] == review['owner'] == 'REPO-HYGIENE.18'
assert census['activation_commit'] == BASE and census['at_utc'] == review['at_utc']
assert census['artifact_files'] == review['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == review['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == review['removed_files'] == review['removed_bytes'] == 0
for key in ('live_metadata_checked', 'fresh_metadata_census_matches', 'per_file_os_metadata_oracle_matches',
            'aggregate_inflation_rejected', 'balanced_size_redistribution_rejected', 'start_symlink_rejected',
            'ancestor_symlink_rejected', 'start_nested_repository_rejected', 'start_submodule_rejected',
            'outside_root_rejected'):
    assert review[key], key

freeze = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
assert freeze['base'] == BASE and freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'freeze.py')).read_bytes())
claims = subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
old = lambda path: subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
original_census = []
for path in sorted(claims):
    payload = old(path)
    data = json.loads(payload)
    hits = []
    for i, claim in enumerate(data['claims']):
        d = claim['durability']
        intersection = sorted(set(freeze['owned_bound_paths']) & {x['path'] for x in d['inputs']})
        if d.get('mode') == 'live' and intersection:
            hits.append({'claim_index': i, 'paths': intersection, 'bindings': len(d['inputs'])})
    original_census.append({'path':path,'sha256':sha(payload),'intersections':hits})
assert original_census == freeze['census'], 'fixed accepted claim namespace'
assert len(freeze['selected']) == len(freeze['baselines']) == 1
entry = freeze['selected'][0]
assert entry['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3.json'
accepted = old(entry['path'])
assert len(accepted) == entry['bytes'] == 117862 and sha(accepted) == entry['sha256']
original = json.loads(accepted)
assert len(original['claims']) == 1
bindings = original['claims'][0]['durability']['inputs']
assert len(bindings) == 507 and entry['intersections'][0]['bindings'] == 507
for item in bindings:
    assert sha(old(item['path'])) == item['sha256'], ('complete original historical binding', item['path'])
expected = copy.deepcopy(original)
expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
baseline = freeze['baselines'][0]
assert baseline == json.loads((ROOT/(PREFIX+'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.1.3.json')).read_bytes())

def verify_preserved(before, projected, observed):
    assert before == accepted, 'accepted whole publication'
    assert projected == expected, 'mode/revision-only projection'
    assert observed['claim'] == entry['path'], 'actual baseline claim'
    assert observed['command'] == ['bash','tools/run_python_project_data.sh','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/publish.py'], 'actual baseline command'
    assert observed['returncode'] == 0 and base64.b64decode(observed['stderr_base64'],validate=True) == b'', 'actual baseline exit/channels'
    assert base64.b64decode(observed['stdout_base64'],validate=True) == b'Finite engineering-history publication PASS: 507 live inputs; 117862 bytes\n', 'actual baseline stdout'

before = (ROOT/entry['before']).read_bytes()
projected = json.loads((ROOT/entry['path']).read_bytes())
verify_preserved(before, projected, baseline)
preservation_controls = []
for name in ('whole-publication bytes', 'historical projection', 'baseline stdout'):
    test_before, test_projection, test_baseline = before, copy.deepcopy(projected), copy.deepcopy(baseline)
    if name == 'whole-publication bytes':
        test_before = b' ' + before
        reason = 'accepted whole publication'
    elif name == 'historical projection':
        test_projection['claims'][0]['statement'] += ' forged'
        reason = 'mode/revision-only projection'
    else:
        test_baseline['stdout_base64'] = base64.b64encode(b'forged\n').decode()
        reason = 'actual baseline stdout'
    try:
        verify_preserved(test_before, test_projection, test_baseline)
    except AssertionError as error:
        assert str(error) == reason, (name, str(error))
        preservation_controls.append({'name':name,'rejected':True,'reason':reason})
    else:
        raise AssertionError('accepted preservation corruption: '+name)

result = {'owner': 'REPO-HYGIENE.18', 'result': 'PASS', 'controls': controls,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'historical_publication_inputs':507, 'historical_publication_bytes':117862,
          'preservation_controls':preservation_controls,
          'limits': 'Dated retained metadata and actual channels only; no content ownership, disposal safety, liveness, recovery/purge or concurrent adversarial traversal guarantee.'}
target = ROOT / (PREFIX + 'actual-verification.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot actual review already captured'
    target.write_text(json.dumps(result, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == result, 'retained actual verification drift'
print('Actual census/review channels and four channel/three preservation RED controls PASS.')
