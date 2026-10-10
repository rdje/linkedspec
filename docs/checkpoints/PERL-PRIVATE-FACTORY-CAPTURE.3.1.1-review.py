"""Readonly three-owner/eight-role inference acceptance with exact paired native observations."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '429d0c6d959e883304bc06d8c569c76e7bdcedfc'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_inference_capture.t'
COLD = 't/actionir_method_inference_capture_cold.t'
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
original = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(original) == 146 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST)), COLD: digest(read(COLD))})
assert len(inputs) == 148 and 't/trace_emit_context_bridge.t' in original
producer = read(PREFIX + 'capture.py')

# Independently constrain production to the three owned required-return edits.
expected_source = original[MODULE].decode()
for name in ('_infer_assignment_source_container_kind', '_lower_value_binding_source_expr', '_lower_typed_declare_statement'):
    start = expected_source.index('sub ' + name + ' {')
    end = expected_source.index('\nsub ', start + 1)
    body = expected_source[start:end]
    assert body.count('  return $cb;') == 1
    expected_source = expected_source[:start] + body.replace('  return $cb;', '  return _bind_emission_dependency($cb);') + expected_source[end:]
assert read(MODULE) == expected_source.encode(), 'production exceeds three required return seams'


def channel(row, population, command, instrument=producer):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(instrument), 'capture producer identity'
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
families = (
    ('_infer_assignment_source_container_kind', ('trim_action_ir_value', 'parse_method_function_expr', 'normalize_method_args_with_optional_scope')),
    ('_lower_value_binding_source_expr', ('trim_action_ir_value', 'lower_assignment_source_expr')),
    ('_lower_typed_declare_statement', ('split_declare_symbol_names', 'parse_declare_binding_entry', 'lower_declare_initializer_expr')),
)
roles = [(owner, key) for owner, keys in families for key in keys]
owners = tuple(owner for owner, _ in families)
assert [(r['owner'], r['key'], r['outcome']) for r in observations[0]] == [
    (owner, key, outcome) for owner, key in roles
    for outcome in (('string', 'undefined', 'fatal', 'reference') if key == 'lower_assignment_source_expr' else ('string', 'undefined', 'fatal'))]
assert len(observations[0]) == 25

positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 277)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive method inference capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 16
assert out.count(b'target callback keeps native invocation count') == 25 and not err
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 277)
assert before_row['returncode'] != 0, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = []
for name, key in roles:
    expected_failures.extend([name + '/' + key + '/0 required dependency cannot donate nested publication',
        name + '/' + key + '/0 actual callback has its own identity boundary',
        name + '/' + key + '/1 required dependency cannot donate nested publication'])
assert failed_names == expected_failures and len(failed_names) == 24, 'unexpected original failure set'

normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 4)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=29,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct only the retained pure edit definitions; never invoke the writer.
tree = ast.parse(producer)
edit = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'edit')
branch = next(n for n in ast.walk(tree) if isinstance(n, ast.If) and n.orelse
              and any(isinstance(t, ast.Assign) and any(isinstance(x, ast.Name) and x.id == 'variants'
                      for x in t.targets) for t in n.orelse))
pure = []
for node in branch.orelse:
    if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'expected' for t in node.targets):
        break
    pure.append(node)
namespace = {'source': read(MODULE).decode(), 'TEST': TEST, 'COLD': COLD}
exec(compile(ast.Module(body=[edit, *pure], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _, _ in expected] == [prefix + name.removeprefix('_') for name in owners for prefix in ('required-', 'identity-', 'diagnostic-')]
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['fixture_assertions'] == {TEST: 277, COLD: 4}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 4 if fixture == COLD else 277
    assert item == {'case': name, 'path': path, 'sha256': digest(raw), 'source_sha256': source_hash,
                    'reason': reason, 'fixture': fixture, 'assertions': count, 'observed': 'RED'}, 'inverse index identity'
    assert row['case'] == name and row['source_sha256'] == source_hash and row['distinguishing_reason'] == reason
    population = dict(inputs, **{MODULE: source_hash})
    syntax_out, syntax_err = channel(row['syntax'], population, ['perl', '-Iperl', '-c', MODULE])
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in syntax_err, 'invalid source fault'
    out, err = channel(row, population, ['perl', '-Iperl', fixture])
    tap(out, count)
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 262
assert freeze['producer_sha256'] == digest(read(PREFIX + 'freeze.py'))
before = read(freeze['before'])
assert before == blob(CLAIM) and digest(before) == freeze['original_sha256']
old = json.loads(before)
bindings = []
for claim in old['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        bindings.extend(durability['inputs'])
        durability.update(mode='historical', revision=BASE)
assert len(bindings) == 262
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 277, 'cold_assertions': 4,
    'actual_caller_modes': 25, 'required_callers': 3, 'required_callback_roles': 8,
    'paired_original_semantic_failures': 24, 'paired_original_passing_controls': 253,
    'semantic_source_faults': len(expected), 'consumer_suites': 29,
    'supplied_files': len(inputs), 'historical_bindings_preserved': len(bindings),
    'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only three MethodLowering assignment/declaration required-resolution seams and all eight callback roles. Same277-assertion fixture reaches its full plan with exactly24 original publication-isolation REDs and all277 current GREEN; other253 original controls pass. Exact25 native/current actual caller ledgers preserve scalar context, local scalar copies, actual shared parser-returned array aliases, public callbacks, string/reference/undefined values, once/twice effects and successful/incoming/fatal error identities. Secondary shape/value/source-slot helpers return controlled undef; this is no universal composed value test or authored declaration admission. Each seam has independent effective boundary, actual-to-wrapper identity and required diagnostic faults. Original146 supplied Git files retain three JSON reader artifacts; only MethodLowering overlaid plus two fixtures. Read-only standard interpreter/core/toolchain reused with repository-volume scratch. No optional/direct, authored DSL, other owner/pipeline/output/mapped/full-private/canonical/parent admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained method inference review drift'
print('Method inference review PASS277/4/9; callers25/roles8; paired24RED/277GREEN; consumers29/148; original262 preserved')
