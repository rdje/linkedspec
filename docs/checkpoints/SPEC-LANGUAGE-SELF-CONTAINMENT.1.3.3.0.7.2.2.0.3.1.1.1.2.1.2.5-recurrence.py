"""Rerun the complete selected private consumer tree from immutable clean Git bytes."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '42e00f840059db5bd4e602aee7a3b5d1e366b97b'
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5-'
SEED = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1-consumers.json'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_empty_expression_spans.t'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()
def channels(result):
    return {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}

def census(root):
    return {p.relative_to(root).as_posix(): digest(p.read_bytes()) for p in root.rglob('*') if p.is_file()}

seed_raw = subprocess.check_output(['git', 'show', BASE + ':' + SEED], cwd=ROOT)
seed = json.loads(seed_raw)
files = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in seed['inputs']}
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
assert inputs == seed['inputs'] and len(inputs) == 133
with tempfile.TemporaryDirectory(prefix='private-recurrence-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    for p, raw in files.items():
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    assert census(supplied) == inputs
    environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
    result = subprocess.run(seed['command'], cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    row = dict(channels(result), command=seed['command'], inputs=inputs, base=BASE,
               seed=SEED, seed_sha256=digest(seed_raw), unchanged=census(supplied) == inputs,
               producer_sha256=digest(Path(__file__).read_bytes()),
               scope='Fourteen selected suites in133 immutable supplied Git files. Standard read-only Perl/prove modules and project-volume TMPDIR reused. No full Phase0, toolchain or dependency reproduction claim.')
    (ROOT / (PREFIX + 'consumers.json')).write_text(json.dumps(row, indent=2) + '\n')
    assert row['unchanged'] and result.returncode == 0
    old = b' my $remaining = length($text) - $leading;\n $trailing = $remaining if $trailing > $remaining;\n'
    assert files[PARSER].count(old) == 1
    changed = files[PARSER].replace(old, b'', 1)
    (supplied / PARSER).write_bytes(changed)
    command = ['perl', '-Iperl', TEST]
    result = subprocess.run(command, cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    inverse = dict(channels(result), command=command, source=PARSER, old=old.decode(), new='',
                   inputs=dict(inputs, **{PARSER: digest(changed)}))
    (ROOT / (PREFIX + 'source-inverse.json')).write_text(json.dumps(inverse, indent=2) + '\n')
    assert result.returncode == 18 and b'empty expression has ordered original public interval' in result.stderr
print('Immutable133-file/fourteen-suite recurrence PASS; actual restored-trim semantic RED18 retained.')
