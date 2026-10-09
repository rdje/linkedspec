"""Run isolated foundation fixtures and effective production-source inverses."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1'
PREFIX = 'docs/checkpoints/' + OWNER
ORIGINS = 'perl/LinkedSpec/ActionIR/SourceOrigins.pm'
EMISSIONS = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_source_emissions.t'
BASE = 'a367b66f06b1deacefc172484834b7cd9b1093d1'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def run(name, files):
    # Only these supplied project files are visible on the module search path.
    # Standard Perl/core modules are required read-only toolchain dependencies.
    with tempfile.TemporaryDirectory(prefix='emission-', dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        for path, raw in files.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        env = dict(os.environ, PERL5LIB='', PERL5OPT='')
        result = subprocess.run(['perl', '-Iperl', TEST], cwd=root, env=env,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return {'name': name, 'returncode': result.returncode,
                'stdout_base64': base64.b64encode(result.stdout).decode(),
                'stderr_base64': base64.b64encode(result.stderr).decode(),
                'inputs': [{'path': p, 'sha256': digest(raw), 'bytes': len(raw)}
                           for p, raw in sorted(files.items())]}


def write(name, value):
    (ROOT / (PREFIX + '-' + name + '.json')).write_text(json.dumps(value, indent=2) + '\n')


def inverse(files, name, old, new, reason, source=EMISSIONS):
    changed = dict(files)
    raw = changed[source]
    assert raw.count(old.encode()) == 1, name
    changed[source] = raw.replace(old.encode(), new.encode(), 1)
    row = run(name, changed)
    row.update(source=source, old=old, new=new, required_failure=reason)
    stderr = base64.b64decode(row['stderr_base64']).decode(errors='replace')
    assert row['returncode'] != 0 and reason in stderr, (name, stderr)
    assert 'syntax error' not in stderr and 'Compilation failed' not in stderr, name
    return row


mode = sys.argv[1]
if mode == 'original':
    files = {ORIGINS: subprocess.check_output(['git', 'show', BASE + ':' + ORIGINS], cwd=ROOT),
             TEST: (ROOT / TEST).read_bytes()}
    row = run('original', files)
    write(mode, row)
    assert row['returncode'] != 0 and b'private emission foundation is available' in base64.b64decode(row['stderr_base64'])
    print('Original RED: missing private foundation; later inverses distinguish its semantics.')
elif mode == 'consumers':
    tests = ['t/' + name + '.t' for name in (
        'actionir_ast_parser', 'canonical_event_occurrence_order',
        'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
        'actionir_executable_source_membership', 'trace_emit_context_bridge')]
    tests.append('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t')
    paths = subprocess.check_output(['git', 'ls-files', '-z', 'perl', 'specs', 't', 'docs/checkpoints'], cwd=ROOT).decode().split('\0')
    # Guard the entire parent-repository supplied superset before/after. This is
    # live focused recurrence, not the later immutable complete Phase0 acceptance.
    inputs = {p: digest((ROOT / p).read_bytes()) for p in paths if p and p != PREFIX + '-consumers.json' and (ROOT / p).is_file()}
    inputs.update({p: digest((ROOT / p).read_bytes()) for p in (ORIGINS, EMISSIONS, TEST)})
    result = subprocess.run(['prove', '-v', '-Iperl'] + tests, cwd=ROOT,
                            env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert all(digest((ROOT / p).read_bytes()) == h for p, h in inputs.items()), 'consumer input changed during run'
    row = {'name': mode, 'command': ['prove', '-v', '-Iperl'] + tests, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(), 'inputs': inputs,
           'scope': 'Guarded live parent-repository superset. Standard toolchain and published dependency outputs are reused; no immutable full Phase0 or dependency reproduction claim.'}
    write(mode, row)
    print('Unchanged direct consumers exit', result.returncode)
    raise SystemExit(result.returncode)
elif mode in ('draft', 'final'):
    files = {p: (ROOT / p).read_bytes() for p in (ORIGINS, EMISSIONS, TEST)}
    row = run(mode, files)
    write(mode, row)
    print(mode, 'exit', row['returncode'])
    if row['returncode']:
        print(base64.b64decode(row['stderr_base64']).decode(errors='replace'))
        raise SystemExit(row['returncode'])
    if mode == 'final':
        controls = [
            ('no-known-identity', 'callback => $callback, known => $known,', 'callback => $callback, known => 1,', 'custom calling built-in cannot inherit'),
            ('no-call', 'my $value = $callback->(@_);', 'my $value = undef;', 'actual known producer publishes'),
            ('list-context', 'my $value = $callback->(@_);', 'my @values = $callback->(@_); my $value = $values[-1];', 'callback called in scalar context'),
            ('copy-capture', 'my $entry = $_producers->{captures}{Scalar::Util::refaddr($capture)};\n return undef unless $entry && _same_reference($entry->{capture}, $capture)', 'my ($entry) = values %{$_producers->{captures}};\n return undef unless $entry', 'copied capture cannot borrow'),
            ('foreign-callback', '_same_reference($entry->{callback}, $callback)', '1', 'foreign callback denied'),
            ('foreign-event', '_same_reference($entry->{event}, $event)', '1', 'copied event denied'),
            ('no-source-fragments', "$fragment->{kind} = 'source';", "$fragment->{kind} = 'generated';", 'independent character/occurrence oracle'),
            ('shifted-coordinates', 'start => 0 + $start, end => 0 + $end', 'start => 1 + $start, end => 1 + $end', 'independent character/occurrence oracle'),
            ('generated-as-source', "my $fragment = {kind => 'generated', output_span", "my $fragment = {kind => 'source', source_span => {start => 0, end => length($text)}, output_span", 'independent character/occurrence oracle'),
            ('no-consumption', 'push @{$record->{consumed}}, {event => $event, source_span => {start => $start, end => $end}};', '# no consumption', 'independently authored consumed occurrence'),
            ('no-builder-validation', '&& ${$record->{builder}} eq $record->{text}', '&& 1', 'changed builder denied'),
            ('shared-packet', 'return _copy_packet($entry->{packet})', 'return $entry->{packet}', 'retrieval is detached'),
            ('shared-source-token', "return ref($_invocation) eq 'HASH' ? $_invocation : undef", 'our $_shared_token; return $_shared_token ||= {}', 'equal source gets distinct invocation identity', ORIGINS),
            ('copied-arguments', 'my $value = $callback->(@_);', 'my @copy = @_; my $value = $callback->(@copy);', 'scalar argument alias preserved'),
            ('double-callback', 'my $value = $callback->(@_);', 'my $discard = $callback->(@_); my $value = $callback->(@_);', 'exactly one callback invocation'),
            ('no-call-unwind', 'local $_call = {source_token', '$_call = {source_token', 'outer builder restored after nested fatal scope'),
        ]
        observed = []
        for args in controls:
            observed.append(inverse(files, *args))
            write('inverses', observed)
        print('Final GREEN and', len(observed), 'effective reason-sensitive source REDs.')
else:
    raise SystemExit('original|draft|final required')
