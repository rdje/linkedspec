"""Actual current-reviewer RED/restoration controls; default reads retained evidence."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
ADR = 'docs/decisions/0133-finite-engineering-notes-member.md'
CARD = 'docs/knowledge/finite-engineering-notes-member-0131.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
paths = [CLAIM, ADR, CARD, BOOK] + [DIR + name for name in (
    'review.py', 'freeze.py', 'freeze.json', 'diagnosis.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json',
    'original-replay.json', 'original-replay-reached.json',
    'review-draft.py', 'retain-draft.py', 'draft-correction.json',
    'original-replay-draft-reached.json')]
sha = lambda raw: hashlib.sha256(raw).hexdigest()
files = {path: (ROOT / path).read_bytes() for path in paths}
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
assert sys.argv[1:] in ([], ['--capture'])


def changed(name):
    selected = dict(files)
    if name == 'stale-command':
        old = (DIR + 'review.py').encode()
        new = b'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-capacity.py review'
        assert selected[ADR].count(old) == 1
        selected[ADR] = selected[ADR].replace(old, new, 1)
    elif name == 'forged-original-binding':
        record = json.loads(selected[CLAIM])
        record['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        selected[CLAIM] = (json.dumps(record, indent=2) + '\n').encode()
        freeze = json.loads(selected[DIR + 'freeze.json'])
        freeze['records'][0]['after_sha256'] = sha(selected[CLAIM])
        selected[DIR + 'freeze.json'] = (json.dumps(freeze, indent=2) + '\n').encode()
    elif name == 'missing-guidance':
        marker = b'A historical review command requires its original logical inputs.\n'
        assert selected[BOOK].count(marker) == 1
        selected[BOOK] = selected[BOOK].replace(marker, b'', 1)
    else:
        assert name == 'healthy'
    return selected


reasons = {'stale-command': 'exact current ADR review pointer',
           'forged-original-binding': 'mode/revision-only predecessor preservation',
           'missing-guidance': 'exact related guidance: ' + BOOK}


def run(selected):
    population = {path: sha(raw) for path, raw in sorted(selected.items())}
    with tempfile.TemporaryDirectory(prefix='current-review-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in selected.items():
            destination = supplied / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(raw)
        command = ['python3', DIR + 'review.py']
        environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied),
                           GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
        result = subprocess.run(command, cwd=supplied, env=environment,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        census = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
                  for path in supplied.rglob('*') if path.is_file()}
        return {'command': command, 'inputs': population, 'unchanged': census == population,
                'returncode': result.returncode,
                'stdout_base64': base64.b64encode(result.stdout).decode(),
                'stderr_base64': base64.b64encode(result.stderr).decode()}


target = ROOT / (DIR + 'evidence.json')
reached = ROOT / (DIR + 'evidence-reached.json')
if sys.argv[1:]:
    assert not target.exists() and not reached.exists(), 'one-shot current controls'
    data = {'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs,
            'healthy': run(files), 'rows': []}
    reached.write_text(json.dumps(data, indent=2) + '\n')
    assert data['healthy']['returncode'] == 0 and data['healthy']['unchanged']
    assert not base64.b64decode(data['healthy']['stderr_base64'])
    for name, reason in reasons.items():
        selected = changed(name)
        row = {'name': name, 'reason': reason,
               'mutations': {path: base64.b64encode(raw).decode() for path, raw in selected.items() if raw != files[path]},
               'observed': run(selected)}
        data['rows'].append(row)
        reached.write_text(json.dumps(data, indent=2) + '\n')
        assert row['observed']['returncode'] != 0 and row['observed']['unchanged']
        assert reason.encode() in base64.b64decode(row['observed']['stderr_base64']), 'named actual current-reviewer denial'
        row['restored'] = run(files)
        reached.write_text(json.dumps(data, indent=2) + '\n')
        assert row['restored']['returncode'] == 0 and row['restored']['unchanged']
        assert row['restored']['stdout_base64'] == data['healthy']['stdout_base64']
        assert row['restored']['stderr_base64'] == data['healthy']['stderr_base64']
    data['scope'] = 'Three actual current-reviewer denials, each exact restoration: stale command, forged original binding beyond an updated immediate freeze-SHA field, and missing book guidance. Complete supplied populations, changed bytes and distinct channels are saved before assertions. Accepted Git object reads are read-only; no original producer or observation is refreshed.'
    reached.write_text(json.dumps(data, indent=2) + '\n')
    target.write_text(json.dumps(data, indent=2) + '\n')
data = json.loads(target.read_bytes())
assert json.loads(reached.read_bytes()) == data
assert data['producer_sha256'] == sha(Path(__file__).read_bytes()) and data['inputs'] == inputs
assert [row['name'] for row in data['rows']] == list(reasons)
assert data['healthy']['inputs'] == inputs and data['healthy']['returncode'] == 0 and data['healthy']['unchanged']
assert not base64.b64decode(data['healthy']['stderr_base64'], validate=True)
for row in data['rows']:
    selected = changed(row['name'])
    assert row['mutations'] == {path: base64.b64encode(raw).decode() for path, raw in selected.items() if raw != files[path]}
    assert row['reason'] == reasons[row['name']]
    assert row['observed']['inputs'] == {path: sha(raw) for path, raw in selected.items()}
    assert row['observed']['returncode'] != 0 and row['observed']['unchanged']
    assert row['reason'].encode() in base64.b64decode(row['observed']['stderr_base64'], validate=True)
    assert row['restored']['inputs'] == inputs and row['restored']['returncode'] == 0 and row['restored']['unchanged']
    assert row['restored']['stdout_base64'] == data['healthy']['stdout_base64']
    assert row['restored']['stderr_base64'] == data['healthy']['stderr_base64']
    for observed in (row['observed'], row['restored']):
        assert observed['command'] == ['python3', DIR + 'review.py']
        for channel in ('stdout_base64', 'stderr_base64'):
            base64.b64decode(observed[channel], validate=True)
print('Current reviewer evidence PASS: three actual named REDs and exact restorations;', len(inputs), 'supplied current files')
