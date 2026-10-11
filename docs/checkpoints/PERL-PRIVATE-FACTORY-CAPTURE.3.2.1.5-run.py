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
BASE = '15197dfdf0f198a4eb25517e278edba491d12db7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_ast_optional_capture.t'
ADDED = ['t/actionir_ast_optional_probe.pl', 't/actionir_ast_optional_stable_probe.pl', TEST, PREFIX + 'before-stable-native.json']
PIPE_OLD = b'my $lowered = $lower_array_pipeline_expr->($node->{source}, $node->{source_span});'
PIPE_NEW = b'my $lowered = _bind_emission_dependency($lower_array_pipeline_expr)->($node->{source}, $node->{source_span});'
ASSIGN_OLD = b'my $lowered = $lower_assign_statement->($effective_args->[0], $effective_args->[1]);'
ASSIGN_NEW = b"my $lowered = _bind_emission_dependency(ref($lower_assign_statement) eq 'CODE' ? $lower_assign_statement : sub { return $lower_assign_statement->(@_) })->($effective_args->[0], $effective_args->[1]);"
VARIANTS = ('inverse-pipeline', 'inverse-assign', 'opaque-code', 'direct-noncode', 'copy-source', 'copy-span', 'copy-effective', 'list-context', 'assign-early', 'pipeline-guard', 'fallback-map')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + VARIANTS
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 233 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
source = files[MODULE]
assert source.count(PIPE_OLD) == source.count(ASSIGN_OLD) == 1
accepted = source.replace(PIPE_OLD, PIPE_NEW).replace(ASSIGN_OLD, ASSIGN_NEW)
if mode == 'before':
    assert (ROOT / MODULE).read_bytes() == source, 'original RED precedes production edits'
else:
    assert (ROOT / MODULE).read_bytes() == accepted, 'only two optional invocation lines'
    source = accepted
if mode == 'inverse-pipeline':
    source = source.replace(PIPE_NEW, PIPE_OLD)
elif mode == 'inverse-assign':
    source = source.replace(ASSIGN_NEW, ASSIGN_OLD)
elif mode in ('opaque-code', 'direct-noncode', 'list-context'):
    term = b"ref($lower_assign_statement) eq 'CODE' ? $lower_assign_statement : sub { return $lower_assign_statement->(@_) }"
    replacement = b'$lower_assign_statement' if mode == 'direct-noncode' else b'sub { return $lower_assign_statement->(@_) }'
    if mode == 'list-context':
        replacement = b'sub { my @result = $lower_assign_statement->(@_); return $result[0] }'
    source = source.replace(ASSIGN_NEW, ASSIGN_NEW.replace(term, replacement))
    if mode != 'direct-noncode':
        replacement = b'sub { return $lower_array_pipeline_expr->(@_) }'
        if mode == 'list-context':
            replacement = b'sub { my @result = $lower_array_pipeline_expr->(@_); return $result[0] }'
        source = source.replace(PIPE_NEW, PIPE_NEW.replace(b'_bind_emission_dependency($lower_array_pipeline_expr)', b'_bind_emission_dependency(' + replacement + b')'))
elif mode == 'copy-source':
    source = source.replace(PIPE_NEW, PIPE_NEW.replace(b'->($node->{source},', b"->(($node->{source} // '') . '',"))
elif mode == 'copy-span':
    source = source.replace(PIPE_NEW, PIPE_NEW.replace(b'$node->{source_span});', b"(ref($node->{source_span}) eq 'HASH' ? {%{$node->{source_span}}} : $node->{source_span}));"))
elif mode == 'copy-effective':
    source = source.replace(ASSIGN_NEW, ASSIGN_NEW.replace(b'->($effective_args->[0], $effective_args->[1])', b"->(($effective_args->[0] // '') . '', ($effective_args->[1] // '') . '')"))
elif mode in ('assign-early', 'fallback-map'):
    start = source.index(b'sub _lower_ast_call_statement {')
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    block = b"  my $lower_assign_statement = (ref($deps) eq 'HASH' && ref($deps->{lower_assign_statement}) eq 'CODE')\n   ? $deps->{lower_assign_statement}\n   : sub { return _lower_assign_statement($_[0], $_[1], $deps) };\n"
    assert body.count(block) == 1
    if mode == 'assign-early':
        anchor = b'  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);'
        assert body.count(anchor) == 1
        body = body.replace(block, b'').replace(anchor, block + anchor)
    else:
        body = body.replace(block, block.replace(b'$_[1], $deps)', b'$_[1], {})'))
    source = source[:start] + body + source[end:]
elif mode == 'pipeline-guard':
    start = source.index(b'sub _lower_ast_block_side_effect_statement {')
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    guard = b"if (ref($lower_array_pipeline_expr) eq 'CODE') {"
    assert body.count(guard) == 1
    source = source[:start] + body.replace(guard, b'if (1) {') + source[end:]
files[MODULE] = source
for path in ADDED:
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='ast-optional-run-', dir=os.environ['TMPDIR']) as directory:
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
    'scope': 'All233 accepted predecessor inputs plus both original/stable diagnostic producers, unchanged regression and first stable native ledger. Identical complete fixture/source/modes/channels retained. Complete72 consumer commands append the new suite. Faults alter supplied complete source only; first native observations/producers remain exact. Secondary helpers remain controls. No full-helper/private/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in VARIANTS
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('AST-optional supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('AST-optional', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
