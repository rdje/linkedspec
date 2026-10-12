"""One-shot identical regression, complete-source faults and supplied consumers."""
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
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_named_dispatch_capture.t'
ADDED = ['t/actionir_named_dispatch_probe.pl', TEST, PREFIX + 'before-native.json']
OLD = b'my $lowered = $lowerer->($trimmed, $deps);'
NEW = b'my $lowered = _bind_emission_dependency($lowerer)->($trimmed, $deps);'
HELPER = b'sub _lower_block_side_effect_statement {'
NAMES = (
 b'_lower_scalar_assignment_operator_statement',
 b'_lower_array_append_operator_statement',
 b'_lower_array_end_mutation_method_statement',
 b'_lower_hash_index_assignment_operator_statement',
 b'_lower_set_key_statement',
 b'_lower_push_statement',
)
VARIANTS = ('inverse', 'opaque-code', 'copy-trimmed', 'copy-deps', 'list-context',
    'boolean-result', 'defined-result', 'reverse-order', 'late-name-resolution',
    'ast-guard', 'return-guard', 'set-fallback')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

def edit_helper(source, change):
    start = source.index(HELPER)
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    changed = change(body)
    assert changed != body
    return source[:start] + changed + source[end:]

def accepted_source(original):
    def bind(body):
        assert body.count(OLD) == 1 and NEW not in body
        return body.replace(OLD, NEW)
    source = edit_helper(original, bind)
    assert source.count(b'\n') == original.count(b'\n')
    return source

def variant(original, mode):
    if mode == 'before':
        return original
    source = accepted_source(original)
    if mode in ('green', 'consumers'):
        return source
    def change(body):
        if mode == 'inverse':
            return body.replace(NEW, OLD)
        replacements = {
            'opaque-code': (b'_bind_emission_dependency($lowerer)', b'_bind_emission_dependency(sub { return $lowerer->(@_) })'),
            'copy-trimmed': (b'->($trimmed, $deps)', b"->(($trimmed // '') . '', $deps)"),
            'copy-deps': (b'->($trimmed, $deps)', b'->($trimmed, {%$deps})'),
            'list-context': (b'_bind_emission_dependency($lowerer)', b'_bind_emission_dependency(sub { my @values = $lowerer->(@_); return $values[0] })'),
        }
        if mode in replacements:
            needle, value = replacements[mode]
            assert NEW.count(needle) == 1
            return body.replace(NEW, NEW.replace(needle, value))
        guard = b'return $lowered if defined($lowered) && length($lowered);'
        if mode in ('boolean-result', 'defined-result'):
            assert body.count(guard) == 2
            value = b'return $lowered if $lowered;' if mode == 'boolean-result' else b'return $lowered if defined($lowered);'
            return body.replace(guard, value, 1)
        if mode == 'reverse-order':
            lines = b''.join(b'  \\&' + name + b',\n' for name in NAMES)
            assert body.count(lines) == 1
            return body.replace(lines, b''.join(b'  \\&' + name + b',\n' for name in reversed(NAMES)))
        if mode == 'late-name-resolution':
            for name in NAMES:
                needle = b'\\&' + name + b','
                assert body.count(needle) == 1
                body = body.replace(needle, b'sub { return ' + name + b'(@_) },')
            return body
        if mode == 'ast-guard':
            needle = b'return $ast_assign_lowered if defined($ast_assign_lowered) && length($ast_assign_lowered);'
            assert body.count(needle) == 1
            return body.replace(needle, b'')
        if mode == 'return-guard':
            needle = b"return undef if $call && ($call->{method} // '') eq 'return';"
            assert body.count(needle) == 1
            return body.replace(needle, b'')
        if mode == 'set-fallback':
            needle = b"if ($call && (($call->{method} // '') eq 'set') && $trimmed =~ /^\\s*set\\s*\\(/o)"
            assert body.count(needle) == 1
            return body.replace(needle, needle.replace(b'if (', b'if (0 && ', 1))
        raise AssertionError('unknown source fault')
    return edit_helper(source, change)

assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + VARIANTS
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 243 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
original = files[MODULE]
assert (ROOT / MODULE).read_bytes() == (original if mode == 'before' else accepted_source(original))
source = variant(original, mode)
files[MODULE] = source
for path in ADDED:
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='named-dispatch-run-', dir=os.environ['TMPDIR']) as directory:
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
    'scope': 'All243 accepted predecessor runtime inputs plus unchanged named-dispatch diagnostic, identical regression and first native ledger. Complete real owner body executes with explicit localized selected callbacks and secondary controls, without full named-helper admission. One invocation expression changes only; full source variants/modes/syntax/channels are retained. Complete75 consumer commands append this suite. No public/private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in VARIANTS
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('Named-dispatch supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('Named-dispatch', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
