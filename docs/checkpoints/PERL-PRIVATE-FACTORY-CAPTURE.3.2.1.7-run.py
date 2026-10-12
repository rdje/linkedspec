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
BASE = 'b1133da422bbf19b54818c97c2b67a5e6a402012'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_formal_trim_capture.t'
ADDED = ['t/actionir_formal_trim_probe.pl', TEST, PREFIX + 'before-native.json']
ARGUMENT = b"ref($trim_action_ir_value) eq 'CODE' ? $trim_action_ir_value : sub { return $trim_action_ir_value->(@_) }"
BOUND = b'_bind_emission_dependency(' + ARGUMENT + b')'
OLD_FIRST = b'my $trimmed = $trim_action_ir_value->($expr);'
OLD_RECEIVER = b'my $receiver = $trim_action_ir_value->(substr($trimmed, 0, $idx));'
OLD_CALL = b'my $call_expr = $trim_action_ir_value->(substr($trimmed, $idx + 1));'
OLD = {'brace-first': OLD_FIRST, 'dot-first': OLD_FIRST, 'dot-receiver': OLD_RECEIVER, 'dot-call': OLD_CALL}
NEW = {site: line.replace(b'$trim_action_ir_value->(', BOUND + b'->(', 1) for site, line in OLD.items()}
HELPERS = {'brace': '_extract_outer_brace_payload', 'dot': '_split_receiver_dot_method_expr'}
SITES = {'brace': ('brace-first',), 'dot': ('dot-first', 'dot-receiver', 'dot-call')}
VARIANTS = tuple('inverse-' + site for site in OLD) + ('opaque-code', 'direct-noncode', 'copy-expr', 'copy-receiver', 'copy-call', 'list-context', 'early-receiver-guard', 'brace-depth', 'dot-quote', 'dot-decimal')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

def edit_helper(source, owner, change):
    start = source.index(('sub ' + HELPERS[owner] + ' {').encode())
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    changed = change(body)
    assert changed != body
    return source[:start] + changed + source[end:]

def accepted_source(original):
    source = original
    for owner, sites in SITES.items():
        def bind(body):
            for site in sites:
                assert body.count(OLD[site]) == 1 and body.count(NEW[site]) == 0
                body = body.replace(OLD[site], NEW[site])
            return body
        source = edit_helper(source, owner, bind)
    assert source.count(b'\n') == original.count(b'\n')
    return source

def variant(original, mode):
    if mode == 'before':
        return original
    source = accepted_source(original)
    if mode in ('green', 'consumers'):
        return source
    if mode.startswith('inverse-'):
        site = mode.removeprefix('inverse-')
        return edit_helper(source, site.split('-')[0], lambda body: body.replace(NEW[site], OLD[site]))
    owners = ('brace',) if mode == 'brace-depth' else ('dot',) if mode in ('copy-receiver', 'copy-call', 'early-receiver-guard', 'dot-quote', 'dot-decimal') else tuple(HELPERS)
    for owner in owners:
        def change(body):
            if mode == 'early-receiver-guard':
                guard = b'  return undef unless defined($receiver) && length($receiver);\n'
                anchor = b'  ' + NEW['dot-receiver'] + b'\n'
                assert body.count(guard) == body.count(anchor) == 1
                return body.replace(guard, b'').replace(anchor, anchor + guard)
            if mode == 'brace-depth':
                assert body.count(b'++$depth;') == 1
                return body.replace(b'++$depth;', b'$depth = 1;')
            if mode == 'dot-quote':
                needle = b"if ($ch eq \"'\") { $in_single_quote = 1; next; }"
                assert body.count(needle) == 1
                return body.replace(needle, needle.replace(b'= 1;', b'= 0;'))
            if mode == 'dot-decimal':
                needle = b'next if $prev_ch =~ /\\d/o && $next_ch =~ /\\d/o;'
                assert body.count(needle) == 1
                return body.replace(needle, needle.replace(b'next if ', b'next if 0 && '))
            for site in SITES[owner]:
                line = NEW[site]
                if mode in ('opaque-code', 'direct-noncode', 'list-context'):
                    term = b'$trim_action_ir_value' if mode == 'direct-noncode' else b'sub { return $trim_action_ir_value->(@_) }'
                    if mode == 'list-context':
                        term = b'sub { my @values = $trim_action_ir_value->(@_); return $values[0] }'
                    line = line.replace(ARGUMENT, term)
                elif mode == 'copy-expr' and site.endswith('-first'):
                    line = line.replace(b'->($expr)', b"->(($expr // '') . '')")
                elif mode == 'copy-receiver' and site == 'dot-receiver':
                    line = line.replace(b'->(substr($trimmed, 0, $idx))', b"->(('' . substr($trimmed, 0, $idx)))")
                elif mode == 'copy-call' and site == 'dot-call':
                    line = line.replace(b'->(substr($trimmed, $idx + 1))', b"->(('' . substr($trimmed, $idx + 1)))")
                if line != NEW[site]:
                    assert body.count(NEW[site]) == 1
                    body = body.replace(NEW[site], line)
            return body
        source = edit_helper(source, owner, change)
    return source

assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + VARIANTS
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 240 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
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
with tempfile.TemporaryDirectory(prefix='formal-trim-run-', dir=os.environ['TMPDIR']) as directory:
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
    'scope': 'All240 accepted predecessor runtime inputs plus unchanged formal diagnostic, identical regression and first native ledger. Complete real brace/dot helper bodies execute without stubs. Four invocation expressions change only; complete source variants/modes/syntax/full channels retained. Complete74 consumer commands append this suite. No complete helper/public/private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in VARIANTS
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('Formal-trim supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('Formal-trim', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
