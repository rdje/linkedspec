"""One-shot paired, full-source fault and complete supplied consumer captures."""
import base64
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
LEGACY = 't/actionir_small_kind_capture.t'
PROBE = 't/actionir_uniform_target_probe.pl'
TEST = 't/actionir_uniform_target.t'
OLD = rb'return undef unless $target_expr =~ /^\Q$container\E\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;'
NEW = OLD.replace(b'$/o;', b'$/;')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([m] for m in ('before', 'green', 'consumers', 'inverse', 'unquoted', 'hardcoded'))
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot result'
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {p: old(p) for p in seed['inputs']}
assert len(files) == 223 and {p: sha(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p not in (MODULE, LEGACY))
assert files[MODULE].count(OLD) == 1
if mode == 'before':
    assert all((ROOT / p).read_bytes() == files[p] for p in (MODULE, LEGACY))
else:
    files[MODULE] = (ROOT / MODULE).read_bytes()
    assert files[MODULE] == old(MODULE).replace(OLD, NEW), 'sole dynamic regex repair'
    files[LEGACY] = (ROOT / LEGACY).read_bytes()
for path in (PROBE, TEST):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
if mode == 'inverse':
    files[MODULE] = files[MODULE].replace(NEW, OLD)
elif mode == 'unquoted':
    files[MODULE] = files[MODULE].replace(NEW, NEW.replace(rb'\Q$container\E', b'$container'))
elif mode == 'hardcoded':
    files[MODULE] = files[MODULE].replace(NEW, NEW.replace(b'$container', b'array'))
inputs = {p: sha(raw) for p, raw in sorted(files.items())}
modes = {p: stat.S_IMODE((ROOT / p).stat().st_mode) for p in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='uniform-target-run-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    syntax_command = ['perl', '-c', '-Iperl', MODULE]
    syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, capture_output=True)
    command = seed['command'] + [TEST] if mode == 'consumers' else ['perl', '-Iperl', TEST]
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
    actual_modes = {p: stat.S_IMODE((supplied / p).stat().st_mode) for p in actual}
channels = lambda result: {'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(),
    'stderr_base64': base64.b64encode(result.stderr).decode()}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'module_base64': base64.b64encode(files[MODULE]).decode(),
    'legacy_fixture_base64': base64.b64encode(files[LEGACY]).decode(),
    'syntax_command': syntax_command, 'syntax': channels(syntax), 'command': command,
    **channels(process), 'unchanged': actual == inputs and actual_modes == modes,
    'scope': 'Complete223 accepted consumer inputs plus the new probe/fixture. Paired new fixture is identical; current source differs by sole interpolated-regex /o removal. Current legacy fixture migrates only the retained container-empty observation. Three full-source variants retain exact executed source, syntax and command channels. Consumers append the new suite to every original69 ordered command path. No full-private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0, 'unchanged supplied capsule / valid full source'
red = mode in ('before', 'inverse', 'unquoted', 'hardcoded')
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode != 'consumers':
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(r[1]) for r in rows] == list(range(1, int(plans[0]) + 1)), 'complete numeric TAP'
    print('Container-target', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(r[0]) for r in rows), 'RED')
else:
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64']), 'unchanged predecessor diagnostic channel'
    print('Container-target complete supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
