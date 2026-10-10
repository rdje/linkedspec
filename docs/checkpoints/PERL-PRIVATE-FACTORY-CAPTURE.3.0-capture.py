"""Supplied native/current MethodLowering default maps and semantic source faults."""
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
BASE = '33e57deee73e27b97e9c21116bc70942f3f33772'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
EMITTER = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
MODULES = (MODULE, EMITTER)
TEST = 't/actionir_method_default_capture.t'
COLD = 't/actionir_method_default_capture_cold.t'
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
assert len(files) == 142 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p not in MODULES)
if mode != 'native':
    for path in MODULES:
        files[path] = (ROOT / path).read_bytes()
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 144
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


with tempfile.TemporaryDirectory(prefix='method-default-capture-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        output = supplied / path; output.parent.mkdir(parents=True, exist_ok=True); output.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original142 supplied inputs; only MethodLowering default factory and EmitContext method native reference catalogue/selector overlaid except native mode, plus two fixtures. Standard read-only core/toolchain outputs reused on the repository volume. Default map/ref selection only: no injected call isolation, successful helper semantics, automatic pipeline/output/mapped/full-private/canonical/parent admission.'
        retain(mode, row)
        assert row['unchanged'] and result.returncode == 0
        if mode in ('native', 'observe'):
            ledgers = json.loads(result.stdout)
            assert len(ledgers) == 2 and all(len(row['callbacks']) == 19 for row in ledgers) and not result.stderr
        elif mode == 'consumers':
            assert b'All tests successful.' in result.stdout
        else:
            assert complete_tap(result.stdout) and not re.search(rb'^not ok ', result.stdout, re.MULTILINE)
        print('Supplied method defaults', mode, 'PASS; exact144-file population unchanged')
    else:
        variants = []
        method_keys = ('trim_action_ir_value split_declare_symbol_names parse_declare_binding_entry '
            'lower_declare_initializer_expr parse_method_function_expr normalize_method_args_with_optional_scope '
            'lower_direct_nested_access_value_expr extract_array_symbol_name extract_hash_symbol_name '
            'extract_scalar_symbol_name lower_scalar_access_key_expr lower_primitive_literal_expr '
            'infer_scalar_container_kind split_top_level_csv split_action_ir_statements lower_array_pipeline_expr '
            'lower_assignment_source_expr lower_flow_composite_expr strip_literal_delimiters').split()
        for key in method_keys:
            # Alter only this owner's separate native catalogue, not Contracts'.
            marker = 'my @builtin_method_emission_callbacks = ('
            start = sources[EMITTER].index(marker)
            before, catalogue = sources[EMITTER][:start], sources[EMITTER][start:]
            needle = ' \\&_' + key + ',\n'
            assert catalogue.count(needle) == 1
            changed = before + catalogue.replace(needle, '', 1)
            variants.append(('native-' + key, EMITTER, changed, TEST,
                key + ' actual native reference is selected in current scope'))
        variants.extend([
            ('missing-factory', MODULE, edit(sources[MODULE], 'default_deps_for_package',
             'for values %$deps;', 'for ();'), TEST,
             'native default selects each actual reference exactly once'),
            ('custom-target', MODULE, edit(sources[MODULE], 'default_deps_for_package',
             "$pkg eq 'LinkedSpec::RuleIR::EmitContext'", 'length($pkg)'), TEST,
             'trim_action_ir_value custom target cannot register its native alias'),
            ('same-name-reference', EMITTER, edit(sources[EMITTER], '_register_builtin_method_emission_callback',
             'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin)', '1'), TEST,
             'trim_action_ir_value same-name replacement remains opaque'),
            ('copied-map', MODULE, edit(sources[MODULE], 'default_deps_for_package',
             'return $deps', 'return {%$deps}'), TEST,
             'default factory returns the exact actual OwnerDispatch map'),
            ('cold-loading', MODULE, edit(sources[MODULE], 'default_deps_for_package',
             'my ($pkg) = @_;', 'my ($pkg) = @_;\n require LinkedSpec::ActionIR::SourceEmissions;'), COLD,
             'cold method default keeps SourceEmissions unloaded'),
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
            'scope': 'Each of nineteen method native definition references removed separately, factory registration omitted, custom target/ref selection bypassed, actual map copied and cold loading introduced; effective syntax-valid semantic faults with complete positive-sized TAP and named REDs. Exact supplied bytes restore after every case.'})
        print('Method defaults inverses PASS:', len(rows), 'complete semantic REDs')
