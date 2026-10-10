"""Retain and reject the initial wrong-claim preservation instrument.

The initial producer/result/reviewer stay byte-exact. Reproduce its own readonly
validation failure in an isolated supplied tree; never replay its mutation mode.
"""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4fde89c1958faf4057ab80eb7e7cd50962c7ac3c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4.json'
TARGET = ROOT / (PREFIX + 'initial-control-review.json')
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
checked = {}


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


producer = read(PREFIX + 'preservation-initial.py')
initial = read(PREFIX + 'preservation-initial.json')
reviewer = read(PREFIX + 'preservation-initial-reviewer.py')
original = read(CLAIM)
assert original == subprocess.check_output(['git', 'show', BASE + ':' + CLAIM], cwd=ROOT)
row = json.loads(initial)
assert row['claim'] == CLAIM and row['original_sha256'] == digest(original)
assert row['producer_sha256'] == digest(producer) and row['reviewer_sha256'] == digest(reviewer)
mutated = json.loads(original)
mutated['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
assert base64.b64decode(row['mutated_base64'], validate=True) == (json.dumps(mutated, indent=2) + '\n').encode()
assert row['unchanged'] is True
assert row['red']['returncode'] == row['restored']['returncode'] == 0
assert row['red'] == row['restored'], 'unrelated mutation must not affect actual reviewer result'
assert b'original283 preserved' in base64.b64decode(row['red']['stdout_base64'], validate=True)
assert not base64.b64decode(row['red']['stderr_base64'], validate=True)
fixed = read(PREFIX + 'preservation-control.py')
assert fixed == producer.replace(CLAIM.encode(), b'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2.json')
files = {PREFIX + 'preservation-control.py': producer,
         PREFIX + 'preservation-control.json': initial,
         PREFIX + 'review.py': reviewer, CLAIM: original}
population = {p: digest(raw) for p, raw in sorted(files.items())}
command = ['python3', PREFIX + 'preservation-control.py']
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot initial control review'
    with tempfile.TemporaryDirectory(prefix='initial-control-', dir=os.environ['TMPDIR']) as temporary:
        supplied = Path(temporary)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in files.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        result = subprocess.run(command, cwd=supplied,
                                env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        unchanged = {p.relative_to(supplied).as_posix(): digest(p.read_bytes())
                     for p in supplied.rglob('*') if p.is_file()} == population
    report = {'producer_sha256': digest(Path(__file__).read_bytes()), 'checked': dict(sorted(checked.items())),
              'command': command, 'inputs': population, 'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
              'scope': 'Initial unrelated-claim mutation restored exactly but produced no reviewer RED. Retain original instrument/result/reviewer, reconstruct mutation bytes and actual zero result, and reproduce the instrument readonly validation rejection. Corrected instrument differs only by the claim target; runtime fixtures/captures/production stay unchanged.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
assert report['producer_sha256'] == digest(Path(__file__).read_bytes())
assert report['checked'] == dict(sorted(checked.items())) and report['inputs'] == population
assert report['command'] == command and report['returncode'] != 0 and report['unchanged'] is True
assert not base64.b64decode(report['stdout_base64'], validate=True)
error = base64.b64decode(report['stderr_base64'], validate=True)
assert b"assert report['red']['command'] == COMMAND and report['red']['returncode'] != 0" in error
assert error.rstrip().endswith(b'AssertionError')
print('Initial preservation instrument review PASS: wrong target/no RED retained and readonly validation rejects')
