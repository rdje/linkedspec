"""Compose readonly runtime/book reviews and verify actual evidence controls."""
import base64
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


evidence = json.loads(read(PREFIX + 'evidence.json'))
assert evidence['result'] == 'PASS' and evidence['unchanged'] is True
assert evidence['producer_sha256'] == digest(read(PREFIX + 'evidence.py'))
original = {path: read(path) for path in evidence['original_inputs']}
assert {p: digest(raw) for p, raw in original.items()} == evidence['original_inputs'], 'successful evidence bytes drift'
positive = json.loads(original[PREFIX + 'fixture.json']); positive['returncode'] = 1
consumers = json.loads(original[PREFIX + 'consumers.json'])
artifact = next(p for p in consumers['inputs'] if p.startswith('docs/checkpoints/') and p.endswith('.json'))
del consumers['inputs'][artifact]
missing = json.loads(original[PREFIX + 'inverses.json']); missing['rows'].pop()
path = PREFIX + 'inverse-required.json'
inverse = json.loads(original[path])
inverse['stdout_base64'] = base64.b64encode(base64.b64decode(inverse['stdout_base64']).replace(
    inverse['distinguishing_reason'].encode(), b'unrelated assertion')).decode()
index = json.loads(original[PREFIX + 'inverses.json'])
index['rows'][0]['sha256'] = digest((json.dumps(inverse, indent=2) + '\n').encode())
expected = [
    ('failed-positive', {PREFIX + 'fixture.json': positive}, 'positive main method/value capture failed'),
    ('missing-reader-input', {PREFIX + 'consumers.json': consumers}, 'supplied input population/content mismatch'),
    ('missing-inverse', {PREFIX + 'inverses.json': missing}, 'missing inverse'),
    ('lost-semantic-reason', {path: inverse, PREFIX + 'inverses.json': index}, 'source-fault assertion population changed'),
    ('missing-consumer-capture', {PREFIX + 'consumers.json': None}, 'FileNotFoundError'),
]
assert len(evidence['rows']) == len(expected)
command = ['python3', PREFIX + 'review.py']
for row, (name, changes, reason) in zip(evidence['rows'], expected):
    assert row['case'] == name and row['reason'] == reason and row['command'] == command
    assert row['reviewer_sha256'] == digest(read(PREFIX + 'review.py'))
    assert row['returncode'] != 0 and reason.encode() in base64.b64decode(row['stderr_base64'], validate=True)
    base64.b64decode(row['stdout_base64'], validate=True)
    assert set(row['changes']) == set(changes)
    for path, data in changes.items():
        change = row['changes'][path]
        assert change['before_sha256'] == digest(original[path])
        if data is None:
            assert change['after_base64'] is None
            assert (PREFIX + 'consumers.json').encode() in base64.b64decode(row['stderr_base64'], validate=True)
        else:
            raw = base64.b64decode(change['after_base64'], validate=True)
            assert raw == (json.dumps(data, indent=2) + '\n').encode(), 'counterfactual artifact identity'
restored = evidence['restored']
assert restored['command'] == command and restored['returncode'] == 0
assert b'PASS518/10/3' in base64.b64decode(restored['stdout_base64'], validate=True)
assert not base64.b64decode(restored['stderr_base64'], validate=True)

rows = []
for tail in ('review.py', 'book-review.py', 'preservation-control.py', 'draft-replay-review.py'):
    path = PREFIX + tail
    read(path)
    result = subprocess.run(['python3', path], cwd=ROOT,
                            env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    rows.append({'command': ['python3', path], 'returncode': result.returncode,
                 'stdout_base64': base64.b64encode(result.stdout).decode(),
                 'stderr_base64': base64.b64encode(result.stderr).decode()})
    assert result.returncode == 0, (tail, result.stderr)
draft = json.loads(read(PREFIX + 'draft-replay-review.json'))['proof']
assert draft['result'] == 'PASS' and len(draft['rows']) == 3
for path, expected in draft['checked'].items():
    assert digest(read(path)) == expected, 'retained draft input identity'
book = json.loads(read(PREFIX + 'book-review.json'))
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
read(PREFIX + 'book.json'); read(PREFIX + 'book.py')
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'scope': 'Fresh actual readonly runtime/book/preservation/native-draft reviews and exact five evidence-control counterfactual/channel identities. Original291 assignment input identities remain exact; both retained fixture premise failures and the rejected original-seed reviewer are actually reproduced in supplied repository-volume scratch. Complete native42/branch23 ledgers, identical518 assertion populations and three effective source faults admit only the main required resolver.'}
target = ROOT / (PREFIX + 'final-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot final review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'final composed review drift'
print('Composed acceptance review PASS: runtime518/10/3, callbacks42/branches23, paired42RED/518GREEN, consumers48/168, evidence5, drafts3, book57+32/3')
