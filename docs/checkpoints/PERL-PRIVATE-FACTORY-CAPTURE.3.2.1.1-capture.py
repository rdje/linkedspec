"""One-shot source-bound paired trim captures over the accepted consumer seed."""
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
BASE = '354c15530fd1445ebfa8c6c0683e7b8d066caced'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_dropped_trim_probe.pl'
COLD = 't/actionir_dropped_trim_cold_probe.pl'
TEST = 't/actionir_dropped_trim_capture.t'
NATIVE = PREFIX + 'native.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([mode] for mode in ('before', 'current', 'fixture', 'consumers'))
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 211
files = {p: old(p) for p in seed['inputs']}
assert {p: sha(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
if mode != 'before':
    files[MODULE] = (ROOT / MODULE).read_bytes()
for p in (PROBE, COLD) if mode == 'current' else (PROBE, COLD, TEST, NATIVE):
    assert p not in files
    files[p] = (ROOT / p).read_bytes()
inputs = {p: sha(raw) for p, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='dropped-trim-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for p, raw in files.items():
        destination = supplied / p
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    command = seed['command'] + [TEST] if mode == 'consumers' else (
        ['perl', '-Iperl', './' + PROBE, 'observe'] if mode == 'current' else ['perl', '-Iperl', TEST])
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == inputs
record = {'base': BASE, 'seed': SEED, 'seed_sha256': sha(seed_raw),
    'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs, 'command': command,
    'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode(), 'unchanged': unchanged,
    'scope': 'Accepted211-file final consumer capsule plus immutable two probes (current213) or probes/assertion fixture/original native JSON (paired/consumers215). Only the direct required trim invocation is overlaid for current/fixture/consumers; before uses accepted original source. Fresh native probe subprocesses preserve native Perl die handle/record suffixes. Complete channels and exact supplied input identities are retained; secondary helpers are controlled, not complete AST/helper/language admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert unchanged, 'supplied capsule mutation'
if mode == 'current':
    assert process.returncode == 0 and not process.stderr, 'current probe must complete cleanly'
elif mode in ('before', 'fixture'):
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(number) for _, number, _ in rows] == list(range(1, int(plans[0]) + 1)), 'complete paired TAP'
    failures = [label.decode() for failed, _, label in rows if failed]
    assert (process.returncode != 0 and failures) if mode == 'before' else (process.returncode == 0 and not failures and not process.stderr)
    print(mode, 'complete TAP:', int(plans[0]), 'assertions;', len(failures), 'RED')
else:
    assert process.returncode == 0 and b'Result: PASS' in process.stdout and b'All tests successful.' in process.stdout
    headers = re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', process.stdout, re.M)
    assert headers == [p.encode() for p in command[3:]], 'complete ordered supplied suite paths'
    assert len(re.findall(rb'^1\.\.\d+$', process.stdout, re.M)) == len(headers)
    assert process.stderr == base64.b64decode(seed['stderr_base64']), 'unchanged predecessor diagnostic bytes'
print('Dropped trim', mode, 'capture PASS:', len(inputs), 'supplied inputs')
