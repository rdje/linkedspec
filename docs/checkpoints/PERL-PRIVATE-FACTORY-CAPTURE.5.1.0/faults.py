"""One-shot complete-source semantic controls in project-volume supplied roots."""
import base64
import gzip
import hashlib
import json
import os
import re
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FIXTURE = 't/actionir_control_expansion_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'faults.json')
assert not target.exists(), 'one-shot source fault loop'
capsule_path = ROOT / (PREFIX + 'after-inputs.json.gz')
capsule_raw = capsule_path.read_bytes()
capsule = json.loads(gzip.decompress(capsule_raw))
files = {path: base64.b64decode(item['bytes_base64']) for path, item in capsule.items()}
modes = {path: item['mode'] for path, item in capsule.items()}
assert all(sha(files[path]) == item['sha256'] for path, item in capsule.items())
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
before_capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-inputs.json.gz')).read_bytes()))
original = base64.b64decode(before_capsule[MODULE]['bytes_base64'])
source = files[MODULE]
assert source.count(b'return _bind_emission_dependency($cb);') == 4
helper_start = source.index(b'sub _bind_emission_dependency {\n')
helper_end = source.index(b'\n1;', helper_start)
helper = source[helper_start:helper_end]
helpers = ('_expand_flow_branch_action_exprs',)
variants = [('inverse', original)]
for name in helpers:
    start = source.index(('sub ' + name + ' {\n').encode())
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    assert body.count(b'return _bind_emission_dependency($cb);') == 1
    variants.append(('bypass-' + name, source[:start] + body.replace(
        b'return _bind_emission_dependency($cb);', b'return $cb;', 1) + source[end:]))

def change_helper(name, changed):
    assert changed != helper
    variants.append((name, source[:helper_start] + changed + source[helper_end:]))

change_helper('opaque-wrapper-identity', helper.replace(
    b'_invoke_emission_dependency($callback, @_)',
    b'_invoke_emission_dependency(sub { return $callback->(@_) }, @_)', 1))
change_helper('copied-argument-slots', helper.replace(b'return sub {\n', b'return sub {\n  my @args = @_;\n', 1)
    .replace(b'($callback, @_)', b'($callback, @args)').replace(b'$callback->(@_)', b'$callback->(@args)'))
change_helper('localized-error-effects', helper.replace(b'return sub {\n', b'return sub {\n  local $@;\n', 1))
change_helper('twice-only-effects', helper.replace(b'return sub {\n', b'return sub {\n  $callback->(@_);\n', 1))
change_helper('eager-emission-loading', helper.replace(b'return sub {\n',
    b'return sub {\n  require LinkedSpec::ActionIR::SourceEmissions;\n', 1))
variants.append(('delayed-map-selection', source[:start] + body.replace(b'return _bind_emission_dependency($cb);',
    b'return sub { return _bind_emission_dependency($deps->{$name})->(@_) };') + source[end:]))
variants.append(('public-map-rebinding', source[:start] + body.replace(b'return _bind_emission_dependency($cb);',
    b'return $deps->{$name} = _bind_emission_dependency($cb);') + source[end:]))
variants.append(('disabled-required-validation', source[:start] + body.replace(b"unless ref($cb) eq 'CODE';", b'if 0;') + source[end:]))
assert len({name for name, _ in variants}) == len(variants)
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
for name, changed in variants:
    selected = dict(files)
    selected[MODULE] = changed
    with tempfile.TemporaryDirectory(prefix='control-expansion-fault-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in selected.items():
            destination = supplied / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(raw)
            destination.chmod(modes[path])
        commands = [['perl', '-c', '-Iperl', MODULE], ['perl', '-Iperl', FIXTURE]]
        channels = []
        for command in commands:
            process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
            channels.append({'command': command, 'returncode': process.returncode,
                             'stdout_base64': base64.b64encode(process.stdout).decode(),
                             'stderr_base64': base64.b64encode(process.stderr).decode()})
        actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
                  for path in supplied.rglob('*') if path.is_file()}
        actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
    text = base64.b64decode(channels[1]['stdout_base64']).decode()
    assertions = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    plans = re.findall(r'^1\.\.(\d+)$', text, re.M)
    failures = [{'number': int(number), 'name': title} for not_ok, number, title in assertions if not_ok]
    row = {'name': name, 'module_sha256': sha(changed), 'module_base64': base64.b64encode(changed).decode(),
           'channels': channels, 'assertions': len(assertions), 'plan': plans,
           'failures': failures,
           'unchanged': actual == {path: sha(raw) for path, raw in selected.items()} and actual_modes == modes}
    rows.append(row)
    reached = ROOT / (PREFIX + 'faults-reached.json.gz')
    reached.write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
    assert row['unchanged'] and channels[0]['returncode'] == 0
    assert channels[1]['returncode'] != 0 and failures, ('effective semantic fault', name)
    assert len(plans) == 1 and int(plans[0]) == len(assertions)
    assert [int(number) for _, number, _ in assertions] == list(range(1, len(assertions) + 1))
    assert not re.search(r'^Bail out!', text, re.M)
data_path = ROOT / (PREFIX + 'faults-data.json.gz')
with data_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(rows, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
before = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
assert rows[0]['failures'] == before['failures'], 'exact full-source inverse restores all original RED names/numbers'
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items()), 'live inputs untouched'
result = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'positive_capsule_sha256': sha(capsule_raw), 'data_sha256': sha(data_path.read_bytes()),
          'inputs': {path: {'sha256': sha(raw), 'mode': modes[path]} for path, raw in files.items()},
          'variants': [{'name': row['name'], 'assertions': row['assertions'],
                        'failures': len(row['failures']), 'module_sha256': row['module_sha256']}
                       for row in rows],
          'scope': 'Complete current source with one declared semantic fault per isolated supplied root. Every original runtime/fixture byte and mode is supplied; every actual source variant, syntax command, full coherent TAP and separate channel is retained. No live production mutation; exact source inverse restores the complete original RED set.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
print('ControlFlow expansion complete-source faults PASS:', len(rows), 'effective variants;',
      [len(row['failures']) for row in rows], 'actual failures')
