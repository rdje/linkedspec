"""One-shot immutable native, paired TAP and supplied array callback consumer captures."""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'c90b99a831461e25adbc2b34d7da7d3deed11531'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_array_receiver_required_probe.pl'
COLD = 't/actionir_array_receiver_required_cold_probe.pl'
TEST = 't/actionir_array_receiver_required_capture.t'
NATIVE = PREFIX + 'native.json'
assert sys.argv[1:] in ([m] for m in ('native', 'current', 'before', 'fixture', 'consumers'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(files) == 187 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (PROBE, COLD) if mode in ('native', 'current') else (PROBE, COLD, TEST, NATIVE):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == (189 if mode in ('native', 'current') else 191)
inputs = {path: digest(raw) for path, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot result already retained: ' + mode
with tempfile.TemporaryDirectory(prefix='array-required-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    assert census(supplied) == inputs
    command = (seed['command'] + [TEST] if mode == 'consumers'
               else ['perl', '-Iperl', './' + PROBE, 'observe'] if mode in ('native', 'current')
               else ['perl', '-Iperl', TEST])
    result = subprocess.run(command, cwd=supplied, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
           'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': inputs,
           'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'unchanged': census(supplied) == inputs,
           'scope': 'Accepted187-file Git seed. Native/current supply189 inputs including immutable main/cold probes; paired TAP and direct consumers additionally supply assertion fixture/native JSON reader,191 inputs. Only the required array-normalizer resolver return is overlaid for current/fixture/consumers. Complete channels and supplied input identities are retained. Public Toolbox generated-source rows are secondary controls; complete helper/AST/language, optional/direct, full private and canonical admissions remain separately owned.'}
    target.write_text(json.dumps(row, indent=2) + '\n')
assert row['unchanged'], 'capture mutated supplied inputs'
if mode in ('native', 'current'):
    assert result.returncode == 0 and not result.stderr, 'native/current probe failed'
    value = json.loads(result.stdout)
    assert len(value['callbacks']) == 8 and len(value['branches']) == 34
    assert len(value['authority']) == 4 and len(value['public']) == 2
    assert value['cold']['returncode'] == 0 and not value['cold']['stderr']
    print('Array required', mode, 'PASS: callbacks8/branches34/authority4/public2/cold2;189 supplied inputs')
elif mode in ('before', 'fixture'):
    plans = re.findall(rb'^1\.\.(\d+)$', result.stdout, re.MULTILINE)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', result.stdout, re.MULTILINE)
    assert len(plans) == 1 and [int(n) for failed, n, label in rows] == list(range(1, int(plans[0]) + 1)), 'complete paired TAP'
    failures = [label.decode() for failed, n, label in rows if failed]
    if mode == 'before':
        assert result.returncode != 0 and failures, 'original isolation must be RED'
    else:
        assert result.returncode == 0 and not failures and not result.stderr, 'current fixture must be GREEN without diagnostics'
    print('Array required', mode, 'PASS:', int(plans[0]), 'assertions;', len(failures), 'RED;', len(inputs), 'inputs')
else:
    assert result.returncode == 0 and b'All tests successful.' in result.stdout and b'Result: PASS' in result.stdout
    assert len(re.findall(rb'^t/.*\.t$', result.stdout, re.MULTILINE)) == 62, 'complete supplied suite population'
    print('Array required consumers PASS62 suites/191 supplied inputs')
