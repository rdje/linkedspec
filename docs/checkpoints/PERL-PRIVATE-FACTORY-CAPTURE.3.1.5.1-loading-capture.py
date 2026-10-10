"""Retain a rejected unloaded-owner fixture and actual public lazy-loading control."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2c5f84092d91c808ab82b4b886b51e65fc1ac864'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-consumers.json'
TARGET = ROOT / (PREFIX + 'loading-capture.json')
assert not TARGET.exists(), 'one-shot diagnosis already captured'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
files = {p: blob(p) for p in seed['inputs']}
assert len(files) == 170 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items())
for tail in ('loading-draft.t', 'loading-probe.pl'):
    path = PREFIX + tail
    files[path] = (ROOT / path).read_bytes()
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
assert len(inputs) == 172
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
with tempfile.TemporaryDirectory(prefix='return-loading-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for p, raw in files.items():
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for tail in ('loading-draft.t', 'loading-probe.pl'):
        command = ['perl', '-Iperl', PREFIX + tail]
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True, check=False)
        row = {'command': command, 'returncode': result.returncode,
               'stdout_base64': base64.b64encode(result.stdout).decode(),
               'stderr_base64': base64.b64encode(result.stderr).decode(),
               'unchanged': all((supplied / p).read_bytes() == raw for p, raw in files.items())}
        rows.append(row)
        assert row['unchanged']
        if tail.endswith('.t'):
            assert result.returncode == 255 and not re.search(rb'^1\.\.', result.stdout, re.M)
            assert b'Undefined subroutine &LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr' in result.stderr
            assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', result.stdout, re.M)] == list(range(1, 29))
        else:
            assert result.returncode == 0 and not result.stderr
            assert json.loads(result.stdout) == {'before': {'loaded': 0, 'callback': 0}, 'after': {'loaded': 1, 'callback': 1}, 'value': 'return 1'}
report = {'result': 'PASS-diagnosis-only', 'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
          'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': inputs, 'rows': rows,
          'scope': 'Original170 accepted Git inputs plus rejected fixture/public loading probe in172 supplied files. Draft stops after28 assertions with no TAP plan because the direct private owner is not loaded; the actual public Toolbox call changes owner loaded/callback from0 to1 and returns ordinary return1. Full raw channels retained, including process-local Test::More reference diagnostics. This is a fixture bootstrap error, not callback acceptance or a runtime defect. Explicit owner import is required before direct private fixtures.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Loading diagnosis retained: partial28/no-plan rejected fixture; actual public lazy-loading control0-to1; no runtime admission')
