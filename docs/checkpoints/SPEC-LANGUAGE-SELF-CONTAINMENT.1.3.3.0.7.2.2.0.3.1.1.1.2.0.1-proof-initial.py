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


def inverse(files, name, old, new, reason):
    changed = dict(files)
    raw = changed[EMISSIONS]
    assert raw.count(old.encode()) == 1, name
    changed[EMISSIONS] = raw.replace(old.encode(), new.encode(), 1)
    row = run(name, changed)
    row.update(source=EMISSIONS, old=old, new=new, required_failure=reason)
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
            ('copy-capture', '_same_reference($entry->{capture}, $capture)', '1', 'copied capture cannot borrow'),
            ('foreign-callback', '_same_reference($entry->{callback}, $callback)', '1', 'foreign callback denied'),
            ('foreign-event', '_same_reference($entry->{event}, $event)', '1', 'copied event denied'),
            ('no-source-fragments', "$fragment->{kind} = 'source';", "$fragment->{kind} = 'generated';", 'independent character/occurrence oracle'),
            ('shifted-coordinates', 'start => 0 + $start, end => 0 + $end', 'start => 1 + $start, end => 1 + $end', 'independent character/occurrence oracle'),
            ('generated-as-source', "my $fragment = {kind => 'generated', output_span", "my $fragment = {kind => 'source', source_span => {start => 0, end => length($text)}, output_span", 'independent character/occurrence oracle'),
            ('no-consumption', 'push @{$record->{consumed}}, {event => $event, source_span => {start => $start, end => $end}};', '# no consumption', 'independently authored consumed occurrence'),
            ('no-builder-validation', '&& ${$record->{builder}} eq $record->{text}', '&& 1', 'changed builder denied'),
            ('shared-packet', 'return _copy_packet($entry->{packet})', 'return $entry->{packet}', 'retrieval is detached'),
        ]
        observed = []
        for args in controls:
            observed.append(inverse(files, *args))
            write('inverses', observed)
        print('Final GREEN and', len(observed), 'effective reason-sensitive source REDs.')
else:
    raise SystemExit('original|draft|final required')
