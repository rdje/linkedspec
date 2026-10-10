"""Readonly set-key required acceptance, native pairing and original assignment preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'ea6926fefee33cbf77fe512a821d7ba2a4ffc14f'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_set_key_required_capture.t'
COLD = 't/actionir_method_set_key_required_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNERS = ['_lower_set_key_statement']
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
assert len(original) == 174 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 176 and 't/trace_emit_context_bridge.t' in inputs
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
for label, owner in zip(('set-key',), OWNERS):
    indent = ' '
    expected_source = edit(expected_source, owner, indent + ' return $cb;',
                           indent + ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds one required return seam'


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
roles = ['parse_method_function_expr','normalize_method_args_with_optional_scope',
         'extract_hash_symbol_name','lower_scalar_access_key_expr','trim_action_ir_value']
assert [(r['role'],r['outcome']) for r in observations[0]['callbacks']] == [
 (role,outcome) for role in roles for outcome in ('string','undefined','fatal')]
expected_branches = [
 'ast-FAST','ast-0','ast-','ast-reference','parser-undefined','parser-other-method',
 'normalized-undefined','normalized-','normalized-0','normalized-empty-array','normalized-distinct-array',
 'args-undefined','args-empty','trim-0-undefined','trim-0-','trim-0-0','trim-1-undefined','trim-1-','trim-1-0',
 'trim-2-undefined','trim-2-','trim-2-0','symbol-undefined','key-undefined','value-undefined',
 'symbol-','key-','value-','symbol-0','key-0','value-0','binding-undefined','binding-','binding-0',
 'index-reference','index-undefined','undefined-input']
assert len(expected_branches) == len(set(expected_branches)) == 37
assert [r['case'] for r in observations[0]['branches']] == expected_branches
text = original[MODULE].decode()
start = text.index('sub ' + OWNERS[0] + ' {'); end = text.index('\nsub ',start+1)
body = text[start:end]
assert re.findall(r"\$require_dep->\('([^']+)'\)",body) == roles, 'required acquisition population'
assert body.index("$require_dep->('trim_action_ir_value')") < body.index('_lower_ast_call_statement(')
assert '$normalize_method_args_with_optional_scope->($call->{args} || [], 3, 3)' in body
assert body.count('$trim_action_ir_value->(') == 3
for name,index in (('target',0),('key',1),('value',2)):
    assert f'my ${name}_expr = $trim_action_ir_value->($effective_args->[{index}]);' in body
assert '$extract_hash_symbol_name->($target_expr)' in body and '$lower_scalar_access_key_expr->($key_expr)' in body
assert "_uniform_binding_target_symbol($target_expr, 'hash', $deps)" in body
public = observations[0]['public']
assert [(r['case'],r['source']) for r in public] == [
 ('statement','set_key(meta, "key", 1)'),('pure-return','return(set_key(meta, "key", 1))'),
 ('removed-selector','set_key(hash(meta), "key", 1)')]
for row in public[:2]:
    assert row['error'] is None and isinstance(row['value'],str) and row['value'] and row['value'] != row['source']
assert 'LinkedSpec::BindingRuntime::index_set' in public[0]['value']
assert public[1]['value'].startswith('return do {') and 'my %__ls_set_key' in public[1]['value']
assert public[2]['value'] is None and public[2]['error'] == 'aggregate_selector_removed surface=hash identifier=meta replacement=meta\n'
positive = record(CAPTURE_PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 539)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive set-key required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 10
assert out.count(b'required diagnostic retains native selection') == 10
positive_out = out
before_row = record(CAPTURE_PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 539)
assert before_row['returncode'] == 15 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for role in roles for reason in (
    OWNERS[0] + '/' + role + '/0 required dependency cannot donate nested publication',
    OWNERS[0] + '/' + role + '/0 actual callback has its own identity boundary',
    OWNERS[0] + '/' + role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 15, 'unexpected original failure set'
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
assert re.search(rb'Files=56,', out), 'direct consumer population'

source = read(MODULE).decode()
variants = []
for label, owner in zip(('set-key',), OWNERS):
    indent = ' '
    role = 'parse_method_function_expr'
    seam = indent + ' return _bind_emission_dependency($cb);'
    diagnostic = indent + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indent + "  unless ref($cb) eq 'CODE';"
    variants.extend([
        (label + '-required', edit(source, owner, seam, indent + ' return $cb;'),
         owner + '/' + role + '/0 required dependency cannot donate nested publication'),
        (label + '-identity', edit(source, owner, seam, indent + ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
         owner + '/' + role + '/1 actual callback has its own identity boundary'),
        (label + '-diagnostic', edit(source, owner, diagnostic, ''),
         owner + '/' + role + ' required diagnostic retains native selection'),
    ])
index = record(CAPTURE_PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 539
assert len(index['rows']) == 3, 'missing inverse'
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
    tap(out, 539)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 300
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
assert names == freeze['live_claims'] == ['assignment-required-isolation']
assert len(bindings) == 300
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result':'PASS','base':BASE,'assertions':539,'cold_assertions':17,
 'actual_caller_modes':15,'bounded_branch_modes':37,'required_callers':1,'required_callback_roles':5,
 'actually_invoked_roles':5,'actual_path_role_targets':5,'validated_only_roles':0,
 'paired_original_semantic_failures':15,'paired_original_passing_controls':524,'semantic_source_faults':3,
 'consumer_suites':56,'supplied_files':len(inputs),'historical_bindings_preserved':len(bindings),
 'checked':dict(sorted(checked.items())),'reviewer_sha256':digest(Path(__file__).read_bytes()),'public_toolbox_rows':3,
 'scope':('Only one set-key statement required resolver return. Five invoked required roles in15 native-current outcomes '
          'and37 independently enumerated controlled branches. Eager acquisition before AST fast path, actual parser/normalizer '
          'arrays and readonly literal arities, trim array slots versus local target/key/value copies, shared extractor/binding '
          'local target, actual maps/context/effects/errors/fatal/reference identities remain native. Three named public Toolbox '
          'rows retain statement mutation, pure-value copying and removed hash-selector rejection. '
          'Secondary AST/mutation/uniform-target/index helpers remain explicit controls. No complete helper/AST/language, '
          'optional/direct/output/mapped/full-private/canonical or parent admission. Paired15 original publication REDs/524 '
          'controls become539 GREEN; three syntax-valid faults, supplied56 suites/176 files and all300 original assignment '
          'bindings remain recoverable. Read-only toolchain; repository-volume scratch.')}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained set-key required review drift'
print('Set-key required review PASS539/17/3; callbacks15/branches37/public3; paired15RED/539GREEN; consumers56/176; original300 preserved')
