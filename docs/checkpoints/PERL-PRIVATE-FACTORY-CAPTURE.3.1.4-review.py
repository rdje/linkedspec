"""Readonly main method/value acceptance, native pairing and original assignment preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '049e1ba537f2bde635b2c0fed31fe83f6b3c129b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_value_capture.t'
COLD = 't/actionir_method_value_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNER = '_lower_method_value_expr'
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
assert len(original) == 166 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 168 and 't/trace_emit_context_bridge.t' in inputs
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3
for path in (PUBLIC_TEST, PUBLIC_CONTRACT):
    assert read(path) == blob(path), 'public uniform-binding input changed'
producer = read(PREFIX + 'capture.py')


def edit(source, old, new):
    start = source.index('sub ' + OWNER + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


assert read(MODULE) == edit(original[MODULE].decode(), ' return $cb;', ' return _bind_emission_dependency($cb);').encode(), 'production exceeds one required return seam'


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
    row = record(PREFIX + name + '.json')
    population = dict(inputs, **{MODULE: seed['inputs'][MODULE]}) if name == 'native' else inputs
    out, err = channel(row, population, ['perl', '-Iperl', TEST, 'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native dependency/caller observation changed'
roles = ['trim_action_ir_value', 'split_action_ir_statements', 'parse_method_function_expr',
         'normalize_method_args_with_optional_scope', 'lower_direct_nested_access_value_expr',
         'extract_array_symbol_name', 'extract_hash_symbol_name', 'extract_scalar_symbol_name',
         'lower_scalar_access_key_expr', 'lower_primitive_literal_expr', 'split_top_level_csv',
         'lower_array_pipeline_expr', 'strip_literal_delimiters', 'lower_declare_initializer_expr']
assert [(r['role'], r['outcome']) for r in observations[0]['callbacks']] == [
    (role, outcome) for role in roles for outcome in ('string', 'undefined', 'fatal')]
expected_branches = ['trim-parser-slot', 'trim-csv-slot', 'trim-constructor-slot', 'trim-statement-slot',
                     'initializer-hash', 'key-reacquired', 'key-lazy-invalid', 'key-eager-retained', 'key-fast-path']
expected_branches += ['normalize-' + method for method in ('entry_text', 'count', 'substr', 'cat', 'take')]
expected_branches += [role + '/' + result for role in ('lower_primitive_literal_expr',
                     'lower_scalar_access_key_expr', 'lower_declare_initializer_expr') for result in ('empty', 'zero')]
expected_branches += ['initializer-' + guard for guard in ('type-mismatch', 'invalid-target', 'missing-value')]
assert len(expected_branches) == len(set(expected_branches)) == 23
assert [r['case'] for r in observations[0]['branches']] == expected_branches
body_start = original[MODULE].decode().index('sub ' + OWNER + ' {')
body_end = original[MODULE].decode().index('\nsub ', body_start + 1)
body = original[MODULE].decode()[body_start:body_end]
eager = roles[:10] + ['infer_scalar_container_kind'] + roles[10:13]
assert re.findall(r"\$require_dep->\('([^']+)'\)", body) == eager + [
    'lower_scalar_access_key_expr', 'lower_declare_initializer_expr'], 'required acquisition population'
assert len(re.findall(r'\$infer_scalar_container_kind\b', body)) == 1, 'locally validated-only inference changed'
positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 518)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive main method/value capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 28
assert out.count(b'eager diagnostic precedes undefined-input guard') == 28
assert out.count(b'initializer keeps read-only kind literal') == 1
assert out.count(b'keeps actual returned-array scalar alias') == 3
assert out.count(b'shape member trimming keeps local scalar copy') == 1
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 518)
assert before_row['returncode'] == 42 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for role in roles for reason in (
    role + '/0 required dependency cannot donate nested publication',
    role + '/0 actual callback has its own identity boundary',
    role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 42, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 10)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=48,', out), 'direct consumer population'

diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
source = read(MODULE).decode()
variants = [
    ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
     'trim_action_ir_value/0 required dependency cannot donate nested publication'),
    ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                      ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
     'trim_action_ir_value/1 actual callback has its own identity boundary'),
    ('diagnostic', edit(source, diagnostic, ''),
     'trim_action_ir_value eager diagnostic precedes undefined-input guard'),
]
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 518
assert len(index['rows']) == 3, 'missing inverse'
for (name, changed, reason), item in zip(variants, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
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
    tap(out, 518)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 291
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
assert names == freeze['live_claims'] == ['method-required-ast-assignment-isolation']
assert len(bindings) == 291
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 518, 'cold_assertions': 10,
    'actual_caller_modes': 42, 'bounded_branch_modes': 23, 'required_callers': 1,
    'required_callback_roles': 15, 'actually_invoked_roles': 14, 'validated_only_roles': 1,
    'paired_original_semantic_failures': 42, 'paired_original_passing_controls': 476,
    'semantic_source_faults': 3, 'consumer_suites': 48, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'One main method/value required resolver;14 eager roles plus lazy initializer and key reacquisition. Fourteen invoked roles in42 exact native-current string/undefined/fatal observations and23 controlled alias/arity/lazy/result/guard branches. Inference is locally validated-only; complete secondary helpers/AST/language and optional/direct/output/mapped/full-private/canonical/parent admissions stay open. Paired42 original publication REDs/476 passing controls become518 current GREEN. Source faults3, supplied48 suites/168 files and original291 assignment bindings remain recoverable. Read-only toolchain and repository-volume scratch.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained main method/value review drift'
print('Main method/value review PASS518/10/3; callbacks42/branches23; paired42RED/518GREEN; consumers48/168; original291 preserved')
