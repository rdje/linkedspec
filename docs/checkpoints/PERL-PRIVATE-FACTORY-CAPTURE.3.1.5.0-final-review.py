"""Compose readonly runtime/book reviews and verify actual evidence controls."""
import base64
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0'
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
path = PREFIX + 'inverse-bare-required.json'
inverse = json.loads(original[path])
inverse['stdout_base64'] = base64.b64encode(base64.b64decode(inverse['stdout_base64']).replace(
    inverse['distinguishing_reason'].encode(), b'unrelated assertion')).decode()
index = json.loads(original[PREFIX + 'inverses.json'])
index['rows'][0]['sha256'] = digest((json.dumps(inverse, indent=2) + '\n').encode())
expected = [
    ('failed-positive', {PREFIX + 'fixture.json': positive}, 'positive bare/mutation required capture failed'),
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
assert b'PASS455/11/6' in base64.b64decode(restored['stdout_base64'], validate=True)
assert not base64.b64decode(restored['stderr_base64'], validate=True)

rows = []
for tail in ('review.py', 'book-review.py', 'preservation-control.py', 'flow-review.py'):
    path = PREFIX + tail
    read(path)
    result = subprocess.run(['python3', path], cwd=ROOT,
                            env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    rows.append({'command': ['python3', path], 'returncode': result.returncode,
                 'stdout_base64': base64.b64encode(result.stdout).decode(),
                 'stderr_base64': base64.b64encode(result.stderr).decode()})
    assert result.returncode == 0, (tail, result.stderr)
flow = json.loads(read(PREFIX + 'flow-review.json'))
assert flow['result'] == 'PASS' and len(flow['rows']) == 6
for path, expected_hash in flow['checked'].items():
    assert digest(read(path)) == expected_hash, 'native flow input identity'
diagnostic = json.loads(read(PREFIX + 'flow-replay-diagnostic.json'))
assert diagnostic['result'] == 'diagnostic-only'
assert diagnostic['producer_sha256'] == digest(read(PREFIX + 'flow-replay-diagnostic.py'))
assert len(diagnostic['rows']) == 6
original_flow = json.loads(read(PREFIX + 'flow-capture.json'))['rows'] + json.loads(read(PREFIX + 'flow-capture-fixed.json'))['rows']
for index, (row, original_row) in enumerate(zip(diagnostic['rows'], original_flow)):
    assert row['command'] == original_row['command'] and row['inputs'] == original_row['inputs']
    assert row['unchanged'] is True and row['returncode'] == original_row['returncode']
    out, err = [base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64')]
    old_out, old_err = [base64.b64decode(original_row[key], validate=True) for key in ('stdout_base64', 'stderr_base64')]
    assert out == old_out, 'diagnostic stdout drift'
    if index == 5:
        import re
        pattern = rb"(?m)^#     \$expected->\[0\] = ARRAY\(0x[0-9a-fA-F]+\)$"
        assert len(re.findall(pattern, err)) == len(re.findall(pattern, old_err)) == 1
        assert err != old_err and re.sub(pattern, b'<expected ARRAY address>', err) == re.sub(pattern, b'<expected ARRAY address>', old_err)
        assert row['matches_original'] is False
    else:
        assert err == old_err and row['matches_original'] is True
book = json.loads(read(PREFIX + 'book-review.json'))
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
read(PREFIX + 'book.json'); read(PREFIX + 'book.py')
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'scope': 'Fresh actual readonly required runtime/book/preservation/flow reviews and exact five evidence-control counterfactual/channel identities. Original299 main input identities remain exact. Flow argument-premise rejection and all original/fixed169-file channels are retained/replayed; all stdout is exact and only one actual Test::More expected ARRAY address in mutant stderr is normalized, with complete raw channels retained. Complete native9/branch58 ledgers, identical455 assertion populations and six effective source faults admit only two required resolver returns. Optional package-flow repair stays separately owned under .3.2.0.'}
target = ROOT / (PREFIX + 'final-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot final review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'final composed review drift'
print('Composed acceptance review PASS: runtime455/11/6, callbacks9/branches58, paired9RED/455GREEN, consumers50/170, evidence5, flow16/169/replays6, book57+32/3')
