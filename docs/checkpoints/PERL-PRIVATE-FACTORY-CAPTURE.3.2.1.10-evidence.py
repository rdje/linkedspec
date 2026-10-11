"""Readonly evidence review; --capture observes four named RED/restorations once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
TARGET = ROOT / (PREFIX + 'evidence.json')
REACHED = ROOT / (PREFIX + 'evidence-reached.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
encode = lambda value: (json.dumps(value, indent=2) + '\n').encode()
assert sys.argv[1:] in ([], ['--capture'])
CASES = [('forged-original-beyond-freeze', 'exact original full publication'),
         ('censored-membership-reason', 'actual original membership RED'),
         ('stale-corrected-body', 'sole historical population correction'),
         ('changed-book-beyond-report', 'wrong book input population/content')]


def run():
    command = ['python3', PREFIX + 'accepted-review.py']
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode, 'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr)}


def changes(name):
    originals, mutated = {}, {}

    def get(path):
        originals[path] = (ROOT / path).read_bytes()
        return json.loads(originals[path])

    def put(path, value):
        mutated[path] = encode(value)

    if name == 'forged-original-beyond-freeze':
        path = PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json'
        value = get(path)
        value['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        put(path, value)
        path2 = PREFIX + 'freeze.json'
        value = get(path2)
        value['records'][0]['original_sha256'] = sha(mutated[path])
        put(path2, value)
    elif name == 'censored-membership-reason':
        path = PREFIX + 'recovery-final.json'
        value = get(path)
        row = next(row for row in value['rows'] if row['name'] == 'omitted-origin')
        err = base64.b64decode(row['stderr_base64'])
        assert b'complete original live intersection census' in err
        row['stderr_base64'] = b64(err.replace(b'complete original live intersection census', b'ERASED'))
        put(path, value)
        path2 = PREFIX + 'recovery-final-reached.json'
        reached = get(path2)
        assert [row['name'] for row in reached['rows']] == [row['name'] for row in value['rows']]
        reached['rows'] = value['rows']
        put(path2, reached)
    elif name == 'stale-corrected-body':
        path = PREFIX + 'corrected-body.py'
        originals[path] = (ROOT / path).read_bytes()
        mutated[path] = (ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-review.py').read_bytes()
    else:
        assert name == 'changed-book-beyond-report'
        originals[BOOK] = (ROOT / BOOK).read_bytes()
        mutated[BOOK] = originals[BOOK] + b'\nEvidence control.\n'
        path = PREFIX + 'book-review.json'
        value = get(path)
        value['source_inputs'][BOOK] = sha(mutated[BOOK])
        put(path, value)
    path = PREFIX + 'accepted-review.json'
    value = get(path)
    for changed, raw in mutated.items():
        assert changed in value['input_metadata']
        value['input_metadata'][changed] = sha(raw)
    put(path, value)
    assert set(originals) == set(mutated)
    return originals, mutated


if sys.argv[1:]:
    assert not TARGET.exists() and not REACHED.exists()
    healthy = run()
    assert healthy['returncode'] == 0 and not base64.b64decode(healthy['stderr_base64'])
    rows = []
    for name, reason in CASES:
        originals, mutated = changes(name)
        try:
            for path, raw in mutated.items():
                (ROOT / path).write_bytes(raw)
            denied = run()
        finally:
            for path, raw in originals.items():
                (ROOT / path).write_bytes(raw)
        restored = run()
        rows.append({'name': name, 'reason': reason, 'denied': denied, 'restored': restored,
                     'original_sha256': {p: sha(raw) for p, raw in originals.items()}, 'mutated_base64': {p: b64(raw) for p, raw in mutated.items()}})
        REACHED.write_bytes(encode({'healthy': healthy, 'rows': rows}))
        TARGET.write_bytes(encode({'result': 'pending', 'healthy': healthy, 'rows': rows}))
        assert denied['returncode'] != 0 and reason.encode() in base64.b64decode(denied['stderr_base64']), ('actual named evidence RED', name)
        assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64']), ('actual exact restoration', name)
        assert all((ROOT / p).read_bytes() == raw for p, raw in originals.items())
    paths = [PREFIX + tail for tail in ('evidence.py', 'accepted-review.py', 'accepted-review.json', 'book-review.py')]
    report = {'result': 'PASS', 'healthy': healthy, 'rows': rows, 'producer_sha256': sha(Path(__file__).read_bytes()),
              'inputs': {p: sha((ROOT / p).read_bytes()) for p in paths},
              'scope': 'Four actual reason-sensitive original/source/semantic-reason/book REDs beyond updated immediate report hashes; full damaged records and actual denied/restored channels retained. Every original is restored byte-for-byte; no capture or original observation refreshed.'}
    TARGET.write_bytes(encode(report))
else:
    report = json.loads(TARGET.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
assert json.loads(REACHED.read_bytes()) == {'healthy': report['healthy'], 'rows': report['rows']}
assert report['healthy']['returncode'] == 0 and not base64.b64decode(report['healthy']['stderr_base64'])
assert len(report['rows']) == len(CASES)
for row, (name, reason) in zip(report['rows'], CASES):
    originals, mutated = changes(name)
    assert row['name'] == name and row['reason'] == reason
    assert row['original_sha256'] == {p: sha(raw) for p, raw in originals.items()}
    assert row['mutated_base64'] == {p: b64(raw) for p, raw in mutated.items()}, 'exact damaged-record reconstruction'
    assert row['denied']['command'] == row['restored']['command'] == ['python3', PREFIX + 'accepted-review.py']
    assert row['denied']['returncode'] != 0 and reason.encode() in base64.b64decode(row['denied']['stderr_base64'])
    assert row['restored']['returncode'] == 0 and not base64.b64decode(row['restored']['stderr_base64'])
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in report['inputs'].items())
print('Fixed claim census evidence PASS: four named REDs beyond immediate hashes and exact restorations')
