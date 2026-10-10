"""Readonly regex-undef required acceptance, native pairing and original push preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'ae65603bc5bee1f3abeab4d7a028546ddbc8da93'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_regex_undef_required_capture.t'
COLD = 't/actionir_method_regex_undef_required_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
PROBE = 't/actionir_method_regex_undef_required_probe.pl'
NATIVE = PREFIX + 'native.json'
OWNERS = ['_lower_regex_subst_statement','_lower_return_undef_statement']
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
assert len(original) == 178 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, PROBE, TEST, COLD, NATIVE)})
assert len(inputs) == 182 and 't/trace_emit_context_bridge.t' in inputs
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 4
for path in (PUBLIC_TEST, PUBLIC_CONTRACT):
    assert read(path) == blob(path), 'public uniform-binding input changed'
producer = read(CAPTURE_PREFIX + 'capture.py')


def edit(source, owner, old, new):
    start = source.index('sub ' + owner + ' {')
    end = source.find('\nsub ', start + 1)
    end = len(source) if end < 0 else end
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


expected_source = original[MODULE].decode()
for label, owner in zip(('regex','undef'), OWNERS):
    indent = ' '
    expected_source = edit(expected_source, owner, indent + ' return $cb;',
                           indent + ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds one required return seam'


def channel(row, population, command, instrument=None):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(producer if instrument is None else instrument), 'capture producer identity'
    assert row['inputs'] == population, 'supplied input population/content mismatch'
    assert row['command'] == command and row['unchanged'] is True
    return (base64.b64decode(row['stdout_base64'], validate=True),
            base64.b64decode(row['stderr_base64'], validate=True))


def tap(raw, count):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [str(count).encode()], 'incomplete TAP plan'
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)] == list(range(1, count + 1)), 'incomplete TAP population'


native_inputs = {p:inputs[p] for p in list(original) + [PROBE]}
assert len(native_inputs) == 179
observations = []
for name in ('native','observe'):
    row = record(CAPTURE_PREFIX + name + '.json')
    population = dict(native_inputs, **{MODULE:seed['inputs'][MODULE]}) if name == 'native' else native_inputs
    out,err = channel(row,population,['perl','-Iperl',PROBE,'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native dependency/caller observation changed'
roles = {'regex':['extract_scalar_symbol_name','strip_literal_delimiters','trim_action_ir_value'],
         'undef':['parse_method_function_expr','normalize_method_args_with_optional_scope']}
paths = [('regex','defined'),('regex','default'),('undef','plain')]
assert [(r['kind'],r['mode'],r['role'],r['outcome']) for r in observations[0]['callbacks']] == [
 (kind,mode,role,outcome) for kind,mode in paths for role in roles[kind] for outcome in ('string','undefined','fatal')]
expected_branches = [
 'regex-symbol-undefined','regex-symbol-','regex-symbol-0',
 'regex-strip-0-undefined','regex-strip-0-','regex-strip-0-0',
 'regex-strip-1-undefined','regex-strip-1-','regex-strip-1-0',
 'regex-trim-undefined','regex-trim-','regex-trim-0','regex-trim-g','regex-default-flags',
 'regex-undefined-target','regex-undefined-pattern','regex-undefined-replacement',
 'undef-ast-FAST','undef-ast-0','undef-ast-','undef-ast-reference',
 'undef-parser-undefined','undef-parser-other-method',
 'undef-normalized-undefined','undef-normalized-','undef-normalized-0','undef-normalized-empty-array',
 'undef-normalized-distinct','undef-args-undefined','undef-args-empty','undef-args-unvalidated','undef-undefined-input']
assert len(expected_branches) == len(set(expected_branches)) == 32
assert [r['case'] for r in observations[0]['branches']] == expected_branches
text = original[MODULE].decode()
for kind,owner in zip(('regex','undef'),OWNERS):
    start = text.index('sub ' + owner + ' {')
    end = text.find('\nsub ',start+1)
    body = text[start:end if end >= 0 else len(text)]
    assert re.findall(r"\$require_dep->\('([^']+)'\)",body) == roles[kind], 'required acquisition population'
    if kind == 'regex':
        assert body.index("$require_dep->('trim_action_ir_value')") < body.index('my $symbol =')
        assert body.count('$strip_literal_delimiters->(') == 2
        assert "$trim_action_ir_value->($flags // '')" in body
        assert body.index('$strip_literal_delimiters->($replacement)') < body.index('return undef unless defined($pattern_raw)')
    else:
        assert body.index("$require_dep->('normalize_method_args_with_optional_scope')") < body.index('_lower_ast_call_statement(')
        assert '$normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0)' in body
public = observations[0]['public']
assert [(r['case'],r['source']) for r in public] == [
 ('regex-bare','regex_subst(text, /A/, "X", g)'),('substr-bare','substr(text, /A/, "X", g)'),
 ('undef-plain','return_undef()'),('undef-scoped','return_undef(Top)')]
assert [r['error'] for r in public] == [None]*4
assert [r['value'] for r in public] == ['$text =~ s{A}{X}g','$text =~ s{A}{X}g','return undef','return undef']
positive = record(CAPTURE_PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 619)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive regex-undef required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 16
assert out.count(b'required diagnostic retains native selection') == 16
positive_out = out
before_row = record(CAPTURE_PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 619)
assert before_row['returncode'] == 24 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
owners = dict(zip(('regex','undef'),OWNERS))
expected_failures = [reason for kind,mode in paths for role in roles[kind] for reason in (
    owners[kind] + '/' + mode + '/' + role + '/0 required dependency cannot donate nested publication',
    owners[kind] + '/' + mode + '/' + role + '/0 actual callback has its own identity boundary',
    owners[kind] + '/' + mode + '/' + role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 24, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(CAPTURE_PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 23)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(CAPTURE_PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=60,', out), 'direct consumer population'

fault_producer = read(PREFIX + 'faults.py')
old_boundary = "    end = source.index('\\nsub ', start + 1)"
new_boundary = "    end = source.find('\\nsub ', start + 1)\n    end = len(source) if end < 0 else end"
assert producer.decode().count(old_boundary) == 1
assert fault_producer == producer.decode().replace(old_boundary,new_boundary,1).encode(), 'fault producer exceeds last-owner boundary repair'
boundary = record(PREFIX + 'fault-boundary.json')
assert boundary['producer_sha256'] == digest(read(PREFIX + 'fault-boundary.py'))
assert boundary['original_producer_sha256'] == digest(producer)
assert boundary['command'] == ['python3',PREFIX + 'capture.py','inverses']
assert boundary['inputs'] == inputs and boundary['returncode'] != 0 and boundary['unchanged'] is True
assert boundary['mutants_before'] == boundary['mutants_after'] == []
assert b'ValueError: substring not found' in base64.b64decode(boundary['stderr_base64'],validate=True)
assert b"end = source.index('\\nsub ', start + 1)" in base64.b64decode(boundary['stderr_base64'],validate=True)
assert not base64.b64decode(boundary['stdout_base64'],validate=True)

source = read(MODULE).decode()
variants = []
for label, owner in zip(('regex','undef'), OWNERS):
    indent = ' '
    role = 'extract_scalar_symbol_name' if label == 'regex' else 'parse_method_function_expr'
    path_mode = 'defined' if label == 'regex' else 'plain'
    seam = indent + ' return _bind_emission_dependency($cb);'
    diagnostic = indent + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indent + "  unless ref($cb) eq 'CODE';"
    variants.extend([
        (label + '-required', edit(source, owner, seam, indent + ' return $cb;'),
         owner + '/' + path_mode + '/' + role + '/0 required dependency cannot donate nested publication'),
        (label + '-identity', edit(source, owner, seam, indent + ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
         owner + '/' + path_mode + '/' + role + '/1 actual callback has its own identity boundary'),
        (label + '-diagnostic', edit(source, owner, diagnostic, ''),
         owner + '/' + path_mode + '/' + role + ' required diagnostic retains native selection'),
    ])
index = record(CAPTURE_PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(fault_producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 619
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
    syntax_out, syntax_err = channel(row['syntax'], population, ['perl', '-Iperl', '-c', MODULE], fault_producer)
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in syntax_err, 'invalid source fault'
    out, err = channel(row, population, ['perl', '-Iperl', TEST], fault_producer)
    tap(out, 619)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 303
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
assert names == freeze['live_claims'] == ['push-required-isolation']
assert len(bindings) == 303
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result':'PASS','base':BASE,'assertions':619,'cold_assertions':23,
 'actual_caller_modes':24,'bounded_branch_modes':32,'required_callers':2,'required_callback_roles':5,
 'actually_invoked_roles':5,'actual_path_role_targets':8,'validated_only_roles':0,
 'paired_original_semantic_failures':24,'paired_original_passing_controls':595,'semantic_source_faults':6,
 'consumer_suites':60,'supplied_files':len(inputs),'historical_bindings_preserved':len(bindings),
 'checked':dict(sorted(checked.items())),'reviewer_sha256':digest(Path(__file__).read_bytes()),'public_toolbox_rows':4,
 'native_capsule_files':179,'fault_generator_boundary_control':True,
 'scope':('Only two regex/undefined-return required resolver returns. Five eager roles across three paths in24 exact '
          'native-current outcomes,32 independent branches/four actual public Toolbox rows. Native179-file immutable probe '
          'precedes separate182-file main/cold/consumer proof with its retained native JSON reader. Local copies, defined/default '
          'flags and repeated stripping, actual parser/normalizer array and readonly0/0 arities, maps/context/errors/fatal/reference '
          'identities remain native. Paired24 original isolation REDs/595 controls become619 GREEN; six syntax-valid faults, '
          'supplied60 suites/182 files, all303 original push bindings and complete instrument/reader identities are retained. '
          'Native probe/assertions remain unchanged; actual last-owner fault-generator failure and exact delimiter repair are retained. No old runtime refresh. Undefined-return AST is a secondary control; existing .59 repairs '
          'and complete helper/AST/language, optional/direct/output/mapped/full-private/canonical admissions remain separate.')}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained regex-undef required review drift'
print('Regex/undefined-return required review PASS619/23/6; callbacks24/branches32/public4; paired24RED/619GREEN; native179/consumers60/182; original303 preserved')
