"""One-shot original publication recovery before accepting diagnostic encoding."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
target = ROOT / (PREFIX + 'portability-recovery.json')
assert not target.exists(), 'one-shot original publication recovery'
packed_raw = (ROOT / (PREFIX + 'portability-first-candidate.json')).read_bytes()
packed = json.loads(packed_raw)
raw = gzip.decompress(decode(packed['data']))
assert packed['encoding'] == 'gzip-base64' and packed['bytes'] == len(raw) and packed['sha256'] == sha(raw)
assert gzip.compress(raw, mtime=0) == decode(packed['data'])
candidate = json.loads(raw)
assert candidate['base'] == BASE and len(candidate['staged_files']) == 75
captured = {}
for row in candidate['staged_files']:
    body = decode(row['data_base64'])
    assert row['sha256'] == sha(body) and row['bytes'] == len(body)
    assert row['path'] not in captured
    captured[row['path']] = body
assert candidate['staged_diff_sha256'] == sha(decode(candidate['staged_diff_base64']))
claim_raw = captured[CLAIM]
claim = json.loads(claim_raw)
bindings = claim['claims'][0]['durability']['inputs']
assert len(bindings) == 511 and len(claim_raw) == 119230
files = {}
for item in bindings:
    path = item['path']
    body = captured[path] if path in captured else subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    assert sha(body) == item['sha256'], ('complete original binding', path)
    files[path] = body
assert CLAIM not in files
files[CLAIM] = claim_raw
assert len(files) == 512
inputs = {path: sha(body) for path, body in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
command = ['python3', PREFIX + 'publish-claim.py']
rows = []
with tempfile.TemporaryDirectory(prefix='original-method-kind-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, body in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(body)
        destination.chmod(modes[path])
    for name in ('original', 'changed-diagnostic', 'restored'):
        altered = PREFIX + 'first-run-failures.json'
        (supplied / altered).write_bytes((ROOT / altered).read_bytes() if name == 'changed-diagnostic' else files[altered])
        selected = dict(inputs)
        selected[altered] = sha((supplied / altered).read_bytes())
        process = subprocess.run(command, cwd=supplied, capture_output=True)
        actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes()) for path in supplied.rglob('*') if path.is_file()}
        actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
        row = {'name': name, 'command': command, 'returncode': process.returncode,
               'stdout_base64': base64.b64encode(process.stdout).decode(),
               'stderr_base64': base64.b64encode(process.stderr).decode(),
               'inputs': selected, 'modes': modes, 'unchanged': actual == selected and actual_modes == modes}
        rows.append(row)
        (ROOT / (PREFIX + 'portability-recovery-reached.json')).write_text(json.dumps({'rows': rows}, indent=2) + '\n')
        assert row['unchanged']
        if name == 'changed-diagnostic':
            assert process.returncode != 0, 'original verifier must distinguish changed logical input'
        else:
            assert process.returncode == 0 and not process.stderr
            assert process.stdout == b'Method-kind publication PASS: 511 live inputs; 119230 bytes\n'
assert rows[0] == dict(rows[2], name='original')
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'candidate_sha256': sha(packed_raw), 'base': BASE, 'original_bindings': 511,
          'original_claim_bytes': 119230, 'logical_inputs': inputs, 'rows': rows,
          'scope': 'Complete first unaccepted publication recovered from the retained75-file candidate plus acceptedBASE Git inputs. Actual original512-input readonly publisher PASS, changed diagnostic input RED, exact restoration PASS. No original observation or producer is refreshed; no Git repository is created and all scratch stays on the repository volume.'}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Original method-kind publication recovery PASS:512 inputs; original/changed/restored actual commands')
