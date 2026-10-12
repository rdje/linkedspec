"""One-shot identical regression, complete-source faults and predecessor consumers."""
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
BASE = '99f2939ac1d5e543bc2aa7f9c38b8166d5d510cc'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_tracking_predicate_capture.t'
ADDED = ['t/actionir_tracking_predicate_probe.pl', TEST, PREFIX + 'before-native.json']
OLD = b"return ref($predicate) eq 'CODE' && $predicate->($target) ? 1 : 0"
NEW = b"return ref($predicate) eq 'CODE' && _bind_emission_dependency($predicate)->($target) ? 1 : 0"
HELPERS = {'receiver': '_receiver_mutation_target_is_tracked', 'nested': '_nested_write_target_is_tracked'}
VARIANTS = ('inverse-receiver', 'inverse-nested', 'opaque-code', 'copy-target', 'code-guard', 'early-lookup', 'reread-selection', 'list-context', 'raw-return', 'defined-truth')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
def edit_helper(source, owner, transform):
    start = source.index(('sub ' + HELPERS[owner] + ' {').encode())
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    changed = transform(body)
    assert changed != body
    return source[:start] + changed + source[end:]
def variant(original, mode):
    assert original.count(OLD) == 2
    for owner in HELPERS:
        start = original.index(('sub ' + HELPERS[owner] + ' {').encode())
        end = original.index(b'\nsub ', start + 1)
        assert original[start:end].count(OLD) == 1
    accepted = original.replace(OLD, NEW)
    if mode == 'before': return original
    if mode in ('green', 'consumers'): return accepted
    if mode.startswith('inverse-'):
        return edit_helper(accepted, mode.removeprefix('inverse-'), lambda body: body.replace(NEW, OLD))
    source = accepted
    for owner in HELPERS:
        def change(body):
            assert body.count(NEW) == 1
            line = NEW
            if mode == 'opaque-code': line = line.replace(b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency(sub { return $predicate->(@_) })')
            elif mode == 'copy-target': line = line.replace(b'->($target)', b"->(($target // '') . '')")
            elif mode == 'code-guard': line = line.replace(b"ref($predicate) eq 'CODE' && ", b'')
            elif mode == 'reread-selection':
                role = b'receiver_mutation_target' if owner == 'receiver' else b'nested_write_target'
                line = line.replace(b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency($deps->{' + role + b'})')
            elif mode == 'list-context': line = line.replace(b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency(sub { my @value = $predicate->(@_); return $value[0] })')
            elif mode == 'raw-return': line = line.replace(b' ? 1 : 0', b'')
            elif mode == 'defined-truth': line = line.replace(b'_bind_emission_dependency($predicate)->($target)', b'defined(_bind_emission_dependency($predicate)->($target))')
            elif mode == 'early-lookup':
                guard = b' return 0 unless defined($target) && $target =~ /\\A[A-Za-z_][A-Za-z0-9_]*\\z/o;\n'
                assert body.count(guard) == 1
                selection = next(x for x in body.splitlines(keepends=True) if b'my $predicate =' in x)
                return body.replace(guard, b'').replace(selection, selection + guard)
            else: raise AssertionError(mode)
            return body.replace(NEW, line)
        source = edit_helper(source, owner, change)
    return source
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + VARIANTS
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 237 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
source = files[MODULE]
assert (ROOT / MODULE).read_bytes() == variant(source, 'before' if mode == 'before' else 'green')
source = variant(source, mode)
files[MODULE] = source
for path in ADDED:
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='tracking-predicate-run-', dir=os.environ['TMPDIR']) as directory:
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
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes()) for path in supplied.rglob('*') if path.is_file()}
    actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
channels = lambda result: {'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode()}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'module_base64': base64.b64encode(source).decode(), 'syntax_command': syntax_command,
    'syntax': channels(syntax), 'command': command, **channels(process),
    'unchanged': actual == inputs and actual_modes == modes,
    'scope': 'All237 accepted predecessor inputs plus predicate diagnostic, identical regression and first native ledger. Two real predicate helpers and immediate guard/assignment consumers execute without stubs; B local-slot identity is readonly. Complete source variants, modes, syntax and channels retained. Complete73 consumer commands append the new suite. No full-helper/private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in VARIANTS
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('Tracking-predicate supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('Tracking-predicate', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
