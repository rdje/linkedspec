"""Readonly retained proof of rehashed archive and forged byte-measurement denials."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
target = ROOT / (PREFIX + 'evidence-final.json')
command = ['python3', PREFIX + 'review-final.py']
paths = [PREFIX + 'knowledge-headers.md', PREFIX + 'extraction-final.json']
original = {p: (ROOT / p).read_bytes() for p in paths}

def invoke():
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()}

names = [('rehashed-historical-header', 'whole historical headers retained verbatim'),
         ('forged-finite-byte-count', 'exact finite Knowledge collection measurement'),
         ('rehashed-extra-eof-LF', 'exact one-LF archive normalization')]
if sys.argv[1:]:
    assert not target.exists(), 'one-shot current semantic controls'
    baseline = invoke()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64']), baseline
    rows = []
    for name, reason in names:
        extraction = json.loads(original[paths[1]])
        mutations = {}
        if name == 'rehashed-historical-header':
            changed = original[paths[0]].replace(b'id: perl-factory-capture-framework', b'id: forged-framework', 1)
            assert changed != original[paths[0]]
            extraction['archive_sha256'] = sha(changed)
            mutations[paths[0]] = changed
        elif name == 'forged-finite-byte-count':
            extraction['after_collection_bytes'] -= 1
        else:
            changed = original[paths[0]] + b'\n'
            extraction['archive_sha256'] = sha(changed)
            mutations[paths[0]] = changed
        mutations[paths[1]] = (json.dumps(extraction, indent=2) + '\n').encode()
        try:
            for path, raw in mutations.items():
                (ROOT / path).write_bytes(raw)
            result = invoke()
            assert result['returncode'] != 0 and reason.encode() in decode(result['stderr_base64']), (name, result)
            rows.append({'name': name, 'expected_reason': reason,
                         'mutated_bytes_base64': {p: base64.b64encode(raw).decode() for p, raw in mutations.items()}, **result})
        finally:
            for path, raw in original.items():
                (ROOT / path).write_bytes(raw)
        restored = invoke()
        assert restored == baseline, ('exact readonly restoration', name)
        rows[-1]['restoration'] = restored
    inputs = {p: sha((ROOT / p).read_bytes()) for p in paths + [PREFIX + 'review-final.py', PREFIX + 'review-final.json', PREFIX + 'evidence-final.py']}
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'command': command,
              'inputs': inputs, 'baseline': baseline, 'rows': rows,
              'scope': 'Actual archived-header corruption, a false collection count and an extra final LF with amended immediate digests reject for exact independent semantic reasons. All original artifact bytes restore, then readonly current acceptance passes exactly. Runtime, first native observations and original producers remain untouched. Default only reads retained channels/mutations and checks current identities.'}
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
assert report['command'] == command and report['baseline']['returncode'] == 0 and not decode(report['baseline']['stderr_base64'])
assert [(row['name'], row['expected_reason']) for row in report['rows']] == names
for row in report['rows']:
    assert row['returncode'] != 0 and row['expected_reason'].encode() in decode(row['stderr_base64'])
    assert row['restoration'] == report['baseline'] and row['mutated_bytes_base64']
    assert all(decode(value) != (ROOT / path).read_bytes() for path, value in row['mutated_bytes_base64'].items())
assert all(sha((ROOT / p).read_bytes()) == value for p, value in report['inputs'].items())
print('Finite FlowExpr evidence PASS: three reason-sensitive semantic denials; exact restoration')
