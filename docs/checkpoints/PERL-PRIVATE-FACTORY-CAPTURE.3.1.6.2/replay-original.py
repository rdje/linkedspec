"""Readonly original-publication replay; capture retains a card corruption and restoration."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FOLDER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json'
PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py'
CARD = 'docs/knowledge/perl-scalar-receiver-required-capture.md'
TARGET = ROOT / (FOLDER + 'original-replay.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
serialize = lambda value: (json.dumps(value, indent=2) + '\n').encode()
retained = json.loads((ROOT / (FOLDER + 'preservation.json')).read_bytes())
originals = {name: (ROOT / (FOLDER + name)).read_bytes() for name in retained['original_files']}
for name, raw in originals.items():
    assert sha(raw) == retained['original_files'][name]['sha256'], 'retained original identity'
original_claim = json.loads(originals['original-claim.json'])
entries = original_claim['claims'][0]['durability']['inputs']
assert len(entries) == retained['original_inputs'] == 323
supplied = {entry['path']: (originals['original-publisher.py'] if entry['path'] == PUBLISHER
                            else originals['original-scalar-card.md'] if entry['path'] == CARD
                            else (ROOT / entry['path']).read_bytes()) for entry in entries}
assert {path: sha(raw) for path, raw in supplied.items()} == {entry['path']: entry['sha256'] for entry in entries}
assert CLAIM not in supplied
supplied[CLAIM] = originals['original-claim.json']
population = {path: sha(raw) for path, raw in supplied.items()}
assert len(population) == 324
command = ['python3', PUBLISHER]
changed = supplied[CARD] + b'\n'
changed_population = dict(population, **{CARD: sha(changed)})

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot original replay already retained'
    git_dir = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip()
    with tempfile.TemporaryDirectory(prefix='scalar-publication-original-', dir=os.environ['TMPDIR']) as directory:
        directory = Path(directory)
        assert directory.stat().st_dev == ROOT.stat().st_dev
        for path, raw in supplied.items():
            target = directory / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod((ROOT / path).stat().st_mode & 0o777)
        environment = dict(os.environ, GIT_DIR=git_dir, GIT_WORK_TREE=str(directory),
                           GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
        rows = []
        for label in ('healthy', 'changed-card', 'restored'):
            (directory / CARD).write_bytes(changed if label == 'changed-card' else supplied[CARD])
            expected = changed_population if label == 'changed-card' else population
            result = subprocess.run(command, cwd=directory, env=environment,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
            observed = {p.relative_to(directory).as_posix(): sha(p.read_bytes())
                        for p in directory.rglob('*') if p.is_file()}
            row = {'label': label, 'command': command, 'returncode': result.returncode,
                   'stdout_base64': base64.b64encode(result.stdout).decode(),
                   'stderr_base64': base64.b64encode(result.stderr).decode(),
                   'inputs': expected, 'unchanged': observed == expected}
            rows.append(row)
            TARGET.write_bytes(serialize({'result': 'pending', 'rows': rows}))
            assert row['unchanged'], 'original replay input preservation'
            if label == 'changed-card':
                assert result.returncode != 0 and b'required scalar publication drift' in result.stderr, 'original card-binding RED'
            else:
                assert result.returncode == 0 and not result.stderr, 'exact original publication replay'
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
              'original_claim_sha256': sha(originals['original-claim.json']),
              'original_publisher_sha256': sha(originals['original-publisher.py']),
              'original_card_sha256': sha(originals['original-scalar-card.md']),
              'original_binding_count': 323, 'inputs': population, 'rows': rows,
              'changed_card_base64': base64.b64encode(changed).decode(),
              'scope': 'The exact original323 publication inputs plus its original claim target are supplied at their logical paths. Actual original readonly publisher PASS, changed-card metadata RED and exact restored PASS retain full channels and input identities. Original runtime/native/book observations are reviewed, never remeasured. Main Git access is read-only.'}
    TARGET.write_bytes(serialize(report))
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['original_claim_sha256'] == sha(originals['original-claim.json'])
    assert report['original_publisher_sha256'] == sha(originals['original-publisher.py'])
    assert report['original_card_sha256'] == sha(originals['original-scalar-card.md'])
    assert report['original_binding_count'] == 323 and report['inputs'] == population
    assert base64.b64decode(report['changed_card_base64'], validate=True) == changed
    assert [row['label'] for row in report['rows']] == ['healthy', 'changed-card', 'restored']
    for row in report['rows']:
        damaged = row['label'] == 'changed-card'
        assert row['command'] == command and row['inputs'] == (changed_population if damaged else population) and row['unchanged']
        error = base64.b64decode(row['stderr_base64'], validate=True)
        if damaged:
            assert row['returncode'] != 0 and b'required scalar publication drift' in error
        else:
            assert row['returncode'] == 0 and not error
print('Original323 publication replay PASS; actual card-binding RED and restored PASS; runtime observations unchanged')
