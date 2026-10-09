"""Retain supplied native-frame proof and source interventions on the repo volume."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = '0d52a407c4c508cfb00d45765471f741a10de616'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_ast_input_frames.t'

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
    assert row['returncode'] != 0 and b'native AST input frames are available' in base64.b64decode(row['stderr_base64'])
    print('Original native-frame availability RED retained.')
elif mode == 'final':
    files = {p: (ROOT / p).read_bytes() for p in paths + [TEST]}
    row = run(mode, files)
    write(mode, row)
    assert row['returncode'] == 0, base64.b64decode(row['stderr_base64']).decode(errors='replace')
    controls = [
        ('no-native-record', 'input => $frame});', 'input => undef});', 'twins root uses original input trim, not public base'),
        ('public-base-as-input', 'my $input_start = $parent->{start} + $start - $base_start;', 'my $input_start = $parent->{start} + $start;', 'twins root uses original input trim, not public base'),
        ('no-csv-frames', '($parts, $frames) = @{$capture}{qw(arguments source_frames)};', '$parts = $capture->{arguments}; $frames = [];', 'twins actual argument occurrence follows CSV flush frame'),
        ('no-parent-rebase', 'start => $input->{start} + $span->{start}, end => $input->{start} + $span->{end},', 'start => $span->{start}, end => $span->{end},', 'twins actual argument occurrence follows CSV flush frame'),
        ('reuse-first-twin', '$frames->[$index++]', '$frames->[0]', 'twins actual argument occurrence follows CSV flush frame'),
        ('public-coordinate-authority', 'source_span => {start => $input->{start}, end => $input->{end}}}', 'source_span => {start => $node->{source_span}{start}, end => $node->{source_span}{end}}}', 'twins root uses original input trim, not public base'),
        ('foreign-callback-source', '$root->{root}{source} eq $entry->{input_source};', '1;', 'foreign input has no native original frame'),
        ('foreign-native-root', '_same_construction_reference($root->{root}, $input->{root})', '1', 'foreign native input root cannot borrow parent frame'),
        ('no-provided-frame', 'my $provided = $_provided_parse_input;', 'my $provided = undef;', 'twins actual argument occurrence follows CSV flush frame'),
        ('shared-native-description', 'return {source => $input->{root}{source}, raw => $input->{raw},', 'return $input->{_description} ||= {source => $input->{root}{source}, raw => $input->{raw},', 'native frame description detached'),
        ('no-expression-unwind', 'local $_construction_input = ref($_construction_recorder)', '$_construction_input = ref($_construction_recorder)', 'unsupported split preserves its explicit native root'),
    ]
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
    print('Final native-frame GREEN and', len(rows), 'effective source inverses retained.')
elif mode == 'consumers':
    tests = ['t/' + name + '.t' for name in (
        'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
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
