"""Supplied private factory framework and semantic fault captures."""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '02345ee21f9cd674dea073b5e25f6200bd0a6ead'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SEED = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_factory_capture.t'
assert sys.argv[1:] in (['fixture'], ['consumers'], ['inverses'])
mode = sys.argv[1]


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def edit(source, name, old, new, count=1):
    start = source.index('sub ' + name + ' {')
    end = source.find('\nsub ', start + 1)
    if end < 0:
        end = len(source)
    body = source[start:end]
    assert body.count(old) == count, (name, old, body.count(old))
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
seed = json.loads(seed_raw)
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(files) == 135
assert {path: digest(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
files[MODULE] = (ROOT / MODULE).read_bytes()
files[TEST] = (ROOT / TEST).read_bytes()
inputs = {path: digest(raw) for path, raw in sorted(files.items())}
source = files[MODULE].decode()
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')


def retain(name, row):
    target = ROOT / (PREFIX + name + '.json')
    assert not target.exists(), 'one-shot capture already exists: ' + name
    target.write_text(json.dumps(row, indent=2) + '\n')


def capture(directory, command, population):
    assert census(directory) == population
    result = subprocess.run(command, cwd=directory, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
           'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': population,
           'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'unchanged': census(directory) == population}
    return row, result


def complete_tap(raw, expected=None):
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    numbers = [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)]
    return (len(plans) == 1 and int(plans[0]) >= 200
            and (expected is None or int(plans[0]) == expected)
            and numbers == list(range(1, int(plans[0]) + 1)))


with tempfile.TemporaryDirectory(prefix='factory-framework-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode in ('fixture', 'consumers'):
        command = ['perl', '-Iperl', TEST] if mode == 'fixture' else seed['command'] + [TEST]
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original135 supplied consumer files with only SourceEmissions overlaid, plus the independently authored framework fixture. Standard read-only interpreter/core/toolchain outputs reused. Production factory/pipeline/output/mapped/full-private/canonical integration remains open.'
        retain(mode, row)
        assert row['unchanged'] and result.returncode == 0
        assert complete_tap(result.stdout) if mode == 'fixture' else b'All tests successful.' in result.stdout
        print('Supplied framework', mode, 'PASS; exact136-file input population unchanged')
    else:
        variants = [
            ('registration-token', edit(source, '_register_emission_producer',
             '_same_reference($_producers->{source_token}, _current_source_token())', '1'),
             'foreign source registration cannot leak into restored outer scope'),
            ('callback-identity', edit(source, '_capture_emission',
             '_same_reference($_producers->{known}{Scalar::Util::refaddr($callback)}, $callback)', '1'),
             'equal fresh callback and copied metadata have no registration'),
            ('scalar-boundary', edit(source, '_invoke_emission_dependency',
             'my $capture = _capture_emission($callback, @_);\n return $capture->{value}', 'return $callback->(@_)'),
             'scalar opaque dependency cannot donate nested publication'),
            ('list-boundary', edit(source, '_invoke_emission_dependency',
             'if (wantarray) {\n  local $_call;', 'if (wantarray) {'),
             'list opaque dependency cannot donate nested publication'),
            ('void-boundary', edit(source, '_invoke_emission_dependency',
             'if (!defined wantarray) {\n  local $_call;', 'if (!defined wantarray) {'),
             'void opaque dependency cannot donate nested publication'),
            ('list-context', edit(source, '_invoke_emission_dependency',
             'return $callback->(@_)', 'return scalar $callback->(@_)'),
             '0/list/string dependency retains native context'),
            ('void-context', edit(source, '_invoke_emission_dependency',
             '$callback->(@_);', 'my $discard = $callback->(@_);'),
             '0/void/string dependency retains native context'),
            ('aliases', edit(source, '_invoke_emission_dependency',
             '_capture_emission($callback, @_)', '_capture_emission($callback, do { my @copy = @_; @copy })'),
             '0/scalar/string both original caller aliases are written'),
            ('once', edit(source, '_invoke_emission_dependency',
             'my $capture = _capture_emission', '$callback->(@_);\n my $capture = _capture_emission'),
             '0/scalar/string actual dependency executes once'),
            ('success-error', edit(source, '_invoke_emission_dependency',
             'return $capture->{value}', '$@ = q{};\n return $capture->{value}'),
             '0/scalar/string successful error effect survives'),
            ('callback-retention', edit(source, '_register_emission_producer',
             '$_producers->{known}{Scalar::Util::refaddr($callback)} = $callback;',
             '$_producers->{known}{Scalar::Util::refaddr($callback)} = $callback;\n  Scalar::Util::weaken($_producers->{known}{Scalar::Util::refaddr($callback)});'),
             'registered actual callback stays strongly retained until scope exit'),
        ]
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        positive_out = base64.b64decode(positive['stdout_base64'], validate=True)
        assert positive['returncode'] == 0 and complete_tap(positive_out)
        expected_assertions = int(re.findall(rb'^1\.\.(\d+)$', positive_out, re.MULTILINE)[0])
        reports = []
        for name, changed, reason in variants:
            raw = changed.encode()
            assert raw != files[MODULE]
            (supplied / MODULE).write_bytes(raw)
            population = dict(inputs, **{MODULE: digest(raw)})
            syntax, checked = capture(supplied, ['perl', '-Iperl', '-c', MODULE], population)
            row, result = capture(supplied, ['perl', '-Iperl', TEST], population)
            failures = [line.decode() for line in result.stdout.splitlines()
                        if line.startswith(b'not ok ') and reason.encode() in line]
            row.update(case=name, source_sha256=digest(raw), distinguishing_reason=reason,
                       syntax=syntax, semantic_failures=failures)
            retain('inverse-' + name, row)
            assert row['unchanged'] and syntax['unchanged'] and checked.returncode == 0
            assert result.returncode != 0 and failures and complete_tap(result.stdout, expected_assertions), (name, reason)
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason, 'observed': 'RED'})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'fixture_sha256': inputs[TEST], 'source_sha256': inputs[MODULE], 'rows': reports,
                            'assertions': expected_assertions, 'scope': 'Syntax-valid effective faults; complete coherent TAP plans and independently authored identity/context/publication/lifetime reasons. Original supplied bytes/population restore after each fault.'})
        print('Framework inverses PASS:', len(reports), 'complete', expected_assertions, 'assertion semantic REDs')
