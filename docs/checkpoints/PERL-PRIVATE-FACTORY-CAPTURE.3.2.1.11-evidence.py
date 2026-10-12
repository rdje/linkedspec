"""Readonly semantic evidence controls; --capture runs once and restores exact bytes."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
TARGET = ROOT / (PREFIX + 'evidence.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()

def review():
    command = ['python3', PREFIX + 'review.py']
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()}

def packed(raw):
    return {'encoding': 'gzip-base64', 'sha256': sha(raw), 'bytes': len(raw),
        'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot semantic control capture'
    baseline = review()
    assert baseline['returncode'] == 0 and not base64.b64decode(baseline['stderr_base64'])
    after_path = PREFIX + 'after.json'
    current_path = PREFIX + 'current.json'
    card_path = 'docs/knowledge/perl-method-block-component-capture.md'
    originals = {path: read(path) for path in (after_path, current_path, card_path)}
    rows = []
    try:
        for name in ('forged-public-verdict', 'orphan-current-header'):
            damage = {}
            if name == 'forged-public-verdict':
                record = json.loads(originals[after_path])
                observed = json.loads(base64.b64decode(record['rows'][0]['stdout_base64']))
                case = next(row for row in observed['rows'] if row['name'] == 'orphan-after-reverify')
                assert case['check']['status'] == 256
                case['check']['status'] = 0
                record['rows'][0]['stdout_base64'] = base64.b64encode((json.dumps(observed) + '\n').encode()).decode()
                damage[after_path] = (json.dumps(record, indent=2) + '\n').encode()
                reason = b'semantic public verdict'
            else:
                lines = originals[card_path].splitlines(keepends=True)
                position = next(index for index, line in enumerate(lines) if line.startswith(b'reverify:'))
                lines.insert(position + 1, b'  - detached forged command\n')
                damage[card_path] = b''.join(lines)
                current = json.loads(originals[current_path])
                current['inputs'][card_path] = sha(damage[card_path])
                damage[current_path] = (json.dumps(current, indent=2) + '\n').encode()
                reason = b'current Knowledge orphan list'
            for path, raw in damage.items():
                (ROOT / path).write_bytes(raw)
            result = review()
            rows.append({'name': name, 'damage': {path: packed(raw) for path, raw in damage.items()},
                'expected_reason': reason.decode(), 'actual': result})
            assert result['returncode'] != 0 and reason in base64.b64decode(result['stderr_base64']), (name, result)
            for path, raw in originals.items():
                (ROOT / path).write_bytes(raw)
            assert all(read(path) == raw for path, raw in originals.items())
            restored = review()
            assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64'])
            rows[-1]['restored'] = restored
    finally:
        for path, raw in originals.items():
            (ROOT / path).write_bytes(raw)
    inputs = json.loads(read(PREFIX + 'review.json'))['input_metadata']
    inputs = dict(inputs, **{PREFIX + 'review.json': sha(read(PREFIX + 'review.json')),
        PREFIX + 'evidence.py': sha(Path(__file__).read_bytes())})
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
        'baseline': baseline, 'rows': rows, 'inputs': inputs,
        'restored_sha256': {path: sha(raw) for path, raw in originals.items()},
        'scope': 'Actual deeper semantic denials reject a forged native verdict and a malformed current header after its immediate current-input hash is amended; exact byte restoration and actual readonly PASS follow each control.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert all(sha(read(path)) == value for path, value in report['inputs'].items())
    assert all(sha(read(path)) == value for path, value in report['restored_sha256'].items())
    assert [row['name'] for row in report['rows']] == ['forged-public-verdict', 'orphan-current-header']
    for row in report['rows']:
        assert row['actual']['returncode'] != 0
        assert row['expected_reason'].encode() in base64.b64decode(row['actual']['stderr_base64'], validate=True)
        assert row['restored']['returncode'] == 0 and not base64.b64decode(row['restored']['stderr_base64'])
        for data in row['damage'].values():
            raw = gzip.decompress(base64.b64decode(data['data'], validate=True))
            assert len(raw) == data['bytes'] and sha(raw) == data['sha256']
print('Knowledge semantic evidence PASS: two actual distinguishing denials and exact restorations')
