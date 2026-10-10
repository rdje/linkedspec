"""Supplied native/current EmitContext bridge captures and semantic source faults."""
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
BASE = 'b21b3bb9f6a414d50c71468c3e4193d04ad9b56a'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-final-consumers.json'
MODULE = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
TEST = 't/actionir_emit_context_capture.t'
COLD = 't/actionir_emit_context_capture_cold.t'
TRACE = 't/trace_emit_context_bridge.t'
assert sys.argv[1:] in ([m] for m in ('native', 'observe', 'fixture', 'cold', 'consumers', 'inverses'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


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
assert len(files) == 136 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
original_source = files[MODULE]
files[MODULE] = original_source if mode == 'native' else (ROOT / MODULE).read_bytes()
for path in (TEST, COLD, TRACE):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 139
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
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
    return (len(plans) == 1 and (expected is None or int(plans[0]) == expected)
            and numbers == list(range(1, int(plans[0]) + 1)))


with tempfile.TemporaryDirectory(prefix='emit-context-capture-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD, TRACE] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original136 supplied consumer inputs; only EmitContext overlaid except native mode, plus bridge/cold/Trace fixtures. Standard read-only interpreter/core/toolchain outputs reused. No contract factory/pipeline/output/mapped/full-private/canonical admission.'
        retain(mode, row)
        assert row['unchanged'] and result.returncode == 0
        if mode in ('native', 'observe'):
            assert len(json.loads(result.stdout)) == 30 and not result.stderr
        elif mode == 'consumers':
            assert b'All tests successful.' in result.stdout
        else:
            assert complete_tap(result.stdout) and not re.search(rb'^not ok ', result.stdout, re.MULTILINE)
        print('Supplied EmitContext', mode, 'PASS; exact139-file input population unchanged')
    else:
        variants = [
            ('accept-any-reference', edit(source, '_register_builtin_contract_emission_callback',
             'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin)', '1'), TEST,
             'same public name replacement cannot enter the definition-owned selection'),
            ('lost-native-reference', source.replace(' \\&_lower_method_value_expr,', ' sub { return q{opaque} },', 1), TEST,
             '_lower_method_value_expr actual definition-owned reference reaches registration once'),
            ('follow-public-name', edit(source, '_register_builtin_contract_emission_callback',
             'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin)',
             'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin) || LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, __PACKAGE__->can(q{_lower_method_value_expr}))'), TEST,
             'same public name replacement cannot enter the definition-owned selection'),
            ('owner-boundary', edit(source, '_invoke_actionir_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)',
             'return $callback->(@_)'), TEST,
             'owner/scalar opaque resolved call cannot donate nested publication'),
            ('factory-boundary', edit(source, '_actionir_owner_default_deps',
             '_invoke_actionir_emission_dependency($code, __PACKAGE__)', '$code->(__PACKAGE__)'), TEST,
             'factory/scalar opaque resolved call cannot donate nested publication'),
            ('list-context', edit(source, '_invoke_actionir_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency',
             'return scalar LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency'), TEST,
             '0/list/string owner retains native context'),
            ('void-context', edit(source, '_call_actionir_owner',
             '  _invoke_actionir_emission_dependency($code, @args);',
             '  my $discard = _invoke_actionir_emission_dependency($code, @args);'), TEST,
             '0/void/string owner retains native context'),
            ('with-deps-context', edit(source, '_call_actionir_owner_with_deps',
             'my @ret = _invoke_actionir_emission_dependency', 'my @ret = scalar _invoke_actionir_emission_dependency'), TEST,
             '1/list/string owner retains native context'),
            ('caller-copies', edit(edit(source, '_call_actionir_owner',
             'my ($owner_key, $method, @args) = @_;', 'my ($owner_key, $method, @args) = @_;\n my $actual_args = \\@_;'),
             '_call_actionir_owner', '($code, @args)', '($code, @{$actual_args}[2..$#$actual_args])', 3), TEST,
             '0/scalar/string bridge retains its existing caller argument copies'),
            ('factory-map', edit(source, '_call_actionir_owner_with_deps',
             '($code, @args, $deps)', '($code, @args, {%$deps})', 3), TEST,
             '1/scalar/string owner receives the exact factory map'),
            ('incoming-error', edit(source, '_invoke_actionir_emission_dependency',
             'my $callback = shift;', 'my $callback = shift;\n local $@ = q{};'), TEST,
             '0/scalar/string owner observes native incoming error'),
            ('fatal-object', edit(source, '_invoke_actionir_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)\n  if defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency;',
             'if (defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency) {\n  my $value = eval { LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_) };\n  die "$@" if ref($@);\n  return $value\n }'), TEST,
             '0/scalar/fatal fatal object identity survives'),
            ('cold-loading', edit(source, '_register_builtin_contract_emission_callback',
             'my ($callback) = @_;', 'my ($callback) = @_;\n require LinkedSpec::ActionIR::SourceEmissions;'), COLD,
             'cold selection keeps SourceEmissions unloaded'),
        ]
        expected = {}
        for fixture, name in ((TEST, 'fixture'), (COLD, 'cold')):
            positive = json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
            out = base64.b64decode(positive['stdout_base64'], validate=True)
            assert positive['returncode'] == 0 and complete_tap(out)
            expected[fixture] = int(re.findall(rb'^1\.\.(\d+)$', out, re.MULTILINE)[0])
        reports = []
        for name, changed, fixture, reason in variants:
            raw = changed.encode()
            assert raw != files[MODULE], name
            (supplied / MODULE).write_bytes(raw)
            population = dict(inputs, **{MODULE: digest(raw)})
            syntax, checked = capture(supplied, ['perl', '-Iperl', '-c', MODULE], population)
            row, result = capture(supplied, ['perl', '-Iperl', fixture], population)
            failures = [line.decode() for line in result.stdout.splitlines()
                        if line.startswith(b'not ok ') and reason.encode() in line]
            row.update(case=name, source_sha256=digest(raw), distinguishing_reason=reason,
                       syntax=syntax, semantic_failures=failures)
            retain('inverse-' + name, row)
            assert row['unchanged'] and syntax['unchanged'] and checked.returncode == 0
            assert result.returncode != 0 and failures and complete_tap(result.stdout, expected[fixture]), (name, reason)
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason, 'fixture': fixture,
                            'assertions': expected[fixture], 'observed': 'RED'})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'source_sha256': inputs[MODULE], 'fixture_assertions': expected, 'rows': reports,
                            'scope': 'Syntax-valid effective source faults; complete coherent main/cold TAP and independently named identity/context/publication/error/lazy-load REDs. Supplied bytes/population restore after every fault.'})
        print('EmitContext inverses PASS:', len(reports), 'complete semantic REDs')
