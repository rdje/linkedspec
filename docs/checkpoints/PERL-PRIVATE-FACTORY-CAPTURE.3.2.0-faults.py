"""Whole-source, syntax-valid package-flow interventions with complete TAP channels."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TARGET = ROOT / (PREFIX + 'inverses.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert not TARGET.exists(), 'one-shot faults'
fixture_raw = (ROOT / (PREFIX + 'fixture.json')).read_bytes()
fixture = json.loads(fixture_raw)
assert fixture['returncode'] == 0 and fixture['unchanged']
files = {path: (ROOT / path).read_bytes() for path in fixture['inputs']}
assert {path: sha(raw) for path, raw in files.items()} == fixture['inputs']
source = files[MODULE].decode()
bound = '_bind_emission_dependency($lower_flow_composite_expr)->($trimmed)'
faults = [
 ('raw-callback', bound, '$lower_flow_composite_expr->($trimmed)',
  'package-flow known0 child cannot donate parent packet'),
 ('wrapper-identity', bound, '_bind_emission_dependency(sub { return $lower_flow_composite_expr->(@_) })->($trimmed)',
  'package-flow known1 actual callback controls eligibility'),
 ('copied-arguments', bound, '_bind_emission_dependency(sub { my @args=@_; return $lower_flow_composite_expr->(@args) })->($trimmed)',
  'package-flow effect complete native observation'),
 ('map-selection', bound, '_bind_emission_dependency($deps->{lower_flow_composite_expr})->($trimmed)',
  'package-flow string authored result'),
 ('removed-branch', "ref($lower_flow_composite_expr) eq 'CODE'", '0',
  'package-flow public override remains reachable'),
 ('caller-equality', '$flow_expr ne $trimmed', '$flow_expr ne $expr',
  'package-flow mutated-original authored result'),
]


def tap(output):
    plans = re.findall(rb'^1\.\.(\d+)$', output, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', output, re.M)
    assert len(plans) == 1 and [int(n) for failed, n, name in rows] == list(range(1, int(plans[0]) + 1))
    return [name.decode() for failed, n, name in rows], [name.decode() for failed, n, name in rows if failed]


names, failed = tap(base64.b64decode(fixture['stdout_base64'], validate=True))
assert len(names) == 299 and not failed
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def channels(result):
    return {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


def census(directory):
    return {p.relative_to(directory).as_posix(): sha(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


with tempfile.TemporaryDirectory(prefix='package-flow-faults-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    rows = []
    start = source.index('sub _lower_mutation_slot_value_expr {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    for label, old, new, reason in faults:
        assert body.count(old) == 1
        changed = (source[:start] + body.replace(old, new, 1) + source[end:]).encode()
        (supplied / MODULE).write_bytes(changed)
        inputs = dict(fixture['inputs'], **{MODULE: sha(changed)})
        assert census(supplied) == inputs
        syntax_command = ['perl', '-Iperl', '-c', MODULE]
        syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, capture_output=True)
        result = subprocess.run(fixture['command'], cwd=supplied, env=environment, capture_output=True)
        row = {'label': label, 'producer_sha256': sha(Path(__file__).read_bytes()),
               'fixture_sha256': sha(fixture_raw), 'source_base64': base64.b64encode(changed).decode(),
               'source_sha256': sha(changed), 'inputs': inputs, 'syntax_command': syntax_command,
               'syntax': channels(syntax), 'command': fixture['command'], **channels(result),
               'unchanged': census(supplied) == inputs, 'reason': reason}
        target = ROOT / (PREFIX + 'inverse-' + label + '.json')
        assert not target.exists(), 'one-shot inverse'
        target.write_text(json.dumps(row, indent=2) + '\n')
        actual, failures = tap(result.stdout)
        assert syntax.returncode == 0 and b'syntax OK' in syntax.stderr
        assert actual == names and result.returncode != 0 and reason in failures and row['unchanged'], 'effective named semantic fault'
        rows.append({'label': label, 'path': target.relative_to(ROOT).as_posix(),
                     'sha256': sha(target.read_bytes()), 'failed': len(failures), 'reason': reason})
    (supplied / MODULE).write_bytes(files[MODULE])
    assert census(supplied) == fixture['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
TARGET.write_text(json.dumps({'producer_sha256': sha(Path(__file__).read_bytes()),
    'fixture_sha256': sha(fixture_raw), 'inputs': fixture['inputs'], 'rows': rows,
    'unchanged': True, 'scope': 'Six syntax-valid complete-module interventions. Every299-name TAP, named semantic denial, full mutant and211-input population is retained. Exact inputs restored.'}, indent=2) + '\n')
print('Package-flow source faults PASS:', ','.join(r['label'] + '=' + str(r['failed']) for r in rows))
