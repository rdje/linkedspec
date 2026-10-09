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
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = 'e0ebc8d24e6b473c74ad246873402ba9dcd7a3e3'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_empty_expression_spans.t'

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
    assert row['returncode'] != 0 and b'empty expression has ordered original public interval' in base64.b64decode(row['stderr_base64'])
    print('Original public empty-span semantic RED retained.')
elif mode == 'final':
    files = {p: (ROOT / p).read_bytes() for p in paths + [TEST]}
    row = run(mode, files)
    write(mode, row)
    assert row['returncode'] == 0, base64.b64decode(row['stderr_base64']).decode(errors='replace')
    controls = [
        ('restore-double-trim', ' my $remaining = length($text) - $leading;\n $trailing = $remaining if $trailing > $remaining;\n', '', 'empty expression has ordered original public interval'),
        ('wrong-ordered-anchor', '$trailing = $remaining if $trailing > $remaining;', '$leading = 0 if $trailing > $remaining;', 'empty expression has ordered original public interval'),
        ('drop-public-base', 'my $end = $base_start + length($text) - $trailing;', 'my $end = length($text) - $trailing;', 'empty expression has ordered original public interval'),
        ('consume-nonempty-body', '$trailing = $remaining if $trailing > $remaining;', '$trailing = $remaining;', 'nonempty original public text and interval remain exact'),
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
        'actionir_empty_expression_spans', 'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
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
