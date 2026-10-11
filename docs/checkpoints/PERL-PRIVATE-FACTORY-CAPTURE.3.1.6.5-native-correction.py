"""Retain the first warning and independently prove its sole spelling correction."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
PROBE = 't/actionir_hash_index_required_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'native-correction.json')
assert not target.exists(), 'one-shot diagnostic correction'
raw = (ROOT / (PREFIX + 'native.json')).read_bytes()
native = json.loads(raw)
draft = (ROOT / (PREFIX + 'native-draft-probe.pl')).read_bytes()
corrected = (ROOT / PROBE).read_bytes()
assert sha(draft) == native['inputs'][PROBE]
assert draft.count(b'map {encoded($_)} @_[0]') == 1
assert corrected == draft.replace(b'map {encoded($_)} @_[0]', b'encoded($_[0])')
assert native['returncode'] == 0 and native['unchanged']
assert base64.b64decode(native['stderr_base64'], validate=True) == (
    b'Scalar value @_[0] better written as $_[0] at ./t/actionir_hash_index_required_probe.pl line 107.\n')
inputs = dict(native['inputs'], **{PROBE: sha(corrected)})
files = {path: (ROOT / path).read_bytes() for path in inputs}
assert {path: sha(data) for path, data in files.items()} == inputs
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='hash-index-diagnostic-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, data in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
    result = subprocess.run(native['command'], cwd=supplied, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes())
                 for p in supplied.rglob('*') if p.is_file()} == inputs
report = {'producer_sha256': sha(Path(__file__).read_bytes()),
          'original_capture_sha256': sha(raw), 'original_probe_sha256': sha(draft),
          'corrected_probe_sha256': sha(corrected), 'inputs': inputs,
          'command': native['command'], 'returncode': result.returncode,
          'stdout_base64': base64.b64encode(result.stdout).decode(),
          'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
          'scope': 'First205-input runtime observations remain unchanged in native.json. Sole scalar-slice spelling correction removes the observed warning; independently captured supplied stdout must equal the complete original stdout bytes. No assertions or production edits precede this correction. The original outer producer exited1 at its no-diagnostics assertion; the original tool transport envelope is not independently retained, while full inner channels and producer are exact.'}
target.write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr and unchanged
assert result.stdout == base64.b64decode(native['stdout_base64'], validate=True), 'first native observations unchanged'
print('Hash-index diagnostic correction PASS: sole scalar spelling, full original stdout exact, no refreshed first observations')
