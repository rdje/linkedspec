"""Retain supplied MethodExpr input-capture proof and source interventions on the repo volume."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = '8f0cdaec69b80ce5a8f4edfd783199693498bae1'
PARSER = 'perl/LinkedSpec/ActionIR/MethodExpr.pm'
TEST = 't/actionir_method_input_captures.t'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def write(name, value):
    (ROOT / (PREFIX + name + '.json')).write_text(json.dumps(value, indent=2) + '\n')

def run(name, files):
    with tempfile.TemporaryDirectory(prefix='ast-input-', dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        for p, raw in files.items():
            target = root / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        result = subprocess.run(['perl', '-Iperl', TEST], cwd=root,
                                env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return {'name': name, 'command': ['perl', '-Iperl', TEST], 'returncode': result.returncode,
                'stdout_base64': base64.b64encode(result.stdout).decode(),
                'stderr_base64': base64.b64encode(result.stderr).decode(),
                'inputs': {p: digest(raw) for p, raw in sorted(files.items())}}

mode = sys.argv[1]
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = [p for p in paths if p and (ROOT / p).is_file()]
if mode == 'original':
    files = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in paths}
    files[TEST] = (ROOT / TEST).read_bytes()
    row = run(mode, files)
    write(mode, row)
    assert row['returncode'] != 0 and b'actual MethodExpr input captures are available' in base64.b64decode(row['stderr_base64'])
    print('Original private MethodExpr input interface RED retained.')
elif mode == 'final':
    files = {p: (ROOT / p).read_bytes() for p in paths + [TEST]}
    row = run(mode, files)
    write(mode, row)
    assert row['returncode'] == 0, base64.b64decode(row['stderr_base64']).decode(errors='replace')
    controls = [('no-input-scope', 'local $_input_capture_scope = {captures => {}};', 'local $_input_capture_scope;', 'actual original input occurrence intervals'), ('copy-direct-aliases', 'my $framed = _collect_method_source_frames($callback, \\@_);', 'my @copied = @_; my $framed = _collect_method_source_frames($callback, \\@copied);', 'direct input scalar alias preserved'), ('change-legacy-aliases', 'my ($callback, @args) = @_;\n return _collect_method_source_frames($callback, \\@args)', 'my $callback = shift;\n return _collect_method_source_frames($callback, \\@_)', 'legacy wrapper copied scalar behavior preserved'), ('no-callback-check', '&& _same_input_reference($record->{callback}, $callback)', '&& 1', 'foreign input callback denied'), ('no-array-check', '&& _same_input_reference($record->{arguments}, $arguments)', '&& 1', 'copied CSV input argument array denied'), ('no-capture-value-check', '&& _same_input_reference($record->{value}, $capture->{value})', '&& 1', 'changed capture result denied'), ('no-method-fields', 'for my $field (qw(method source_method source)) {', 'for my $field () {', 'changed method input root denied'), ('no-method-args-check', 'return undef unless _same_input_reference($value->{args}, $arguments);', '', 'changed method argument reference denied'), ('no-shape-check', '&& @$arguments == $record->{count} && $index < @$arguments;', '&& $index < @$arguments;', 'changed input array shape denied'), ('no-value-check', '&& $value eq $frame->{raw};', '&& 1;', 'changed input occurrence denied'), ('shared-input-description', 'return _copy_input_frame($frame)\n}', 'return $frame\n}', 'input description detached from authority'), ('no-input-unwind', 'local $_input_capture_scope = {captures => {}};', '$_input_capture_scope = {captures => {}};', 'input scope restored after nested success'), ('shift-private-span', 'source_span => {%{$frame->{source_span}}}}', 'source_span => {start => $frame->{source_span}{start} + 1, end => $frame->{source_span}{end}}}', 'actual original input occurrence intervals')]
    rows = []
    for name, old, new, reason in controls:
        assert files[PARSER].count(old.encode()) == 1, name
        changed = dict(files)
        changed[PARSER] = files[PARSER].replace(old.encode(), new.encode(), 1)
        observed = run(name, changed)
        observed.update(source=PARSER, old=old, new=new, required_failure=reason)
        rows.append(observed)
        write('inverses', rows)
        error = base64.b64decode(observed['stderr_base64']).decode(errors='replace')
        assert observed['returncode'] != 0 and reason in error, (name, error)
        assert 'syntax error' not in error and 'Compilation failed' not in error, name
    print('Final MethodExpr input GREEN and', len(rows), 'effective source inverses retained.')
elif mode == 'consumers':
    tests = ['t/' + name + '.t' for name in (
        'actionir_method_input_captures', 'actionir_method_argument_source_frames', 'actionir_empty_expression_spans', 'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
        'canonical_event_occurrence_order', 'actionir_nested_block_source_spans',
        'actionir_compiler_source_membership', 'actionir_executable_source_membership',
        'trace_actionir_method_lowering', 'trace_emit_context_bridge')]
    tests += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']
    paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs', 't'], cwd=ROOT).decode().split('\0')
    inputs = {p: digest((ROOT / p).read_bytes()) for p in paths + tests + [PREFIX + 'proof.py'] if p and (ROOT / p).is_file()}
    result = subprocess.run(['prove', '-v', '-Iperl'] + tests, cwd=ROOT,
                            env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    row = {'name': mode, 'command': ['prove', '-v', '-Iperl'] + tests,
           'returncode': result.returncode, 'inputs': inputs,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'unchanged': all(digest((ROOT / p).read_bytes()) == h for p, h in inputs.items()),
           'scope': 'Guarded live parent Perl/spec/test superset; standard toolchain and published dependency outputs reused. No immutable full Phase0/dependency reproduction claim.'}
    write(mode, row)
    assert row['unchanged'], 'consumer inputs changed'
    print('Direct consumers exit', result.returncode)
    raise SystemExit(result.returncode)
else:
    raise SystemExit('original|final|consumers required')
