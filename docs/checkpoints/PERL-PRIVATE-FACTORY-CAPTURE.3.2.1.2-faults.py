"""One-shot nine full-source optional-kind counterfactuals with complete channels."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBES = ('t/actionir_small_kind_probe.pl', 't/actionir_small_kind_symbolic_probe.pl', 't/actionir_small_kind_reference_probe.pl')
TEST = 't/actionir_small_kind_capture.t'
NATIVES = tuple(PREFIX + tail for tail in ('native.json', 'symbolic-native.json', 'reference-native.json', 'reference-native-final.json'))
TARGET = ROOT / (PREFIX + 'inverses.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
assert not TARGET.exists(), 'one-shot source-fault capture'
seed = json.loads(subprocess.check_output(['git', 'show', BASE + ':' + SEED], cwd=ROOT))
files = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in seed['inputs']}
current = (ROOT / MODULE).read_bytes()
files[MODULE] = current
for p in PROBES + (TEST,) + NATIVES:
    assert p not in files
    files[p] = (ROOT / p).read_bytes()
assert len(files) == 223
positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
assert positive['returncode'] == 0 and positive['unchanged']
assert positive['inputs'] == {p: sha(raw) for p, raw in files.items()}
names = {'infer': ('_infer_assignment_source_container_kind', '_lower_value_binding_source_expr'),
    'target': ('_uniform_binding_target_symbol', '_uniform_binding_hash_index_set_expr'),
    'candidate': ('_codeblock_variable_call_candidate', '_codeblock_runtime_binding_expr')}
spans = {}
for key, (name, following) in names.items():
    start = current.index(('sub ' + name + ' {').encode())
    end = current.index(('sub ' + following + ' {').encode(), start)
    spans[key] = (start, end)


def specification(name):
    specs = []
    owners = [name[4:]] if name.startswith('raw-') else list(names)
    for owner in owners:
        selected = '$selected_kind' if owner == 'candidate' else '$bare_symbol_kind'
        argument = '$1' if owner == 'infer' else '$name'
        choice = ('ref(' + selected + ") eq 'CODE' ? " + selected + ' : sub { return ' + selected + '->(@_) }').encode()
        call = ('_bind_emission_dependency($kind_callback)->(' + argument + ')').encode()
        if name.startswith('raw-'):
            if owner == 'infer':
                old = b'   my $kind_callback = ' + choice + b';\n   my $kind = ' + call + b';'
                new = b'   my $kind = $bare_symbol_kind->($1);\n'
            elif owner == 'target':
                old = b' my $kind_callback = ' + choice + b";\n return ((" + call + b" // '') eq 'scalar') ? $name : undef"
                new = b" return (($bare_symbol_kind->($name) // '') eq 'scalar') ? $name : undef\n"
            else:
                old = b' my $selected_kind = $deps->{bare_symbol_kind};\n my $kind_callback = ' + choice + b";\n return ((" + call + b" // '') eq 'scalar') ? 1 : 0"
                new = b"\n return (($deps->{bare_symbol_kind}->($name) // '') eq 'scalar') ? 1 : 0\n"
        elif name == 'wrapper-identity':
            old = choice
            new = ('ref(' + selected + ") eq 'CODE' ? sub { return " + selected + '->(@_) } : sub { return ' + selected + '->(@_) }').encode()
        elif name == 'argument-copy':
            old = call
            new = ('(sub { my ($copy) = @_; return _bind_emission_dependency($kind_callback)->($copy) })->(' + argument + ')').encode()
        elif name == 'object-coercion':
            if owner != 'candidate':
                continue
            old, new = call, b"_bind_emission_dependency($kind_callback)->(''.$name)"
        elif name == 'code-validation':
            old, new = b"ref($deps->{bare_symbol_kind}) eq 'CODE'", b'defined($deps->{bare_symbol_kind})'
        elif name == 'early-function-decision':
            if owner != 'candidate':
                continue
            old = b" return $function_names->{$name} ? 1 : 0 if ref($function_names) eq 'HASH';"
            new = b''
        else:
            assert name == 'name-authority'
            old, new = choice, ('ref(' + selected + ") eq 'CODE' ? " + selected + ' : \\&{' + selected + '}').encode()
        specs.append({'owner': owner, 'old_base64': b64(old), 'new_base64': b64(new)})
    return specs


cases = [
    ('raw-infer', 'small kind infer/known0 child cannot donate parent packet'),
    ('raw-target', 'small kind target/known0 child cannot donate parent packet'),
    ('raw-candidate', 'small kind candidate/known0 child cannot donate parent packet'),
    ('wrapper-identity', 'small kind infer/known1 actual selected CODE controls eligibility'),
    ('argument-copy', 'small kind infer/effect complete native observation'),
    ('object-coercion', 'reference kind effect/known0 actual object argument identity survives'),
    ('code-validation', 'small kind infer/kind-string complete native observation'),
    ('early-function-decision', 'small kind candidate/function-name-absent independent authored result'),
    ('name-authority', 'symbolic kind infer/qualified/known1 selected non-CODE remains opaque'),
]
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def run(command, directory):
    result = subprocess.run(command, cwd=directory, env=environment, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr)}


rows = []
for name, reason in cases:
    specs = specification(name)
    modified = {key: current[start:end] for key, (start, end) in spans.items()}
    for spec in specs:
        owner = modified[spec['owner']]
        old, new = (base64.b64decode(spec[key]) for key in ('old_base64', 'new_base64'))
        assert owner.count(old) == 1, ('exact scoped source fault', name, spec['owner'])
        modified[spec['owner']] = owner.replace(old, new, 1)
    mutated = current
    for key, (start, end) in sorted(spans.items(), key=lambda row: row[1][0], reverse=True):
        mutated = mutated[:start] + modified[key] + mutated[end:]
    supplied_files = dict(files, **{MODULE: mutated})
    inputs = {p: sha(raw) for p, raw in supplied_files.items()}
    with tempfile.TemporaryDirectory(prefix='small-kind-fault-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for p, raw in supplied_files.items():
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        syntax = run(['perl', '-Iperl', '-c', MODULE], supplied)
        probes = [run(['perl', '-Iperl', './' + p] + (['observe'] if index == 0 else []), supplied)
                  for index, p in enumerate(PROBES)]
        fixture = run(['perl', '-Iperl', TEST], supplied)
        unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == inputs
    stdout = base64.b64decode(fixture['stdout_base64'])
    plans = re.findall(rb'^1\.\.(\d+)$', stdout, re.M)
    assertions = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', stdout, re.M)
    failed = [label.decode() for flag, _, label in assertions if flag]
    artifact = PREFIX + 'inverse-' + name + '.json'
    record = {'name': name, 'module_base64': b64(mutated), 'inputs': inputs, 'replacement': specs,
        'syntax': syntax, 'probes': probes, 'fixture': fixture, 'unchanged': unchanged,
        'failures': failed, 'required_reason': reason, 'producer_sha256': sha(Path(__file__).read_bytes())}
    assert not (ROOT / artifact).exists()
    (ROOT / artifact).write_text(json.dumps(record, indent=2) + '\n')
    rows.append({'name': name, 'artifact': artifact, 'artifact_sha256': sha((ROOT / artifact).read_bytes()),
        'failure_count': len(failed), 'required_reason': reason})
    TARGET.write_text(json.dumps({'result': 'pending', 'rows': rows}, indent=2) + '\n')
    assert syntax['returncode'] == 0 and b'syntax OK' in base64.b64decode(syntax['stderr_base64'])
    assert all(row['returncode'] == 0 and not base64.b64decode(row['stderr_base64']) for row in probes)
    assert unchanged and len(plans) == 1 and int(plans[0]) == 1135
    assert [int(number) for _, number, _ in assertions] == list(range(1, 1136))
    assert fixture['returncode'] != 0 and reason in failed, ('actual distinguishing source-fault RED', name, failed)
report = {'result': 'PASS', 'rows': rows, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'module_sha256': sha(current), 'scope': 'Nine complete scoped whole-source syntax-valid faults, each223-input capsule, all three actual probes and identical1135 TAP. Named reasons distinguish each actual boundary, callback identity/aliases/object/CODE guard/early decision and forbidden name-based authority. Every full source/channel/input identity is retained before interpretation; no native observation is refreshed.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Small optional-kind source faults PASS:', [(row['name'], row['failure_count']) for row in rows])
