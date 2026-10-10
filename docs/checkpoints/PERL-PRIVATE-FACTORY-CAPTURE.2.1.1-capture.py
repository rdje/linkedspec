"""Supplied complete native/current constructor captures and semantic faults."""
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
BASE = 'be7d70719856e76b7cb5a427ad6061a7109028ea'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0-final-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/Contracts.pm'
STAGED = 'perl/LinkedSpec/ActionIR/StagedParseJob.pm'
PROGRESSIVE = 'perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm'
MODULES = (MODULE, STAGED, PROGRESSIVE)
TEST = 't/actionir_contract_factory_capture.t'
COLD = 't/actionir_contract_factory_capture_cold.t'
assert sys.argv[1:] in ([m] for m in ('native', 'observe', 'fixture', 'cold', 'consumers', 'inverses'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)


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


def retain(name, row):
    target = ROOT / (PREFIX + name + '.json')
    assert not target.exists(), 'one-shot capture already exists: ' + name
    target.write_text(json.dumps(row, indent=2) + '\n')


seed_raw = blob(SEED)
seed = json.loads(seed_raw)
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 140 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p not in MODULES)
if mode != 'native':
    for path in MODULES:
        files[path] = (ROOT / path).read_bytes()
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 142
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
sources = {p: files[p].decode() for p in MODULES}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')


def capture(directory, command, population):
    assert census(directory) == population
    result = subprocess.run(command, cwd=directory, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    return {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
            'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': population,
            'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode(),
            'unchanged': census(directory) == population}, result


def complete_tap(raw, expected=None):
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    numbers = [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)]
    return (len(plans) == 1 and (expected is None or int(plans[0]) == expected)
            and numbers == list(range(1, int(plans[0]) + 1)))


with tempfile.TemporaryDirectory(prefix='constructor-capture-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        output = supplied / path; output.parent.mkdir(parents=True, exist_ok=True); output.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original140 supplied inputs; only Contracts/StagedParseJob/ProgressiveSpanDispatch overlaid except native mode, plus factory/cold fixtures. Standard read-only core/toolchain outputs reused in same-volume scratch. No other dependency owner, pipeline/output/mapped/full-private/canonical admission.'
        retain(mode, row)
        assert row['unchanged'] and result.returncode == 0
        if mode in ('native', 'observe'):
            ledgers = json.loads(result.stdout)
            assert len(ledgers) == 2 and ledgers[0] and len(ledgers[0]) == len(ledgers[1]) and not result.stderr
        elif mode == 'consumers':
            assert b'All tests successful.' in result.stdout
        else:
            assert complete_tap(result.stdout) and not re.search(rb'^not ok ', result.stdout, re.MULTILINE)
        print('Supplied constructors', mode, 'PASS; exact142-file population unchanged')
    else:
        variants = []
        local_factories = [
            '_build_call_and_dispatch_contracts', '_build_recursive_observation_contracts',
            '_build_inter_match_gap_contracts', '_build_recognition_transaction_contracts',
            '_build_return_contracts', '_build_capture_and_cursor_contracts',
            '_build_passthrough_ir_contracts', '_build_assignment_and_regex_contracts',
            '_build_array_pipeline_contracts', '_build_dropped_value_contracts',
            '_build_flow_control_contracts', '_build_emit_and_declare_contracts']
        for name in local_factories:
            variants.append(('local-' + name.removeprefix('_build_'), MODULE,
                edit(sources[MODULE], name, 'return _register_native_contracts([', 'return (['), TEST,
                'actual returned callback is selected in its producer scope'))
        for module, name in ((STAGED, 'staged'), (PROGRESSIVE, 'progressive')):
            variants.append((name + '-registration', module,
                edit(sources[module], 'build_contracts', 'for @$contracts;', 'for ();'), TEST,
                ('staged_parse_job' if name == 'staged' else 'progressive_span_dispatch') +
                ' actual returned callback is selected in its producer scope'))
        variants.extend([
            ('blind-catalogue', MODULE, edit(edit(sources[MODULE], 'build_action_lowering_contracts',
             'return [', 'return _register_native_contracts(['), 'build_action_lowering_contracts',
             '\n ]\n}', '\n ])\n}'), TEST,
             'LinkedSpec::ActionIR::Contracts::_build_call_and_dispatch_contracts substituted factory cannot register its opaque callback'),
            ('wrong-callback', MODULE, edit(sources[MODULE], '_register_native_contracts',
             '($_->{lower})', '(sub { return q{opaque} })'), TEST,
             'actual returned callback is selected in its producer scope'),
            ('copied-array', MODULE, edit(sources[MODULE], '_register_native_contracts',
             'return $contracts', 'return [map { +{%$_} } @$contracts]'), TEST,
             'local seam 0 returns the actual array'),
            ('copied-callback', MODULE, edit(sources[MODULE], '_register_native_contracts',
             'my ($contracts) = @_;', 'my ($contracts) = @_;\n for my $contract (@$contracts) { my $actual = $contract->{lower}; $contract->{lower} = sub { return $actual->(@_) } }'), TEST,
             'local seam 0 preserves actual public lower references'),
            ('callback-retention', MODULE, edit(sources[MODULE], '_register_native_contracts',
             'my ($contracts) = @_;', 'my ($contracts) = @_;\n our @callback_cache; push @callback_cache, map { $_->{lower} } @$contracts;'), TEST,
             'producer scope exit releases actual lexical factory callback'),
            ('cold-loading', MODULE, edit(sources[MODULE], '_register_native_contracts',
             'my ($contracts) = @_;', 'my ($contracts) = @_;\n require LinkedSpec::ActionIR::SourceEmissions;'), COLD,
             'cold factory registration keeps SourceEmissions unloaded'),
        ])
        expected = {}
        for fixture, name in ((TEST, 'fixture'), (COLD, 'cold')):
            positive = json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
            out = base64.b64decode(positive['stdout_base64'], validate=True)
            assert positive['returncode'] == 0 and complete_tap(out)
            expected[fixture] = int(re.findall(rb'^1\.\.(\d+)$', out, re.MULTILINE)[0])
        rows = []
        for name, module, changed, fixture, reason in variants:
            raw = changed.encode()
            assert raw != files[module], name
            (supplied / module).write_bytes(raw)
            population = dict(inputs, **{module: digest(raw)})
            syntax, compiled = capture(supplied, ['perl', '-Iperl', '-c', module], population)
            row, result = capture(supplied, ['perl', '-Iperl', fixture], population)
            failures = [line.decode() for line in result.stdout.splitlines()
                        if line.startswith(b'not ok ') and reason.encode() in line]
            row.update(case=name, module=module, source_sha256=digest(raw), distinguishing_reason=reason,
                       syntax=syntax, semantic_failures=failures)
            retain('inverse-' + name, row)
            assert row['unchanged'] and syntax['unchanged'] and compiled.returncode == 0
            assert result.returncode != 0 and failures and complete_tap(result.stdout, expected[fixture]), (name, reason)
            rows.append({'case': name, 'module': module, 'path': PREFIX + 'inverse-' + name + '.json',
                         'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                         'source_sha256': digest(raw), 'reason': reason, 'fixture': fixture,
                         'assertions': expected[fixture], 'observed': 'RED'})
            (supplied / module).write_bytes(files[module])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
            'sources': {p: inputs[p] for p in MODULES}, 'fixture_assertions': expected, 'rows': rows,
            'scope': 'Each local/delegated seam removed separately, blind aggregate authority, wrong callback, public reference copies, scope retention and cold loading; effective syntax-valid semantic faults with complete positive-sized TAP and named REDs. Exact supplied bytes restore after every case.'})
        print('Constructor inverses PASS:', len(rows), 'complete semantic REDs')
