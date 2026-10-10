"""Readonly push required acceptance, native pairing and original set-key preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd74c534853832f6286813d924e018bd1bc6c2239'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_push_required_capture.t'
COLD = 't/actionir_method_push_required_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNERS = ['_lower_push_statement']
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
assert len(original) == 176 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 178 and 't/trace_emit_context_bridge.t' in inputs
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
for label, owner in zip(('push',), OWNERS):
    indent = ' '
    expected_source = edit(expected_source, owner, ' return $cb;',
                           ' return _bind_emission_dependency($cb);')
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
roles = ['parse_method_function_expr','extract_array_symbol_name',
         'trim_action_ir_value','lower_primitive_literal_expr']
assert [(r['arity'],r['role'],r['outcome']) for r in observations[0]['callbacks']] == [
 (arity,role,outcome) for arity in (2,3) for role in roles for outcome in ('string','undefined','fatal')]
expected_branches = [
 'ast-FAST','ast-0','ast-','ast-reference','parser-undefined','parser-other-method',
 'args-undefined','args-empty','args-one','args-four','two-normal','three-normal',
 'two-trim-0-undefined','two-trim-0-','two-trim-0-0',
 'two-trim-1-undefined','two-trim-1-','two-trim-1-0',
 'two-trim-2-undefined','two-trim-2-','two-trim-2-0',
 'two-trim-3-undefined','two-trim-3-','two-trim-3-0',
 'three-trim-0-undefined','three-trim-0-','three-trim-0-0',
 'three-trim-3-undefined','three-trim-3-','three-trim-3-0',
 'three-trim-4-undefined','three-trim-4-','three-trim-4-0',
 'symbol-undefined','symbol-','symbol-0','bare-target-fallback','word-target-fallback',
 'scope-undefined-nonbare','scope-undefined-bare','scope-undefined-digit','scope-empty-defined',
 'bare-primitive-undefined','bare-primitive-','bare-primitive-0',
 'value-undefined','value-','value-0','binding-undefined','binding-','binding-0',
 'push-reference','push-undefined','ambiguous-reference','ambiguous-undefined','undefined-input']
assert len(expected_branches) == len(set(expected_branches)) == 56
assert [r['case'] for r in observations[0]['branches']] == expected_branches
text = original[MODULE].decode()
start = text.index('sub ' + OWNERS[0] + ' {'); end = text.index('\nsub ',start+1)
body = text[start:end]
assert re.findall(r"\$require_dep->\('([^']+)'\)",body) == roles, 'required acquisition population'
assert body.index("$require_dep->('lower_primitive_literal_expr')") < body.index('_lower_ast_call_statement(')
assert '$effective_args = $raw_args;' in body
assert '$effective_args = [ $raw_args->[1], $raw_args->[2] ];' in body
assert body.count('$trim_action_ir_value->(') == 5
assert body.count('$extract_array_symbol_name->(') == 2
assert '$lower_primitive_literal_expr->($second_expr)' in body
assert "_uniform_binding_target_symbol($target_expr, 'array', $deps)" in body
public = observations[0]['public']
assert [(r['case'],r['source']) for r in public] == [
 ('child-index','push(items, 1)'),('child','push(Child, items)'),
 ('scoped-child-index','push(Top, items, 1)'),('removed-selector','push(array(items), 1)'),
 ('append','push(items, "v")'),('scoped-append','push(Top, items, "v")')]
for row in public[:3] + public[4:]:
    assert row['error'] is None and isinstance(row['value'],str) and row['value'] and row['value'] != row['source']
assert public[0]['value'] == 'push @Top, &{$$descr{spec}{items}{handler}}($descr, $STRING, $minfo)->[1]'
assert public[2]['value'] == 'push @items, &{$$descr{spec}{Top}{handler}}($descr, $STRING, $minfo)->[1]'
assert '$__ls_push_handler' in public[1]['value'] and 'LinkedSpec::BindingRuntime::push_value' in public[1]['value']
assert public[3]['value'] is None and public[3]['error'] == 'aggregate_selector_removed surface=array identifier=items replacement=items\n'
assert public[4]['value'] == public[5]['value'] == 'do { require LinkedSpec::BindingRuntime; $items = LinkedSpec::BindingRuntime::push_value($items, "items", "v") }'
positive = record(CAPTURE_PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 850)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive push required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 16
assert out.count(b'required diagnostic retains native selection') == 16
positive_out = out
before_row = record(CAPTURE_PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 850)
assert before_row['returncode'] == 24 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for arity in (2,3) for role in roles for reason in (
    OWNERS[0] + '/' + str(arity) + '/' + role + '/0 required dependency cannot donate nested publication',
    OWNERS[0] + '/' + str(arity) + '/' + role + '/0 actual callback has its own identity boundary',
    OWNERS[0] + '/' + str(arity) + '/' + role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 24, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(CAPTURE_PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 15)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(CAPTURE_PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=58,', out), 'direct consumer population'

source = read(MODULE).decode()
variants = []
for label, owner in zip(('push',), OWNERS):
    indent = ' '
    role = 'parse_method_function_expr'
    seam = ' return _bind_emission_dependency($cb);'
    diagnostic = indent + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indent + "  unless ref($cb) eq 'CODE';"
    variants.extend([
        (label + '-required', edit(source, owner, seam, ' return $cb;'),
         owner + '/2/' + role + '/0 required dependency cannot donate nested publication'),
        (label + '-identity', edit(source, owner, seam, ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
         owner + '/2/' + role + '/1 actual callback has its own identity boundary'),
        (label + '-diagnostic', edit(source, owner, diagnostic, ''),
         owner + '/2/' + role + ' required diagnostic retains native selection'),
    ])
index = record(CAPTURE_PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 850
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
    tap(out, 850)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

# Preserve and independently reconstruct the initial instrument-only correction.
draft = PREFIX + 'initial-probe/'
correction = record(draft + 'correction.json')
assert correction['observed'] == {'callbacks':24,'branches':56,'public':4}
assert correction['incorrect_driver_branch_count'] == 55 and correction['source_changed'] is False
assert set(correction['inputs']) == {'capture.py','native.json',Path(TEST).name,Path(COLD).name}
for name, expected_hash in correction['inputs'].items():
    assert digest(read(draft + name)) == expected_hash, 'initial instrument input drift'
initial_producer = read(draft + 'capture.py')
expected_producer = initial_producer.decode().replace(
    "len(observed['branches']) == 55 and len(observed['public']) == 4",
    "len(observed['branches']) == 56 and len(observed['public']) == 6").replace(
    'and55 controlled branches/four public rows','and56 controlled branches/six public rows').replace(
    "owner + '/' + role + ' required diagnostic retains native selection'",
    "owner + '/2/' + role + ' required diagnostic retains native selection'")
assert producer == expected_producer.encode(), 'correction exceeds driver counts and diagnostic name'
initial_fixture = read(draft + Path(TEST).name)
expected_fixture = initial_fixture.decode().replace(
    "['append', 'push(items, 1)']", "['child-index', 'push(items, 1)']").replace(
    "['scoped-append', 'push(Top, items, 1)']", "['scoped-child-index', 'push(Top, items, 1)']").replace(
    "['removed-selector', 'push(array(items), 1)']);",
    "['removed-selector', 'push(array(items), 1)'],\n  ['append', 'push(items, \"v\")'], ['scoped-append', 'push(Top, items, \"v\")']);")
assert read(TEST) == expected_fixture.encode(), 'correction exceeds public labels and added quoted-value probes'
assert read(draft + Path(COLD).name) == read(COLD)
initial = record(draft + 'native.json')
assert initial['base'] == BASE and initial['seed'] == SEED and initial['seed_sha256'] == digest(seed_raw)
assert initial['producer_sha256'] == digest(initial_producer)
assert initial['inputs'] == dict(before_population, **{TEST:digest(initial_fixture)})
assert initial['command'] == ['perl','-Iperl',TEST,'observe']
assert initial['returncode'] == 0 and initial['unchanged'] is True
assert not base64.b64decode(initial['stderr_base64'],validate=True)
initial_observations = json.loads(base64.b64decode(initial['stdout_base64'],validate=True))
assert initial_observations['callbacks'] == observations[0]['callbacks']
assert initial_observations['branches'] == observations[0]['branches']
initial_public = initial_observations['public']
assert len(initial_public) == 4
initial_public[0]['case'] = 'child-index'
initial_public[2]['case'] = 'scoped-child-index'
assert initial_public == observations[0]['public'][:4], 'initial actual public observations replaced'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 296
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
assert names == freeze['live_claims'] == ['set-key-required-isolation']
assert len(bindings) == 296
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result':'PASS','base':BASE,'assertions':850,'cold_assertions':15,
 'actual_caller_modes':24,'bounded_branch_modes':56,'required_callers':1,'required_callback_roles':4,
 'actually_invoked_roles':4,'actual_path_role_targets':8,'validated_only_roles':0,
 'paired_original_semantic_failures':24,'paired_original_passing_controls':826,'semantic_source_faults':3,
 'consumer_suites':58,'supplied_files':len(inputs),'historical_bindings_preserved':len(bindings),
 'instrument_correction':{'initial_callbacks':24,'initial_branches':56,'initial_public':4,'added_public':2,'callback_branch_observations_unchanged':True},
 'checked':dict(sorted(checked.items())),'reviewer_sha256':digest(Path(__file__).read_bytes()),'public_toolbox_rows':6,
 'scope':('Only one push required resolver return. Four eager roles across two/three arguments in24 native-current outcomes '
          'and56 independently enumerated controlled branches, six actual public Toolbox rows. Raw/effective arrays, repeated '
          'trim/extractor effects and local scalar slots, actual maps/context/errors/fatal/reference identities remain native. '
          'Secondary AST/value/uniform-target/push/ambiguity helpers are controls. Paired24 original publication REDs/826 '
          'controls become850 GREEN; three syntax-valid faults, supplied58 suites/178 files, all296 original set-key '
          'bindings and the complete instrument-only initial correction remain recoverable. No complete helper/AST/language, '
          'optional/direct/output/mapped/full-private/canonical or parent admission. Read-only toolchain; repository-volume scratch.')}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained push required review drift'
print('Push required review PASS850/15/3; callbacks24/branches56/public6; paired24RED/850GREEN; consumers58/178; original296 preserved')
