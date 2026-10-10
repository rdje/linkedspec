"""Readonly three-caller trim acceptance: paired native RED/GREEN and binding semantics."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '89a4ede6fbbb0f3b7a4e4f98a4b477b79c0cfeb7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_trim_capture.t'
COLD = 't/actionir_method_trim_capture_cold.t'
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
assert len(original) == 144 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST)), COLD: digest(read(COLD))})
assert len(inputs) == 146 and 't/trace_emit_context_bridge.t' in original
producer = read(PREFIX + 'capture.py')


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
assert [(r['context'], r['outcome']) for r in observations[0]['dependency']] == [
    (c, o) for c in ('scalar', 'list', 'void')
    for o in ('string', 'reference', 'undefined', 'values', 'fatal')]
owners = ('_infer_direct_shape_literal_kind', '_normalize_method_tag_expr', '_lower_inline_switch_case_value_expr')
assert [(r['owner'], r['outcome']) for r in observations[0]['callers']] == [
    (name, outcome) for name in owners for outcome in ('string', 'undefined', 'fatal')]

positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 255)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive method trim capture failed'
assert out.count(b'injected trim cannot donate nested publication') == 6
assert out.count(b'actual trim effects keep native invocation count') == 9 and not err
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 255)
assert before_row['returncode'] != 0, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = []
for name in owners:
    expected_failures.extend([name + '/0 injected trim cannot donate nested publication',
        name + '/0 trim has its own actual callback boundary',
        name + '/1 injected trim cannot donate nested publication'])
expected_failures += ['known child packet never transfers implicitly to parent',
                     'explicit actual known-child capture retains its own packet']
assert failed_names == expected_failures and len(failed_names) == 11, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 5)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=27,', out), 'direct consumer population'
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
assert [n for n, _, _, _ in expected] == ['required-' + name.removeprefix('_') for name in owners] + [
    'binding-boundary', 'alias-copies', 'list-context', 'void-context', 'once',
    'incoming-error', 'successful-error', 'fatal-object', 'callback-retention', 'cold-loading']
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['fixture_assertions'] == {TEST: 255, COLD: 5}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 5 if fixture == COLD else 255
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
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 282
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
assert len(bindings) == 282
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

# Preserve the actual partial attempt: retention fault was semantic RED255,
# while the inherited instrument matcher still expected its old label. The
# cold matcher was aligned before that not-yet-run case. No runtime input changed.
diagnosis = record(PREFIX + 'draft1-diagnosis.json')
draft_producer = read(PREFIX + 'draft1-capture.py')
assert diagnosis['result'] == 'PASS' and diagnosis['producer_before_sha256'] == digest(draft_producer)
assert diagnosis['producer_after_sha256'] == digest(producer)
assert draft_producer.decode().replace(
    'private binding release leaves no global callback cache',
    'private binding release leaves no global callback retention').replace(
    'cold binding keeps SourceEmissions unloaded',
    'cold private binding keeps SourceEmissions unloaded').encode() == producer
assert diagnosis['source_sha256'] == inputs[MODULE] and diagnosis['fixture_sha256'] == inputs[TEST]
assert diagnosis['cold_sha256'] == inputs[COLD] and diagnosis['full_plan'] == 255
assert len(diagnosis['rows']) == 18
for item in diagnosis['rows']:
    raw = read(item['retained']); assert digest(raw) == item['sha256']
    row = json.loads(raw); final = record(item['original'])
    assert row['producer_sha256'] == digest(draft_producer)
    assert row['inputs'] == final['inputs'] and row['command'] == final['command']
    assert row['unchanged'] is True and row['returncode'] == final['returncode']
    out = base64.b64decode(row['stdout_base64'], validate=True)
    err = base64.b64decode(row['stderr_base64'], validate=True)
    if item['original'].endswith('-inverse-callback-retention.json'):
        tap(out, 255)
        red = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ')]
        assert row['returncode'] == 1 and red == ['not ok 255 - private binding release leaves no global callback retention']
        assert row['semantic_failures'] == [] and row['distinguishing_reason'] == diagnosis['declared_wrong_reason']
        assert diagnosis['actual_semantic_red'] == red and diagnosis['actual_retention_fault_returncode'] == 1
        assert row['distinguishing_reason'].encode() not in out, 'original matcher diagnosis'
        assert row['syntax']['returncode'] == 0
    elif 'distinguishing_reason' in row:
        tap(out, 255)
        assert row['returncode'] != 0 and row['semantic_failures']
        assert row['distinguishing_reason'].encode() in out and row['syntax']['returncode'] == 0
    elif row['command'][-1] == 'observe':
        assert json.loads(out) == observations[0] and not err
    elif row['command'][0] == 'perl':
        tap(out, 5 if row['command'][-1] == COLD else 255)
        assert (item['original'].endswith('-before.json')) == bool(row['returncode'])
    else:
        assert b'All tests successful.' in out and re.search(rb'Files=27,', out)

report = {'result': 'PASS', 'base': BASE, 'assertions': 255, 'cold_assertions': 5,
    'native_differential_modes': 15, 'actual_caller_modes': 9, 'required_callers': 3,
    'paired_original_semantic_failures': 11, 'paired_original_passing_controls': 244, 'retained_partial_attempt_captures': 18,
    'semantic_source_faults': len(expected), 'consumer_suites': 27,
    'supplied_files': len(inputs), 'historical_bindings_preserved': len(bindings),
    'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Private MethodLowering native-context lexical binding plus required trim seams in direct shape inference, method tag and inline switch-case normalization only. Same255-assertion fixture reaches its full plan with exactly eleven original publication-isolation REDs and all255 current GREEN; other244 original controls pass. Exact native/current15 dependency and9 actual caller ledgers preserve context, original aliases, copied top-level caller inputs, public callbacks, values/effects/errors/fatal identities. Shape secondary value result is explicitly held constant while observing its actual trim call. Known-child explicit captures retain their own packet; parents do not inherit. Lexical lifetime and cold lazy loading are bounded controls. Original144 supplied Git inputs retain all three JSON reader artifacts; only MethodLowering overlaid plus two fixtures. Standard read-only interpreter/core/toolchain outputs reused on the repository volume. The partial source-fault attempt retains18 actual captures and the exact producer; two inherited assertion matcher labels are corrected, with unchanged production and fixtures. No other required/optional call, automatic pipeline/output/mapped/full-private/canonical/parent admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained method trim review drift'
print('Method trim review PASS255/5/13; native15/callers9; paired11RED/255GREEN; consumers27/146; original282 preserved')
