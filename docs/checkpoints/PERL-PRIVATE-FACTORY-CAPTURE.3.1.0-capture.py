"""Supplied native/current MethodLowering trim bindings and actual semantic source faults."""
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
BASE = '89a4ede6fbbb0f3b7a4e4f98a4b477b79c0cfeb7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_trim_capture.t'
COLD = 't/actionir_method_trim_capture_cold.t'
TRACE = 't/trace_emit_context_bridge.t'
assert sys.argv[1:] in ([m] for m in ('native', 'observe', 'before', 'fixture', 'cold', 'consumers', 'inverses'))
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
assert len(files) == 144 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
original_source = files[MODULE]
files[MODULE] = original_source if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
assert TRACE in files and (ROOT / TRACE).read_bytes() == files[TRACE]
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 146
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
        command = seed['command'] + [TEST, COLD] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original144 supplied Git inputs; only MethodLowering primitive/three required trim seams overlaid except original native/before modes, plus two fixtures. The original direct callback is the generic native binding oracle; actual three callers use the same fixture with a controlled constant secondary shape-value result. Standard read-only interpreter/core/toolchain outputs reused on the repository volume. No other required/optional call, pipeline/output/mapped/full-private/canonical/parent admission.'
        retain(mode, row)
        assert row['unchanged']
        assert (result.returncode != 0) if mode == 'before' else (result.returncode == 0)
        if mode in ('native', 'observe'):
            ledgers = json.loads(result.stdout)
            assert len(ledgers['dependency']) == 15 and len(ledgers['callers']) == 9 and not result.stderr
        elif mode == 'before':
            assert complete_tap(result.stdout) and b'injected trim cannot donate nested publication' in result.stdout
        elif mode == 'consumers':
            assert b'All tests successful.' in result.stdout
        else:
            assert complete_tap(result.stdout) and not re.search(rb'^not ok ', result.stdout, re.MULTILINE)
        print('Supplied method trim', mode, 'PASS; exact146-file input population unchanged')
    else:
        variants = []
        for name in ('_infer_direct_shape_literal_kind', '_normalize_method_tag_expr', '_lower_inline_switch_case_value_expr'):
            variants.append(('required-' + name.removeprefix('_'), edit(source, name,
                'return _bind_emission_dependency($cb);', 'return $cb;'), TEST,
                name + '/0 injected trim cannot donate nested publication'))
        variants.extend([
            ('binding-boundary', edit(source, '_bind_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)\n   if defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency;',
             ''), TEST, '_normalize_method_tag_expr/0 injected trim cannot donate nested publication'),
            ('alias-copies', edit(edit(source, '_bind_emission_dependency',
             'return sub {', 'return sub {\n  my @args = @_;'), '_bind_emission_dependency',
             '($callback, @_)', '($callback, @args)'), TEST,
             'scalar/string first and extra caller aliases survive'),
            ('list-context', edit(source, '_bind_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency',
             'return scalar LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency'), TEST,
             'list/string native dependency context survives'),
            ('void-context', edit(source, '_bind_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)\n   if defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency;',
             'if (defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency) {\n   my $value = LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_);\n   return $value\n  }'), TEST,
             'void/string native dependency context survives'),
            ('once', edit(source, '_bind_emission_dependency',
             'return sub {', 'return sub {\n  my $discard = $callback->(@_);'), TEST,
             'scalar/string actual injected callback executes once'),
            ('incoming-error', edit(source, '_bind_emission_dependency',
             'return sub {', 'return sub {\n  local $@ = q{};'), TEST,
             'scalar/string native incoming error survives'),
            ('successful-error', edit(source, '_bind_emission_dependency',
             'return sub {', 'return sub {\n  local $@ = $@;'), TEST,
             'scalar/string native successful error effect survives'),
            ('fatal-object', edit(source, '_bind_emission_dependency',
             'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)\n   if defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency;',
             'if (defined &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency) {\n   my $value = eval { LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_) };\n   die "$@" if ref($@);\n   return $value\n  }'), TEST,
             'scalar/fatal fatal object identity survives'),
            ('callback-retention', edit(source, '_bind_emission_dependency',
             'my ($callback) = @_;', 'my ($callback) = @_;\n our @callback_cache; push @callback_cache, $callback;'), TEST,
             'private binding release leaves no global callback retention'),
            ('cold-loading', edit(source, '_bind_emission_dependency',
             'my ($callback) = @_;', 'my ($callback) = @_;\n require LinkedSpec::ActionIR::SourceEmissions;'), COLD,
             'cold private binding keeps SourceEmissions unloaded'),
        ])
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
                            'scope': 'Three actual required trim seams and private native-context binding primitive; effective syntax-valid source faults, coherent complete main/cold TAP and independently named alias/context/publication/effect/error/lifetime/lazy-load REDs. Supplied bytes/population restore after every fault.'})
        print('Method trim inverses PASS:', len(reports), 'complete semantic REDs')
