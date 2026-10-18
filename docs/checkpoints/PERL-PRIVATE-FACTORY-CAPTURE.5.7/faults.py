"""One-shot complete three-owner source controls in supplied project roots."""
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
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
CONTROL = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FACADE = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
VALUE = 'perl/LinkedSpec/ActionIR/ValueExpr.pm'
OWNERS = (CONTROL, FACADE, VALUE)
FIXTURE = 't/actionir_control_default_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'faults.json')
assert not target.exists(), 'one-shot source fault loop'
capsule_raw = (ROOT / (PREFIX + 'complete-after-inputs.json.gz')).read_bytes()
capsule = json.loads(gzip.decompress(capsule_raw))
files = {p: decode(x['bytes_base64']) for p, x in capsule.items()}
modes = {p: x['mode'] for p, x in capsule.items()}
assert all((ROOT / p).read_bytes() == value for p, value in files.items())
before = json.loads(gzip.decompress((ROOT / (PREFIX + 'complete-before-inputs.json.gz')).read_bytes()))
sources = {p: files[p] for p in OWNERS}
variants = [('inverse', {p: decode(before[p]['bytes_base64']) for p in OWNERS})]

def variant(name, path, old, new):
    assert sources[path].count(old) == 1 and old != new, name
    selected = dict(sources)
    selected[path] = selected[path].replace(old, new, 1)
    variants.append((name, selected))

variant('facade-selection-bypass', CONTROL,
    b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'",
    b"if (0 && defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'")
fixed_guard = b'if (defined &LinkedSpec::ActionIR::ValueExpr::_register_builtin_control_emission_callback) {'
variant('fixed-selection-bypass', CONTROL, fixed_guard, b'if (0) {')
variant('flow-catalogue-union', FACADE,
    b'my @builtin_control_emission_callbacks = (',
    b'my @builtin_control_emission_callbacks = (\n \\&_extract_array_symbol_name,')
variant('wrong-fixed-definition', VALUE,
    b'my $builtin_control_emission_callback = \\&_extract_array_symbol_name;',
    b'my $builtin_control_emission_callback = \\&_lower_primitive_literal_expr;')
catalogue = sources[FACADE].split(b'my @builtin_control_emission_callbacks = (', 1)[1].split(b');', 1)[0]
names = re.findall(rb'\\&(_\w+)', catalogue)
assert len(names) == 7
variant('dynamic-facade-lookup', FACADE,
    b'for my $builtin (@builtin_control_emission_callbacks) {',
    b'for my $builtin (map {__PACKAGE__->can($_)} qw(' + b' '.join(names) + b')) {')
variant('dynamic-fixed-lookup', VALUE,
    b'_same_reference($callback, $builtin_control_emission_callback)',
    b"_same_reference($callback, __PACKAGE__->can('_extract_array_symbol_name'))")
variant('custom-facade-authority', CONTROL,
    b"defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'",
    b'defined($pkg)')
variant('fixed-provider-target-confusion', CONTROL, fixed_guard,
    b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'\n  && defined &LinkedSpec::ActionIR::ValueExpr::_register_builtin_control_emission_callback) {")
facade_loop = b'for my $builtin (@builtin_control_emission_callbacks) {\n  return LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($callback)\n   if LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin);\n }'
variant('all-facade-code-authorized', FACADE, facade_loop,
    facade_loop.replace(b'if LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin);', b'if 1;', 1))
variant('all-fixed-provider-code-authorized', VALUE,
    b'if LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin_control_emission_callback);', b'if 1;')
variant('scalar-list-build', CONTROL, b'my @deps = $build->();', b'my @deps = scalar $build->();')
variant('scalar-void-build', CONTROL,
    b'if (!defined wantarray) { $build->(); return }',
    b'if (!defined wantarray) { scalar $build->(); return }')
variant('void-cached-selection', CONTROL,
    b'if (!defined wantarray) { $build->(); return }',
    b'if (!defined wantarray) { $build->(); _select_default_emission_callbacks($pkg, {trim_action_ir_value => \\&LinkedSpec::RuleIR::EmitContext::_trim_action_ir_value, extract_array_symbol_name => \\&LinkedSpec::ActionIR::ValueExpr::_extract_array_symbol_name}); return }')
variant('copied-public-map', CONTROL, b'\n return $deps\n}\n\n1;', b'\n return {%$deps}\n}\n\n1;')
variant('localized-factory-error', CONTROL,
    b'sub _with_default_emission_selection {\n my ($pkg, $build) = @_;',
    b'sub _with_default_emission_selection {\n my ($pkg, $build) = @_; local $@;')
variant('eager-private-channel', VALUE,
    b'# ControlFlow\'s extractor has this fixed provider',
    b'require LinkedSpec::ActionIR::SourceEmissions;\n# ControlFlow\'s extractor has this fixed provider')
variant('twice-factory-effects', CONTROL,
    b'sub _with_default_emission_selection {\n my ($pkg, $build) = @_;',
    b'sub _with_default_emission_selection {\n my ($pkg, $build) = @_; $build->();')
assert len(variants) == 17
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
for name, selected_sources in variants:
    selected = files | selected_sources
    with tempfile.TemporaryDirectory(prefix='control-default-fault-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, value in selected.items():
            destination = supplied / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(value)
            destination.chmod(modes[path])
        commands = [['perl', '-c', '-Iperl', p] for p in OWNERS] + [['perl', '-Iperl', FIXTURE]]
        channels = []
        for command in commands:
            result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
            channels.append(dict(command=command, returncode=result.returncode,
                stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr)))
        actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
        actual_modes = {p: (supplied / p).stat().st_mode & 0o7777 for p in actual}
    text = decode(channels[-1]['stdout_base64']).decode()
    assertions = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    plans = re.findall(r'^1\.\.(\d+)$', text, re.M)
    failures = [dict(number=int(n), name=title) for bad, n, title in assertions if bad]
    row = dict(name=name, sources={p: dict(sha256=sha(v), bytes_base64=encode(v)) for p, v in selected_sources.items()},
        channels=channels, assertions=len(assertions), plans=plans, failures=failures,
        unchanged=actual == {p: sha(v) for p, v in selected.items()} and actual_modes == modes)
    rows.append(row)
    (ROOT / (PREFIX + 'faults-reached.json.gz')).write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
    assert row['unchanged'] and all(r['returncode'] == 0 for r in channels[:-1]), ('complete syntax', name)
    assert channels[-1]['returncode'] != 0 and failures, ('effective semantic fault', name)
    assert plans == ['445'] and len(assertions) == 445
    assert [int(n) for _, n, _ in assertions] == list(range(1, 446))
    assert not re.search(r'^Bail out!', text, re.M)
assert rows[0]['failures'] == json.loads((ROOT / (PREFIX + 'complete-before.json')).read_bytes())['failures']
assert all((ROOT / p).read_bytes() == value for p, value in files.items())
data = gzip.compress(json.dumps(rows, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
with (ROOT / (PREFIX + 'faults-data.json.gz')).open('xb') as output:
    output.write(data)
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
    positive_capsule_sha256=sha(capsule_raw), data_sha256=sha(data),
    variants=[dict(name=r['name'], assertions=r['assertions'], failures=len(r['failures'])) for r in rows],
    scope='Three complete actual owner sources, three syntax channels and full445-assertion semantic plan per supplied variant. All byte/mode inputs are preserved; live sources stay untouched. Exact three-owner inverse reproduces53 original failures by number/name. Exact provider populations, fixed/target distinction, retained actual definitions, contexts/returned maps, void no-selection, error/effects and lazy loading have distinguishing source controls. No exhaustive mutation or broader admission claim.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Mixed-default source faults PASS:', len(rows), 'effective variants;', [len(r['failures']) for r in rows])
