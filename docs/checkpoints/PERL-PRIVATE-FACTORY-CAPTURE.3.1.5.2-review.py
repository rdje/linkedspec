"""Readonly assignment required acceptance, native pairing and original generalized-return preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2b1f949b897cc8fac8f87f7652ad67eb90241479'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-complete-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_assignment_required_capture.t'
COLD = 't/actionir_method_assignment_required_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNERS = ['_lower_assign_statement', '_lower_scalar_assignment_operator_statement', '_lower_array_append_operator_statement']
CAPTURE_PREFIX = PREFIX
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(path):
    return json.loads(read(path))


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


seed_raw = read(SEED)
assert seed_raw == blob(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
original = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(original) == 172 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 174 and 't/trace_emit_context_bridge.t' in inputs
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3
for path in (PUBLIC_TEST, PUBLIC_CONTRACT):
    assert read(path) == blob(path), 'public uniform-binding input changed'
producer = read(CAPTURE_PREFIX + 'capture.py')


def edit(source, owner, old, new):
    start = source.index('sub ' + owner + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


expected_source = original[MODULE].decode()
for label, owner in zip(('wrapper', 'scalar', 'append'), OWNERS):
    indent = ' '
    expected_source = edit(expected_source, owner, indent + ' return $cb;',
                           indent + ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds three required return seams'


def channel(row, population, command):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(producer), 'capture producer identity'
    assert row['inputs'] == population, 'supplied input population/content mismatch'
    assert row['command'] == command and row['unchanged'] is True
    return (base64.b64decode(row['stdout_base64'], validate=True),
            base64.b64decode(row['stderr_base64'], validate=True))


def tap(raw, count):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [str(count).encode()], 'incomplete TAP plan'
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)] == list(range(1, count + 1)), 'incomplete TAP population'


observations = []
for name in ('native', 'observe'):
    row = record(CAPTURE_PREFIX + name + '.json')
    population = dict(inputs, **{MODULE: seed['inputs'][MODULE]}) if name == 'native' else inputs
    out, err = channel(row, population, ['perl', '-Iperl', TEST, 'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native dependency/caller observation changed'
roles = [
 (OWNERS[0],'trim_action_ir_value','scalar'), (OWNERS[0],'extract_scalar_symbol_name','scalar'),
 (OWNERS[0],'extract_array_symbol_name','array'), (OWNERS[0],'extract_hash_symbol_name','hash'),
 (OWNERS[0],'lower_assignment_source_expr','scalar'), (OWNERS[0],'lower_declare_initializer_expr','array'),
 (OWNERS[0],'lower_declare_initializer_expr','hash'), (OWNERS[1],'trim_action_ir_value','fallback'),
 (OWNERS[2],'trim_action_ir_value','fallback')]
assert [(r['owner'],r['role'],r['route'],r['outcome']) for r in observations[0]['callbacks']] == [
 (('assign' if owner == OWNERS[0] else 'scalar' if owner == OWNERS[1] else 'append'),role,route,outcome)
 for owner,role,route in roles for outcome in ('string','undefined','fatal')]
expected_branches = [
 'assign-retired','assign-bare','assign-binding-','assign-binding-0','assign-binding-undefined','assign-binding-reference',
 'assign-array-held','assign-array-kind-undefined','assign-array-kind-array','assign-array-noncode-kind',
 'assign-hash-held','assign-hash-kind-undefined','assign-hash-kind-array','assign-hash-noncode-kind','assign-unsupported',
 'assign-target-undefined','assign-target-','assign-target-0',
 'assign-scalar-value-','assign-scalar-value-0','assign-scalar-value-undefined',
 'assign-array-value-','assign-array-value-0','assign-array-value-undefined',
 'assign-hash-value-','assign-hash-value-0','assign-hash-value-undefined','assign-source-reference',
 'scalar-input-undefined','scalar-input-','scalar-input-not an assignment','scalar-input-x == y','scalar-input-x => y',
 'scalar-ast-FAST','scalar-ast-0','scalar-ast-','scalar-ast-reference','scalar-rhs-','scalar-binding-',
 'scalar-rhs-0','scalar-binding-0','scalar-rhs-undefined','scalar-binding-undefined','scalar-final-undefined',
 'append-input-undefined','append-input-','append-input-not an assignment','append-input-x = y','append-input-x + y',
 'append-ast-FAST','append-ast-0','append-ast-','append-ast-reference','append-rhs-','append-mutation-',
 'append-rhs-0','append-mutation-0','append-rhs-undefined','append-mutation-undefined','append-final-undefined']
assert len(expected_branches) == len(set(expected_branches)) == 60
assert [r['case'] for r in observations[0]['branches']] == expected_branches
bodies = []
required_roles = [['extract_scalar_symbol_name','extract_array_symbol_name','extract_hash_symbol_name',
                  'lower_assignment_source_expr','lower_declare_initializer_expr','trim_action_ir_value'],
                  ['trim_action_ir_value'],['trim_action_ir_value']]
for owner, required in zip(OWNERS, required_roles):
    text = original[MODULE].decode()
    start = text.index('sub ' + owner + ' {'); end = text.index('\nsub ',start+1)
    body=text[start:end]; bodies.append(body)
    assert re.findall(r"\$require_dep->\('([^']+)'\)",body) == required, 'required acquisition population'
    assert body.index("$require_dep->('trim_action_ir_value')") < body.index('$trim_action_ir_value->(')
assert bodies[0].index("$require_dep->('trim_action_ir_value')") < bodies[0].index('if (defined($target_trimmed)')
assert "->('array', $source)" in bodies[0] and "->('hash', $source)" in bodies[0]
for body,kind in zip(bodies[1:],('assign_scalar','assign_array_append')):
    assert body.count('$trim_action_ir_value->(') == 2
    assert body.index('_lower_ast_assignment_operator_statement(') < body.index('return undef unless $trimmed =~')
    assert "'"+kind+"'" in body
public = observations[0]['public']
assert [(r['case'],r['source']) for r in public] == [
 ('set','set(counter, 1)'),('scalar','counter = 1'),('append','items += 1'),
 ('array-selector','set(array(items), 1)'),('hash-selector','set(hash(meta), 1)')]
for row in public[:3]:
    assert row['error'] is None and isinstance(row['value'],str) and row['value']
for row,surface,name in zip(public[3:],('array','hash'),('items','meta')):
    assert row['value'] is None and row['error'] == f'aggregate_selector_removed surface={surface} identifier={name} replacement={name}\n'
positive = record(CAPTURE_PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 938)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive assignment required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 18
assert out.count(b'required diagnostic retains native selection') == 16
positive_out = out
before_row = record(CAPTURE_PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 938)
assert before_row['returncode'] == 27 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for owner, role, route in roles for reason in (
    owner + '/' + role + '/' + route + '/0 required dependency cannot donate nested publication',
    owner + '/' + role + '/' + route + '/0 actual callback has its own identity boundary',
    owner + '/' + role + '/' + route + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 27, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(CAPTURE_PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 17)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(CAPTURE_PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=54,', out), 'direct consumer population'

source = read(MODULE).decode()
variants = []
for label, owner in zip(('wrapper', 'scalar', 'append'), OWNERS):
    indent = ' '
    role = 'extract_scalar_symbol_name' if label == 'wrapper' else 'trim_action_ir_value'
    route = 'scalar' if label == 'wrapper' else 'fallback'
    seam = indent + ' return _bind_emission_dependency($cb);'
    diagnostic = indent + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indent + "  unless ref($cb) eq 'CODE';"
    variants.extend([
        (label + '-required', edit(source, owner, seam, indent + ' return $cb;'),
         owner + '/' + role + '/' + route + '/0 required dependency cannot donate nested publication'),
        (label + '-identity', edit(source, owner, seam, indent + ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
         owner + '/' + role + '/' + route + '/1 actual callback has its own identity boundary'),
        (label + '-diagnostic', edit(source, owner, diagnostic, ''),
         owner + '/' + role + ' required diagnostic retains native selection'),
    ])
index = record(CAPTURE_PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 938
assert len(index['rows']) == 9, 'missing inverse'
for (name, changed, reason), item in zip(variants, index['rows']):
    path = CAPTURE_PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    assert item == {'case': name, 'path': path, 'sha256': digest(raw), 'source_sha256': source_hash,
                    'reason': reason, 'observed': 'RED'}, 'inverse index identity'
    assert row['case'] == name and row['source_sha256'] == source_hash and row['distinguishing_reason'] == reason
    population = dict(inputs, **{MODULE: source_hash})
    syntax_out, syntax_err = channel(row['syntax'], population, ['perl', '-Iperl', '-c', MODULE])
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in syntax_err, 'invalid source fault'
    out, err = channel(row, population, ['perl', '-Iperl', TEST])
    tap(out, 938)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 306
assert freeze['producer_sha256'] == digest(read(PREFIX + 'freeze.py'))
before = read(freeze['before'])
assert before == blob(CLAIM) and digest(before) == freeze['original_sha256']
old = json.loads(before)
bindings, names = [], []
for claim in old['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        names.append(claim['name'])
        bindings.extend(durability['inputs'])
        durability.update(mode='historical', revision=BASE)
assert names == freeze['live_claims'] == ['general-return-required-isolation']
assert len(bindings) == 306
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result':'PASS','base':BASE,'assertions':938,'cold_assertions':17,
 'actual_caller_modes':27,'bounded_branch_modes':60,'required_callers':3,'required_callback_roles':8,
 'actually_invoked_roles':8,'actual_path_role_targets':9,'validated_only_roles':0,
 'paired_original_semantic_failures':27,'paired_original_passing_controls':911,'semantic_source_faults':9,
 'consumer_suites':54,'supplied_files':len(inputs),'historical_bindings_preserved':len(bindings),
 'checked':dict(sorted(checked.items())),'reviewer_sha256':digest(Path(__file__).read_bytes()),'public_toolbox_rows':5,
 'scope':('Only three required resolver returns in assignment wrapper, scalar assignment operator and array append operator. '
          'Eight invoked owner/role pairs across nine path/role targets in27 native-current rows and60 independently enumerated controlled branches. '
          'Eager validation, actual maps, local source/target copies, readonly kind versus writable initializer source, '
          'two distinct operator trim slots and actual RHS helper slot, contexts/effects/errors/fatal/reference identities remain native. '
          'Five named public Toolbox rows retain existing assignment lowerings and array/hash selector rejection. '
          'Secondary AST/value/tracked/push/migration helpers are explicit controls; optional kind selection is preserved, not isolated. '
          'No complete helper/AST/language, optional/direct/output/mapped/full-private/canonical or parent admission. '
          'Paired27 original publication REDs/911 controls become938 GREEN; nine syntax-valid faults, supplied54 suites/174 files '
          'and all306 original generalized-return bindings remain recoverable. Read-only toolchain; repository-volume scratch.')}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained assignment required review drift'
print('Assignment required review PASS938/17/9; callbacks27/branches60/public5; paired27RED/938GREEN; consumers54/174; original306 preserved')
