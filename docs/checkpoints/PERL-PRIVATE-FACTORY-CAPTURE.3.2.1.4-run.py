"""One-shot identical regression, full-source variants and all predecessor consumers."""
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
BASE = 'dd82f9cbced8311dca8ea8610282780e0c0adf3e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-consumers-final.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_source_assignment_kind_capture.t'
ADDED = ['t/actionir_source_assignment_kind_probe.pl', TEST, PREFIX + 'before-native.json']
READ_OLD = b"my $kind = $bare_symbol_kind->($name);"
READ_NEW = b"my $kind = _bind_emission_dependency(ref($bare_symbol_kind) eq 'CODE' ? $bare_symbol_kind : sub { return $bare_symbol_kind->(@_) })->($name);"
ASSIGN_OLD = b"if (($bare_symbol_kind->($target_name) // '') eq 'scalar') {"
ASSIGN_NEW = b"if ((_bind_emission_dependency(ref($bare_symbol_kind) eq 'CODE' ? $bare_symbol_kind : sub { return $bare_symbol_kind->(@_) })->($target_name) // '') eq 'scalar') {"
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
variants = ('inverse-read', 'inverse-assign', 'opaque-code', 'direct-noncode', 'read-late', 'assign-early', 'copy-name', 'list-context', 'remove-read-reserved')
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + variants
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 230 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
source = files[MODULE]
assert source.count(READ_OLD) == source.count(ASSIGN_OLD) == 1
accepted = source.replace(READ_OLD, READ_NEW).replace(ASSIGN_OLD, ASSIGN_NEW)
if mode == 'before':
    assert (ROOT / MODULE).read_bytes() == source, 'native source before production edits'
else:
    assert (ROOT / MODULE).read_bytes() == accepted, 'only two optional invocation lines'
    source = accepted
if mode == 'inverse-read': source = source.replace(READ_NEW, READ_OLD)
elif mode == 'inverse-assign': source = source.replace(ASSIGN_NEW, ASSIGN_OLD)
elif mode in ('opaque-code', 'direct-noncode', 'list-context'):
    term = b"ref($bare_symbol_kind) eq 'CODE' ? $bare_symbol_kind : sub { return $bare_symbol_kind->(@_) }"
    replacement = b'$bare_symbol_kind' if mode == 'direct-noncode' else b'sub { return $bare_symbol_kind->(@_) }'
    if mode == 'list-context': replacement = b'sub { my @result = $bare_symbol_kind->(@_); return $result[0] }'
    for line in (READ_NEW, ASSIGN_NEW):
        assert line.count(term) == source.count(line) == 1
        source = source.replace(line, line.replace(term, replacement))
elif mode == 'read-late':
    source = source.replace(READ_NEW, READ_NEW.replace(b'$bare_symbol_kind', b"$deps->{bare_symbol_kind}"))
elif mode == 'assign-early':
    start = source.index(b'sub _lower_assign_statement {')
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    block = b"  my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')\n   ? $deps->{bare_symbol_kind}\n   : sub { return undef };\n"
    anchor = b' my $target_trimmed = $trim_action_ir_value->($target);'
    assert body.count(block) == body.count(anchor) == 1
    body = body.replace(block, b'').replace(anchor, block + anchor)
    source = source[:start] + body + source[end:]
elif mode == 'copy-name':
    source = source.replace(READ_NEW, READ_NEW.replace(b'->($name)', b"->($name . '')"))
    source = source.replace(ASSIGN_NEW, ASSIGN_NEW.replace(b'->($target_name)', b"->($target_name . '')"))
elif mode == 'remove-read-reserved':
    line = b' return undef if $name =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o;'
    assert source.count(line) == 1
    source = source.replace(line, b'')
files[MODULE] = source
for path in ADDED:
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='source-assignment-kind-run-', dir=os.environ['TMPDIR']) as directory:
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
    'scope': 'All230 accepted predecessor inputs plus the unchanged diagnostic producer/regression and first native ledger. Identical fixture and complete source/modes/channels retained. Complete original71 consumer commands append the new suite. Variants alter supplied complete source only; original native observations/producers remain unchanged. No full-helper/private/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in variants
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('Source-assignment-kind supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('Source-assignment-kind', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
