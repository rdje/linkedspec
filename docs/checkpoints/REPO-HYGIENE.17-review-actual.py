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
PREFIX = 'docs/checkpoints/REPO-HYGIENE.17-'
BASE = 'd432a955ca7a976ccbc3fa047f97bc5e3103ea76'
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
assert census['owner'] == review['owner'] == 'REPO-HYGIENE.17'
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
claims = subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
census = []
for path in sorted(claims):
    payload = subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
    data = json.loads(payload)
    hits = [i for i,c in enumerate(data['claims']) if c['durability'].get('mode')=='live'
            and set(freeze['publication_paths']) & {x['path'] for x in c['durability']['inputs']}]
    census.append({'path':path,'sha256':sha(payload),'intersections':hits})
assert census==freeze['original_claim_census'] and not freeze['records'], 'fixed accepted namespace / zero original live intersections'
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

result = {'owner': 'REPO-HYGIENE.17', 'result': 'PASS', 'controls': controls,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'limits': 'Dated retained metadata and actual channels only; no content ownership, disposal safety, liveness, recovery/purge or concurrent adversarial traversal guarantee.'}
target = ROOT / (PREFIX + 'actual-verification.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot actual review already captured'
    target.write_text(json.dumps(result, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == result, 'retained actual verification drift'
print('Actual census/review channels and four reason-sensitive evidence RED controls PASS.')
