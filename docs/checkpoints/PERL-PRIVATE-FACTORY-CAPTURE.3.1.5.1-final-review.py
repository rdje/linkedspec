"""Compose readonly runtime/book reviews and verify actual evidence controls."""
import base64
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1'
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
positive = json.loads(original[PREFIX + 'complete-fixture.json']); positive['returncode'] = 1
consumers = json.loads(original[PREFIX + 'complete-consumers.json'])
artifact = next(p for p in consumers['inputs'] if p.startswith('docs/checkpoints/') and p.endswith('.json'))
del consumers['inputs'][artifact]
missing = json.loads(original[PREFIX + 'complete-inverses.json']); missing['rows'].pop()
path = PREFIX + 'complete-inverse-payload-required.json'
inverse = json.loads(original[path])
inverse['stdout_base64'] = base64.b64encode(base64.b64decode(inverse['stdout_base64']).replace(
    inverse['distinguishing_reason'].encode(), b'unrelated assertion')).decode()
index = json.loads(original[PREFIX + 'complete-inverses.json'])
index['rows'][0]['sha256'] = digest((json.dumps(inverse, indent=2) + '\n').encode())
expected = [
    ('failed-positive', {PREFIX + 'complete-fixture.json': positive}, 'positive generalized-return required capture failed'),
    ('missing-reader-input', {PREFIX + 'complete-consumers.json': consumers}, 'supplied input population/content mismatch'),
    ('missing-inverse', {PREFIX + 'complete-inverses.json': missing}, 'missing inverse'),
    ('lost-semantic-reason', {path: inverse, PREFIX + 'complete-inverses.json': index}, 'source-fault assertion population changed'),
    ('missing-consumer-capture', {PREFIX + 'complete-consumers.json': None}, 'FileNotFoundError'),
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
            assert (PREFIX + 'complete-consumers.json').encode() in base64.b64decode(row['stderr_base64'], validate=True)
        else:
            raw = base64.b64decode(change['after_base64'], validate=True)
            assert raw == (json.dumps(data, indent=2) + '\n').encode(), 'counterfactual artifact identity'
restored = evidence['restored']
assert restored['command'] == command and restored['returncode'] == 0
assert b'PASS574/15/6' in base64.b64decode(restored['stdout_base64'], validate=True)
assert not base64.b64decode(restored['stderr_base64'], validate=True)

rows = []
for tail in ('review.py', 'book-review.py', 'preservation-control.py', 'instrument-review.py'):
    path = PREFIX + tail
    read(path)
    result = subprocess.run(['python3', path], cwd=ROOT,
                            env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    rows.append({'command': ['python3', path], 'returncode': result.returncode,
                 'stdout_base64': base64.b64encode(result.stdout).decode(),
                 'stderr_base64': base64.b64encode(result.stderr).decode()})
    assert result.returncode == 0, (tail, result.stderr)
instrument = json.loads(read(PREFIX + 'instrument-review.json'))
assert instrument['result'] == 'retained-replay' and len(instrument['rows']) == 4
for path, expected_hash in instrument['checked'].items():
    assert digest(read(path)) == expected_hash, 'historical instrument input identity'
book = json.loads(read(PREFIX + 'book-review.json'))
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
read(PREFIX + 'book.json'); read(PREFIX + 'book.py')
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'scope': 'Fresh actual readonly runtime/book/preservation/instrument reviews and exact five evidence-control counterfactual/channel identities. Original307 bindings remain exact. Complete native9/branch52/public9 ledgers, identical574 TAP and six effective source faults admit only two generalized-return required resolver returns. Original partial28 loading instrument and565 fixture remain unchanged; four supplied172-file replay channels are retained, all stdout/other stderr byte-exact and only the draft expected HASH address normalized. No complete helper/AST/language or independent broader admission.'}
target = ROOT / (PREFIX + 'final-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot final review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'final composed review drift'
print('Composed acceptance review PASS: runtime574/15/6, callbacks9/branches52/public9, paired9RED/574GREEN, consumers52/172, evidence5, instrument4, book57+32/3')
