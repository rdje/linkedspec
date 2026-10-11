"""One-shot native, paired TAP and path-complete supplied package-flow captures."""
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
BASE = '4cc0b5a2a39ef3eec8baafbf874e43bd855e8b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_package_flow_probe.pl'
COLD = 't/actionir_package_flow_cold_probe.pl'
TEST = 't/actionir_package_flow_capture.t'
NATIVE = PREFIX + 'native.json'
assert sys.argv[1:] in ([name] for name in ('native', 'current', 'before', 'fixture', 'consumers'))
mode = sys.argv[1]
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {path.relative_to(directory).as_posix(): sha(path.read_bytes())
            for path in sorted(directory.rglob('*')) if path.is_file()}


seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {path: old(path) for path in sorted(seed['inputs'])}
assert len(files) == 207 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
if mode not in ('native', 'before'):
    files[MODULE] = (ROOT / MODULE).read_bytes()
for path in (PROBE, COLD) if mode in ('native', 'current') else (PROBE, COLD, TEST, NATIVE):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == (209 if mode in ('native', 'current') else 211)
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
target = ROOT / (PREFIX + mode + '-final.json')
assert not target.exists(), 'one-shot result already retained: ' + mode
with tempfile.TemporaryDirectory(prefix='package-flow-required-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
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
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': sha(seed_raw),
           'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs,
           'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'unchanged': census(supplied) == inputs,
           'scope': 'Accepted207-file Git consumer seed. Native/current additionally supply immutable main/cold probes,209 inputs; paired TAP/direct consumers also supply assertion fixture/native JSON,211 inputs. Only the direct package-flow invocation are overlaid for current/fixture/consumers. Complete channels and every supplied input identity retained. Public Toolbox rows are generated-source controls; optional/direct, complete helper/AST/language/private and canonical admissions remain separately owned.'}
    target.write_text(json.dumps(row, indent=2) + '\n')
assert row['unchanged'], 'capture mutated supplied inputs'
if mode in ('native', 'current'):
    assert result.returncode == 0 and not result.stderr, 'native/current probe failed'
    observed = json.loads(result.stdout)
    assert len(observed['callbacks']) == 4 and len(observed['branches']) == len({row['name'] for row in observed['branches']}) > 0
    assert len(observed['authority']) == 2 and len(observed['public']['rows']) == 2
    assert observed['cold']['returncode'] == 0 and not observed['cold']['stderr']
    print('Package-flow', mode, 'PASS:', len(observed['callbacks']), 'callbacks;', len(observed['branches']), 'branches; authority2/public2/cold2;209 supplied inputs')
elif mode in ('before', 'fixture'):
    plans = re.findall(rb'^1\.\.(\d+)$', result.stdout, re.MULTILINE)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', result.stdout, re.MULTILINE)
    assert len(plans) == 1 and [int(number) for failed, number, label in rows] == list(range(1, int(plans[0]) + 1)), 'complete paired TAP'
    failures = [label.decode() for failed, number, label in rows if failed]
    if mode == 'before':
        assert result.returncode != 0 and failures, 'original isolation must be RED'
    else:
        assert result.returncode == 0 and not failures and not result.stderr, 'current fixture must be GREEN without diagnostics'
    print('Package-flow', mode, 'PASS:', int(plans[0]), 'assertions;', len(failures), 'RED;', len(inputs), 'inputs')
else:
    assert result.returncode == 0 and b'All tests successful.' in result.stdout and b'Result: PASS' in result.stdout
    headers = re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', result.stdout, re.MULTILINE)
    assert headers == [path.encode() for path in command[3:]], 'every ordered supplied command path/header'
    assert len(re.findall(rb'^1\.\.\d+$', result.stdout, re.MULTILINE)) == len(headers) == 67, 'complete suite plans'
    assert result.stderr == base64.b64decode(seed['stderr_base64'], validate=True), 'unchanged predecessor diagnostic stream'
    print('Package-flow consumers PASS67 suites/211 supplied inputs')
