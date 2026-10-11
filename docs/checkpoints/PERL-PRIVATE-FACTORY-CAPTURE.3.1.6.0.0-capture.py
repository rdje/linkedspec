"""One-shot supplied public receiver-copy observations, paired TAP and consumers."""
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
BASE = '2b4e484a9bf27471d23d86f72aa25c7616b2bd3b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_receiver_scalar_copy.t'
PROBE = 't/actionir_receiver_scalar_copy_probe.pl'
assert sys.argv[1:] in ([mode] for mode in ('native', 'before', 'fixture', 'consumers'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture already exists'
seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {p: blob(p) for p in seed['inputs']}
assert len(files) == 182
assert {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
if mode in ('fixture', 'consumers'):
    files[MODULE] = (ROOT / MODULE).read_bytes()
else:
    assert (ROOT / MODULE).read_bytes() == files[MODULE], 'native proof must precede source edits'
for path in (PROBE, TEST):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
assert len(inputs) == 184
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
command = seed['command'] + [TEST] if mode == 'consumers' else (
    ['perl', '-Iperl', PROBE, 'observe'] if mode == 'native' else ['perl', '-Iperl', TEST])
with tempfile.TemporaryDirectory(prefix='receiver-scalar-copy-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    assert census(supplied) == inputs
    result = subprocess.run(command, cwd=supplied, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    unchanged = census(supplied) == inputs
    record = {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
              'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': inputs,
              'command': command, 'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
              'scope': 'Complete accepted182-file seed plus immutable public regression/probe,184 files. '
                       'Original native/before source is exact clean2b4e484a9; fixture/consumers overlay current MethodLowering only. '
                       'Live Get, actual standalone generated source/execution, typed AST poisoning, shape/shallow snapshot identity, '
                       'function/multi-step/scalar/legacy aggregate/arity controls. Complete generated source retained in actual observation channel. '
                       'No legacy kind-callback, required receiver or independent factory admission. Readonly toolchain, repository-volume scratch.'}
    target.write_text(json.dumps(record, indent=2) + '\n')
assert unchanged
if mode == 'native':
    assert result.returncode == 0
    observations = json.loads(result.stdout)
    assert observations['live'][1] == [] and observations['standalone'][1] == []
    assert observations['live'][2] == {'k': 'v', 'nested': [1, 2]}
    print('Original supplied receiver-copy observations retained;184 inputs')
elif mode != 'before':
    assert result.returncode == 0
    print('Supplied receiver-copy', mode, 'PASS;184 inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', result.stdout, re.MULTILINE)
    assert len(plans) == 1
    names = re.findall(rb'^(?:not )?ok (\d+) - (.*)$', result.stdout, re.MULTILINE)
    assert [int(n) for n, _ in names] == list(range(1, int(plans[0]) + 1))
    failed = re.findall(rb'^not ok \d+ - (.*)$', result.stdout, re.MULTILINE)
    assert result.returncode != 0 and failed
    print('Original supplied RED retained:', len(failed), 'semantic failures /', int(plans[0]), 'complete TAP assertions')
