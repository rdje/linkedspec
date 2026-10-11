"""Capture effective whole-source interventions for both required hash-index owners."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TARGET = ROOT / (PREFIX + 'inverses.json')
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert not TARGET.exists(), 'one-shot faults'
fixture_raw = (ROOT / (PREFIX + 'fixture.json')).read_bytes()
fixture = json.loads(fixture_raw)
assert fixture['returncode'] == 0 and fixture['unchanged']
files = {path: (ROOT / path).read_bytes() for path in fixture['inputs']}
assert {path: digest(raw) for path, raw in files.items()} == fixture['inputs']
source = files[MODULE].decode()
binding = 'return _bind_emission_dependency($cb);'


def tap(raw):
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', raw, re.MULTILINE)
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    assert len(plans) == 1 and [int(n) for failed, n, label in rows] == list(range(1, int(plans[0]) + 1)), 'complete fault TAP'
    return [label.decode() for failed, n, label in rows], [label.decode() for failed, n, label in rows if failed]


names, failures = tap(base64.b64decode(fixture['stdout_base64'], validate=True))
assert len(names) == 413 and not failures
faults = []
for owner in ('parser', 'lowerer'):
    role = 'trim_action_ir_value' if owner == 'parser' else 'lower_scalar_access_key_expr'
    faults.extend([
        (owner, 'raw-callback', binding, 'return $cb;',
         f'hash-index authority {owner} {role} known0 no child publication donation'),
        (owner, 'wrapper-identity', binding, 'return _bind_emission_dependency(sub { return $cb->(@_) });',
         f'hash-index authority {owner} {role} known1 actual callback identity'),
        (owner, 'copied-arguments', binding, 'return _bind_emission_dependency(sub { my @args=@_; return $cb->(@args) });',
         'hash-index branch parser-rhs-trim-effect complete native observation' if owner == 'parser'
         else 'hash-index ordinary callback lowerer-lower_scalar_access_key_expr-effect complete native effects and aliases'),
        (owner, 'late-map-selection', binding, 'return _bind_emission_dependency(sub { return $deps->{$name}->(@_) });',
         f'hash-index branch {owner}-replace-' + ('trim' if owner == 'parser' else 'key') + ' complete native observation'),
        (owner, 'missing-diagnostic', '::_require_dep)', '::_wrong_dep)',
         f'hash-index branch {owner}-missing-{role} complete native observation'),
    ])
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def channels(result):
    return {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


with tempfile.TemporaryDirectory(prefix='hash-index-required-faults-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    rows = []
    for owner, label, old, new, reason in faults:
        function = ('_parse_' if owner == 'parser' else '_lower_') + 'hash_index_assignment_operator_statement'
        begin = source.index('sub ' + function + ' {')
        end = source.index('\nsub ', begin + 1)
        body = source[begin:end]
        assert body.count(old) == 1
        mutant = (source[:begin] + body.replace(old, new) + source[end:]).encode()
        (supplied / MODULE).write_bytes(mutant)
        population = dict(fixture['inputs'], **{MODULE: digest(mutant)})
        assert census(supplied) == population
        syntax_command = ['perl', '-Iperl', '-c', MODULE]
        syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result = subprocess.run(fixture['command'], cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        row = {'owner': owner, 'label': label, 'producer_sha256': digest(Path(__file__).read_bytes()),
               'fixture_sha256': digest(fixture_raw), 'source_base64': base64.b64encode(mutant).decode(),
               'source_sha256': digest(mutant), 'inputs': population, 'syntax_command': syntax_command,
               'syntax': channels(syntax), 'command': fixture['command'], **channels(result),
               'unchanged': census(supplied) == population, 'reason': reason}
        target = ROOT / (PREFIX + 'inverse-' + owner + '-' + label + '.json')
        assert not target.exists(), 'one-shot inverse'
        target.write_text(json.dumps(row, indent=2) + '\n')
        actual, failed = tap(result.stdout)
        assert syntax.returncode == 0 and b'syntax OK' in syntax.stderr, 'syntax-valid source fault'
        assert actual == names and result.returncode != 0 and reason in failed and row['unchanged'], 'effective named source fault'
        rows.append({'owner': owner, 'label': label, 'path': target.relative_to(ROOT).as_posix(),
                     'sha256': digest(target.read_bytes()), 'failed': len(failed), 'reason': reason})
    (supplied / MODULE).write_bytes(files[MODULE])
    assert census(supplied) == fixture['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
TARGET.write_text(json.dumps({'producer_sha256': digest(Path(__file__).read_bytes()),
    'fixture_sha256': digest(fixture_raw), 'inputs': fixture['inputs'], 'rows': rows, 'unchanged': True,
    'scope': 'Five actual syntax-valid whole-module interventions per required owner. Every complete413-name TAP and named semantic denial, full mutant bytes and207 supplied inputs are retained. Original source, fixture and first native observations stay unchanged.'}, indent=2) + '\n')
print('Hash-index source faults PASS:', ','.join(r['owner'] + '/' + r['label'] + '=' + str(r['failed']) for r in rows))
