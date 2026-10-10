"""Readonly generalized-return required acceptance, native pairing and original main method/value preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2c5f84092d91c808ab82b4b886b51e65fc1ac864'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_general_return_capture.t'
COLD = 't/actionir_method_general_return_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNERS = ['_lower_return_payload_expr', '_lower_return_general_statement']
CAPTURE_PREFIX = PREFIX + 'complete-'
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
assert len(original) == 170 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 172 and 't/trace_emit_context_bridge.t' in inputs
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
for label, owner in zip(('payload', 'statement'), OWNERS):
    indent = ' '
    expected_source = edit(expected_source, owner, indent + ' return $cb;',
                           indent + ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds two required return seams'


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
roles = [(OWNERS[0], 'trim_action_ir_value'), (OWNERS[1], 'parse_method_function_expr'),
         (OWNERS[1], 'trim_action_ir_value')]
assert [(r['owner'], r['role'], r['outcome']) for r in observations[0]['callbacks']] == [
    (('payload' if owner == OWNERS[0] else 'statement'), role, outcome)
    for owner, role in roles for outcome in ('string', 'undefined', 'fatal')]
expected_branches = [
 'payload-input-undefined', 'payload-input-', 'payload-trim-', 'payload-trim-0', 'payload-trim-undefined',
 'payload-kind-call', 'payload-kind-raw_perl', 'payload-kind-variable', 'payload-kind-', 'payload-ast_undefined',
 'payload-ast_nonhash', 'payload-direct-', 'payload-direct-0', 'payload-direct-undefined', 'payload-equal-payload',
 'payload-equal-array(x,y)', 'payload-equal-trim(x)', 'payload-equal-and(x,y)', 'payload-bare-BARE', 'payload-bare-',
 'payload-bare-0', 'payload-bare-undefined', 'payload-direct-reference', 'payload-bare-reference',
 'payload-rewrite-raw(trim(x))', 'payload-rewrite-raw(trim("x(y)"))', 'payload-rewrite-raw(and(x,y))', 'payload-rewrite-limit',
 'statement-ast-FAST', 'statement-ast-0', 'statement-ast-', 'statement-ast-reference', 'statement-parser-undefined',
 'statement-parser-other-method', 'statement-parser-missing-args', 'statement-parser-nonarray-args', 'statement-parser-empty-args',
 'statement-undefined-input', 'statement-single-', 'statement-single-0', 'statement-single-undefined', 'statement-label-Node',
 'statement-label-0', 'statement-label-bad-label', 'statement-label-', 'statement-label-undefined', 'statement-fallback-',
 'statement-fallback-0', 'statement-fallback-undefined', 'statement-multiple', 'statement-fallback-empty', 'statement-fallback-slot-mutation']
assert len(expected_branches) == len(set(expected_branches)) == 52
assert [r['case'] for r in observations[0]['branches']] == expected_branches
bodies = []
for owner, required in zip(OWNERS, (['trim_action_ir_value'], ['parse_method_function_expr', 'trim_action_ir_value'])):
    text = original[MODULE].decode()
    start = text.index('sub ' + owner + ' {')
    end = text.index('\nsub ', start + 1)
    body = text[start:end]; bodies.append(body)
    assert re.findall(r"\$require_dep->\('([^']+)'\)", body) == required, 'required acquisition population'
assert bodies[0].index('return undef unless defined $expr;') < bodies[0].index("$require_dep->('trim_action_ir_value')")
assert bodies[1].index("$require_dep->('parse_method_function_expr')") < bodies[1].index('_lower_ast_call_statement(')
assert bodies[1].index('if (@$args >= 2)') < bodies[1].index("$require_dep->('trim_action_ir_value')")
assert 'for (1 .. 64)' in bodies[0] and 'foreach my $payload_arg (@{$args}[1 .. $#$args])' in bodies[1]
expected_public = [
 {'case': 'retired-'+name, 'error': None, 'source': src, 'value': src} for name, src in
 [('a','return_a(Top)'),('m','return_m(Top)'),('ma','return_ma(Top)'),('imatch','return_imatch("tag")'),('im','return_im("tag")'),('array','return_array(Top,1)')]]
expected_public += [
 {'case':'undefined','error':None,'source':'return_undef()','value':'return undef'},
 {'case':'old-migration','error':'aggregate_selector_removed surface=array identifier=Top replacement=Top\n','source':'return(array_copy(array(Top)))','value':None},
 {'case':'current-copy','error':None,'source':'return(array(copy(Top)))','value':'return [[@Top]]'}]
assert observations[0]['public'] == expected_public
positive = record(CAPTURE_PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 574)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive generalized-return required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 6
assert out.count(b'required diagnostic retains native selection') == 6
positive_out = out
before_row = record(CAPTURE_PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 574)
assert before_row['returncode'] == 9 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for owner, role in roles for reason in (
    owner + '/' + role + '/0 required dependency cannot donate nested publication',
    owner + '/' + role + '/0 actual callback has its own identity boundary',
    owner + '/' + role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 9, 'unexpected original failure set'
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
assert re.search(rb'Files=52,', out), 'direct consumer population'

source = read(MODULE).decode()
variants = []
for label, owner in zip(('payload', 'statement'), OWNERS):
    indent = ' '
    role = 'trim_action_ir_value' if label == 'payload' else 'parse_method_function_expr'
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
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 574
assert len(index['rows']) == 6, 'missing inverse'
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
    tap(out, 574)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 307
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
assert names == freeze['live_claims'] == ['bare-mutation-required-isolation']
assert len(bindings) == 307
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 574, 'cold_assertions': 15,
    'actual_caller_modes': 9, 'bounded_branch_modes': 52, 'required_callers': 2,
    'required_callback_roles': 3, 'actually_invoked_roles': 3, 'validated_only_roles': 0,
    'paired_original_semantic_failures': 9, 'paired_original_passing_controls': 565,
    'semantic_source_faults': 6, 'consumer_suites': 52, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'public_toolbox_rows': 9,
    'scope': 'Only two required resolver returns in generalized payload/statement owners. Three invoked owner/role pairs in9 native-current rows and52 enumerated controlled branches preserve native guard/lazy selection, actual maps, scalar copies versus parser-array slots, contexts/effects/errors/fatal/reference identity and raw64 stabilization. Nine public Toolbox observations establish only the named return spellings/recipe diagnosis. Secondary helpers remain explicit controls; no complete helper/AST/language, optional/direct/output/mapped/full-private/canonical or parent admission. Paired9 original publication REDs/565 controls become574 GREEN; six syntax-valid faults, supplied52 suites/172 files and all307 original bindings remain recoverable. Read-only toolchain; repository-volume scratch.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained generalized-return required review drift'
print('Generalized-return required review PASS574/15/6; callbacks9/branches52/public9; paired9RED/574GREEN; consumers52/172; original307 preserved')
