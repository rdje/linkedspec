"""Readonly evidence review; --capture observes six exact RED/restorations once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
TARGET = ROOT / (PREFIX + 'evidence.json')
REACHED = ROOT / (PREFIX + 'evidence-reached.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
assert sys.argv[1:] in ([], ['--capture'])
CASES = [
    ('failed-positive', 'review.py', 'positive fixture must pass'),
    ('censored-fault-reason', 'review.py', 'all fault assertion labels preserved'),
    ('false-native-authority', 'review.py', 'actual callback authority and ordinary identities'),
    ('omitted-checkpoint-command', 'consumer-review.py', 'complete supplied consumer command population'),
    ('forged-original-beyond-freeze-sha', 'review.py', 'original full trim publication'),
    ('changed-book-beyond-report-sha', 'review.py', 'wrong book input population/content'),
]


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def run(tail):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr)}


def changes(name):
    originals, mutated = {}, {}

    def get(path):
        originals[path] = (ROOT / path).read_bytes()
        return json.loads(originals[path])

    def put(path, value):
        mutated[path] = encode(value)

    if name == 'failed-positive':
        path = PREFIX + 'fixture.json'
        value = get(path)
        stdout = base64.b64decode(value['stdout_base64'])
        assert stdout.startswith(b'ok 1 - ')
        value['stdout_base64'] = b64(b'not ' + stdout)
        put(path, value)
    elif name == 'censored-fault-reason':
        path = PREFIX + 'inverse-wrapper-identity.json'
        value = get(path)
        reason = value['required_reason']
        stdout = base64.b64decode(value['fixture']['stdout_base64'])
        assert stdout.count(reason.encode()) == 1
        value['fixture']['stdout_base64'] = b64(stdout.replace(reason.encode(), b'ERASED', 1))
        assert value['failures'].count(reason) == 1
        value['failures'] = ['ERASED' if label == reason else label for label in value['failures']]
        put(path, value)
        index_path = PREFIX + 'inverses.json'
        index = get(index_path)
        next(row for row in index['rows'] if row['name'] == 'wrapper-identity')['artifact_sha256'] = sha(mutated[path])
        put(index_path, index)
    elif name == 'false-native-authority':
        path = PREFIX + 'current.json'
        value = get(path)
        observed = json.loads(base64.b64decode(value['stdout_base64']))
        assert observed['authority'][0]['actual_map_identity'] == 1
        observed['authority'][0]['actual_map_identity'] = 0
        value['stdout_base64'] = b64(json.dumps(observed).encode())
        put(path, value)
    elif name == 'omitted-checkpoint-command':
        path = PREFIX + 'consumers.json'
        value = get(path)
        checkpoint = next(p for p in value['command'][3:] if p.startswith('docs/checkpoints/'))
        value['command'].remove(checkpoint)
        put(path, value)
        report_path = PREFIX + 'consumer-review.json'
        report = get(report_path)
        report['capture_sha256'] = sha(mutated[path])
        put(report_path, report)
    elif name == 'forged-original-beyond-freeze-sha':
        path = PREFIX + 'before-trim.json'
        value = get(path)
        value['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        put(path, value)
        freeze_path = PREFIX + 'freeze.json'
        freeze = get(freeze_path)
        freeze['original_sha256'] = sha(mutated[path])
        put(freeze_path, freeze)
    else:
        assert name == 'changed-book-beyond-report-sha'
        originals[BOOK] = (ROOT / BOOK).read_bytes()
        mutated[BOOK] = originals[BOOK] + b'\nEvidence control.\n'
        report_path = PREFIX + 'book-review.json'
        report = get(report_path)
        report['source_inputs'][BOOK] = sha(mutated[BOOK])
        put(report_path, report)
    # Rehash immediate composed-review metadata. Each control must reach its
    # independent semantic/population/original-input guard beyond these hashes.
    review_path = PREFIX + 'review.json'
    review = get(review_path)
    for path, raw in mutated.items():
        assert path in review['input_metadata'], ('declared reviewed input', path)
        review['input_metadata'][path] = sha(raw)
    put(review_path, review)
    assert set(originals) == set(mutated)
    return originals, mutated


if sys.argv[1:]:
    assert not TARGET.exists() and not REACHED.exists(), 'one-shot evidence capture'
    healthy = run('review.py')
    assert healthy['returncode'] == 0 and not base64.b64decode(healthy['stderr_base64'])
    rows = []
    for name, oracle, reason in CASES:
        originals, mutated = changes(name)
        try:
            for path, raw in mutated.items():
                (ROOT / path).write_bytes(raw)
            denied = run(oracle)
        finally:
            for path, raw in originals.items():
                (ROOT / path).write_bytes(raw)
        restored = run('review.py')
        row = {'name': name, 'oracle': oracle, 'reason': reason, 'denied': denied,
               'restored': restored, 'original_sha256': {p: sha(raw) for p, raw in originals.items()},
               'mutated_base64': {p: b64(raw) for p, raw in mutated.items()}}
        rows.append(row)
        REACHED.write_bytes(encode({'healthy': healthy, 'rows': rows}))
        TARGET.write_bytes(encode({'result': 'pending', 'healthy': healthy, 'rows': rows}))
        assert denied['returncode'] != 0 and reason.encode() in base64.b64decode(denied['stderr_base64']), ('actual distinguishing evidence RED', name, denied)
        assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64']), ('exact restoration', name)
        assert all((ROOT / p).read_bytes() == raw for p, raw in originals.items())
    paths = {PREFIX + 'evidence.py', PREFIX + 'review.py', PREFIX + 'review.json',
             PREFIX + 'consumer-review.py', PREFIX + 'book-review.py'}
    report = {'result': 'PASS', 'healthy': healthy, 'rows': rows,
        'inputs': {p: sha((ROOT / p).read_bytes()) for p in sorted(paths)},
        'producer_sha256': sha(Path(__file__).read_bytes()),
        'scope': 'Six actual independent semantic/population/original-input REDs after rehashing immediate review metadata; complete damaged records and actual denied/restored channels retained. Every original file is restored byte-for-byte before the next case. No original observation or production code is refreshed.'}
    TARGET.write_bytes(encode(report))
else:
    report = json.loads(TARGET.read_bytes())

assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
assert json.loads(REACHED.read_bytes()) == {'healthy': report['healthy'], 'rows': report['rows']}
assert report['healthy']['returncode'] == 0 and not base64.b64decode(report['healthy']['stderr_base64'])
assert len(report['rows']) == len(CASES)
for row, (name, oracle, reason) in zip(report['rows'], CASES):
    assert (row['name'], row['oracle'], row['reason']) == (name, oracle, reason)
    originals, mutated = changes(name)
    assert row['original_sha256'] == {p: sha(raw) for p, raw in originals.items()}
    assert row['mutated_base64'] == {p: b64(raw) for p, raw in mutated.items()}, 'exact evidence counterfactual reconstruction'
    assert row['denied']['command'] == ['python3', PREFIX + oracle]
    assert row['denied']['returncode'] != 0 and reason.encode() in base64.b64decode(row['denied']['stderr_base64'])
    assert row['restored']['command'] == ['python3', PREFIX + 'review.py']
    assert row['restored']['returncode'] == 0 and not base64.b64decode(row['restored']['stderr_base64'])
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in report['inputs'].items())
actual = run('review.py')
assert actual['returncode'] == 0 and not base64.b64decode(actual['stderr_base64']), 'actual healthy readonly review'
print('Small optional-kind evidence PASS: six reason-sensitive REDs beyond updated immediate hashes; exact restoration')
