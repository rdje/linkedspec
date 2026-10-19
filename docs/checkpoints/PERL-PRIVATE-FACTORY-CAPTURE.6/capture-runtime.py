"""One-shot supplied-input proof: positive, thirteen semantic inverses, all91 consumers."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
MODULE = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
FIXTURE = 't/actionir_factory_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'runtime.json')
capsule_path = ROOT / (PREFIX + 'runtime-inputs.json.gz')
reached = ROOT / (PREFIX + 'runtime-reached.json.gz')
assert not target.exists() and not capsule_path.exists() and not reached.exists()
seed_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/consumers.json'
registration_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/registration.json'
seed = json.loads((ROOT / seed_path).read_bytes())
registration = json.loads((ROOT / registration_path).read_bytes())
factory_path = PREFIX + 'native-factory.json'
factory = json.loads((ROOT / factory_path).read_bytes())
implementation = json.loads((ROOT / (PREFIX + 'implementation.json')).read_bytes())
suites = registration['suites']
assert len(suites) == 91 and suites == seed['command'][3:]
support = [
    'pipeline-probe.pl', 'pipeline-extra-probe.pl', 'pipeline-assertions-portable-final.pl',
    'pipeline-composition-fixed.pl', 'native-factory-current-probe.pl',
    'native-before.json', 'native-prove-context-before.json', 'implementation.json',
    'capture-runtime.py',
]
paths = set(seed['inputs']) | set(factory['inputs']) | {PREFIX + name for name in support}
paths.update({seed_path, registration_path, factory_path, FIXTURE,
              'tools/run_python_project_data.sh', 'tools/project_data_env.sh'})
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert not Path(name).is_absolute() and '..' not in Path(name).parts
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777, bytes_base64=encode(data))
for name, expected in seed['inputs'].items():
    assert name in (MODULE, FIXTURE) or inputs[name]['sha256'] == expected
    assert inputs[name]['mode'] == seed['modes'][name]
assert inputs[MODULE]['sha256'] == implementation['after_sha256']
for name, expected in factory['inputs'].items():
    assert inputs[name]['sha256'] == expected['sha256'] and inputs[name]['mode'] == expected['mode']
candidate = base64.b64decode(inputs[MODULE]['bytes_base64'])
with capsule_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))

def replace(old, new):
    assert candidate.count(old) == 1, old
    value = candidate.replace(old, new)
    assert value != candidate
    return value

producer_scope = b''' return LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], sub {
  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)
 })'''
cases = [
    ('positive', candidate, None),
    ('missing-producer-scope', replace(producer_scope,
        b' return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)'),
     b'pipeline producer source scope'),
    ('missing-input-scope', replace(
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)', b'  return $work->()'),
     b'pipeline input source scope'),
    ('scopes-before-source-invocation', replace(
        b' return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub { return _with_pipeline_emission_scopes(sub {',
        b' return _with_pipeline_emission_scopes(sub { return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub {'),
     b'pipeline producer source scope'),
]
for role, token in [('factory', b'my $contracts = '), ('collect', b'my $ir_diag = '),
                    ('canonical', b'my $canonical_ir_diag = '), ('find', b'my $diag = '),
                    ('apply', b'my $lowered_stmt = ')]:
    matches = [row for row in implementation['replacements']
               if base64.b64decode(row['before_base64']).lstrip().startswith(token)]
    assert len(matches) == 1, role
    old = base64.b64decode(matches[0]['after_base64'])
    new = base64.b64decode(matches[0]['before_base64'])
    cases.append(('missing-' + role + '-capture', replace(old, new),
                  b'factory opaque nested publisher cannot donate' if role == 'factory'
                  else b'apply opaque nested publisher cannot donate' if role == 'apply'
                  else b'pipeline actual callback boundary ' + role.encode()))
cases.extend([
    ('duplicate-apply-fetch', replace(b'my $apply = $rewrite_by_id{$contract_id}{apply};',
        b'my $apply = $rewrite_by_id{$contract_id}{apply}; my $second = $rewrite_by_id{$contract_id}{apply};'),
     b'pipeline native tied lookup non-CODE dispatch exact diagnostics and immediate callback release'),
    ('scope-retains-opaque-callback', replace(b' my $opaque = shift;',
        b' my $opaque = shift;\n $LinkedSpec::ActionIR::SourceEmissions::_producers->{held_opaque} = $callback if ref($LinkedSpec::ActionIR::SourceEmissions::_producers) eq \'HASH\';'),
     b'pipeline native tied lookup non-CODE dispatch exact diagnostics and immediate callback release'),
    ('register-every-supplied-apply', replace(b' my $opaque = shift;',
        b' my $opaque = shift;\n LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($callback);'),
     b'pipeline actual registered factory output versus opaque supplied apply'),
    ('non-CODE-dispatch-moves-source', replace(b"ref($callback) eq 'CODE' ? $callback : $opaque", b'$callback'),
     b'pipeline native tied lookup non-CODE dispatch exact diagnostics and immediate callback release'),
    ('coerce-invocation-body-scalar', replace(
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)',
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs(sub { scalar $work->() })'),
     b'pipeline native values aliases ordering identities and error channels'),
])
assert len(cases) == 14 and len({name for name, _, _ in cases}) == 14
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
reached.write_bytes(gzip.compress(b'[]', mtime=0))

def check_parent():
    return all(sha((ROOT / name).read_bytes()) == row['sha256']
               and (ROOT / name).stat().st_mode & 0o7777 == row['mode']
               for name, row in inputs.items())

def execute(name, source, command):
    expected = {path: row['sha256'] for path, row in inputs.items()}
    expected[MODULE] = sha(source)
    with tempfile.TemporaryDirectory(prefix='pipeline-supplied-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, item in inputs.items():
            destination = supplied / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(source if path == MODULE else base64.b64decode(item['bytes_base64']))
            destination.chmod(item['mode'])
        syntax_command = ['perl', '-c', '-Iperl', MODULE]
        syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, capture_output=True)
        run = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
                  for path in supplied.rglob('*') if path.is_file()}
        modes = {path: (supplied / path).stat().st_mode & 0o7777 for path in actual}
        unexpected = {path: dict(sha256=actual[path], mode=modes[path],
                                bytes_base64=encode((supplied / path).read_bytes()))
                      for path in actual if path not in expected or actual[path] != expected[path]}
    summary = re.findall(rb'^Files=(\d+), Tests=(\d+),', run.stdout, re.M)
    plans = [int(value) for value in re.findall(rb'^1\.\.(\d+)\s*$', run.stdout, re.M)]
    failures = re.findall(rb'^not ok \d+ - (.*)$', run.stdout, re.M)
    row = dict(name=name, command=command, source_sha256=sha(source),
               source_base64=encode(source), syntax_command=syntax_command, syntax_returncode=syntax.returncode,
               syntax_stdout_base64=encode(syntax.stdout), syntax_stderr_base64=encode(syntax.stderr),
               returncode=run.returncode, stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
               summaries=[list(map(int, pair)) for pair in summary], plans=plans,
               failures=[name.decode('utf-8', errors='strict') for name in failures],
               complete_inputs_unchanged=actual == expected,
               modes_unchanged=modes == {path: item['mode'] for path, item in inputs.items()},
               parent_inputs_unchanged=check_parent(), unexpected_outputs=unexpected)
    rows.append(row)
    reached.write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
    assert row['complete_inputs_unchanged'] and row['modes_unchanged'] and row['parent_inputs_unchanged'], name
    assert syntax.returncode == 0, (name, syntax.stderr)
    assert b'Bail out!' not in run.stdout + run.stderr, name
    return row, run.stdout, run.stderr, failures

for name, source, reason in cases:
    row, stdout, stderr, failures = execute(name, source, ['prove', '-v', '-Iperl', FIXTURE])
    assert row['plans'] == [2065] and row['summaries'] == [[1, 2065]], (name, row['plans'], row['summaries'])
    if reason is None:
        assert row['returncode'] == 0 and not failures and b'Result: PASS' in stdout, (name, stderr)
    else:
        assert row['returncode'] != 0 and failures
        assert any(reason in value for value in failures), (name, reason, failures)
    print('Supplied pipeline case retained:', name, 'exit', row['returncode'],
          'assertions2065', 'failures', len(failures), flush=True)

consumer, stdout, stderr, failures = execute('all-direct-consumers', candidate, ['prove', '-v', '-Iperl', *suites])
executed = [value.decode() for value in re.findall(rb'^(\S+\.t)\s+\.+', stdout, re.M)]
assert consumer['returncode'] == 0 and not failures and b'Result: PASS' in stdout
assert executed == suites and len(consumer['summaries']) == 1 and consumer['summaries'][0][0] == 91
assert len(consumer['plans']) == 91 and sum(consumer['plans']) == consumer['summaries'][0][1]
record = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
              capsule_sha256=sha(capsule_path.read_bytes()), reached_sha256=sha(reached.read_bytes()),
              inputs={path: {key: value for key, value in row.items() if key != 'bytes_base64'}
                      for path, row in inputs.items()}, suites=suites,
              environment_controls={key: environment[key] for key in
                  ('PERL5LIB', 'PERL5OPT', 'LINKEDSPEC_EVENT_ORDER_BASELINE', 'LINKEDSPEC_MEMBERSHIP_BASELINE')},
              rows=[{key: value for key, value in row.items() if key not in
                     ('source_base64', 'stdout_base64', 'stderr_base64', 'syntax_stdout_base64', 'syntax_stderr_base64')}
                    for row in rows],
              scope='Complete supplied source/input/mode population and actual separated channels. '
                    'One positive and13 syntax-valid semantic source inverses preserve2065 coherent '
                    'assertions each; every counterfactual differs only in RewritePipeline. All91 '
                    'previously admitted consumers run with current selected fixture/helpers. '
                    'Temporary fixtures are created only in managed same-volume scratch. Host tools '
                    'are read-only prerequisites; no immutable host, arbitrary-shell, minimal IO, '
                    'copied-root/liveness/recovery/purge or broader private/mapped/parent admission claim.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
print('Complete pipeline runtime proof PASS:2065 assertions/13 semantic inverses;',
      len(inputs), 'inputs;91 suites/', consumer['summaries'][0][1], 'assertions', flush=True)
