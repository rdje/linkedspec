"""Independently validate actual census/review channels and preservation."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.14-'
BASE = '85691a26603ffd5c2453c39237fb4de407861d7f'


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
assert census['owner'] == review['owner'] == 'REPO-HYGIENE.14'
assert census['activation_commit'] == BASE and census['at_utc'] == review['at_utc']
assert census['artifact_files'] == review['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == review['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == review['removed_files'] == review['removed_bytes'] == 0
for key in ('live_metadata_checked', 'fresh_metadata_census_matches', 'per_file_os_metadata_oracle_matches',
            'aggregate_inflation_rejected', 'balanced_size_redistribution_rejected', 'start_symlink_rejected',
            'ancestor_symlink_rejected', 'start_nested_repository_rejected', 'start_submodule_rejected',
            'outside_root_rejected'):
    assert review[key], key

freeze = json.loads((ROOT / (PREFIX + 'freeze.json')).read_bytes())
assert freeze['revision'] == BASE and freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'freeze.py')).read_bytes())
for entry in freeze['records']:
    original = (ROOT / entry['before']).read_bytes()
    assert original == subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)
    assert sha(original) == entry['original_sha256']
    expected = json.loads(original)
    count = 0
    for claim in expected['claims']:
        leg = claim['durability']
        if leg.get('mode') != 'live':
            continue
        for item in leg['inputs']:
            raw = subprocess.check_output(['git', 'show', BASE + ':' + item['path']], cwd=ROOT)
            assert sha(raw) == item['sha256'], item['path']
            count += 1
        leg.update(mode='historical', revision=BASE)
    assert count == entry['verified_bindings']
    current = (ROOT / entry['path']).read_bytes()
    assert json.loads(current) == expected and sha(current) == entry['after_sha256']

result = {'owner': 'REPO-HYGIENE.14', 'result': 'PASS', 'controls': controls,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'limits': 'Dated retained metadata and actual channels only; no content ownership, disposal safety, liveness, recovery/purge or concurrent adversarial traversal guarantee.'}
(ROOT / (PREFIX + 'actual-verification.json')).write_text(json.dumps(result, indent=2) + '\n')
print('Actual census/review channels and four reason-sensitive evidence RED controls PASS.')
