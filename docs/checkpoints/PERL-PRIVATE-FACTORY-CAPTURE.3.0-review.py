"""Readonly MethodLowering defaults: actual maps, native refs, source faults, original bindings."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '33e57deee73e27b97e9c21116bc70942f3f33772'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
EMITTER = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
MODULES = (MODULE, EMITTER)
TEST = 't/actionir_method_default_capture.t'
COLD = 't/actionir_method_default_capture_cold.t'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(path):
    return json.loads(read(path))


seed_raw = read(SEED)
assert seed_raw == blob(SEED)
seed = json.loads(seed_raw)
original = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(original) == 142 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path not in MODULES:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (*MODULES, TEST, COLD)})
assert len(inputs) == 144
producer = read(PREFIX + 'capture.py')


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
    population = dict(inputs, **{p: seed['inputs'][p] for p in MODULES}) if name == 'native' else inputs
    out, err = channel(row, population, ['perl', '-Iperl', TEST, 'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native default map observation changed'
default_body = original[MODULE].decode().split('sub default_deps_for_package {', 1)[1].split('\nsub ', 1)[0]
keys = re.findall(r"'([a-z_]+)'", default_body)
assert len(keys) == 19 and len(set(keys)) == 19
assert len(observations[0]) == 2
for row in observations[0]:
    assert row['type'] == 'HASH' and row['keys'] == sorted(keys)
    assert [item['key'] for item in row['callbacks']] == keys
    assert all(item['type'] == 'CODE' and item['actual_native'] == 1 for item in row['callbacks'])
assert observations[0][0] == observations[0][1], 'native callback reuse changed'
assert b'my @maps = map { defaults(' in read(TEST), 'actual callback identities require live references'

positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 426)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive method default capture failed'
assert out.count(b'actual native reference is selected in current scope') == 19
assert out.count(b'same-name replacement remains opaque') == 19
assert out.count(b'opaque equal text cannot publish a selected packet') == 19 and not err
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 6)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=25,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct only the retained pure fault definitions; do not invoke writers.
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
namespace = {'sources': {p: read(p).decode() for p in MODULES}, 'MODULE': MODULE, 'EMITTER': EMITTER, 'TEST': TEST, 'COLD': COLD}
exec(compile(ast.Module(body=[edit, *pure], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _, _, _ in expected] == ['native-' + key for key in keys] + [
    'missing-factory', 'custom-target', 'same-name-reference', 'copied-map', 'cold-loading']
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['sources'] == {p: inputs[p] for p in MODULES}
assert index['fixture_assertions'] == {TEST: 426, COLD: 6}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, module, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 6 if fixture == COLD else 426
    assert item == {'case': name, 'module': module, 'path': path, 'sha256': digest(raw),
                    'source_sha256': source_hash, 'reason': reason, 'fixture': fixture,
                    'assertions': count, 'observed': 'RED'}, 'inverse index identity'
    assert row['case'] == name and row['module'] == module and row['source_sha256'] == source_hash
    assert row['distinguishing_reason'] == reason
    population = dict(inputs, **{module: source_hash})
    syntax_out, syntax_err = channel(row['syntax'], population, ['perl', '-Iperl', '-c', module])
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in syntax_err, 'invalid source fault'
    out, err = channel(row, population, ['perl', '-Iperl', fixture])
    tap(out, count)
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 244
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
assert len(bindings) == 244
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

# Retain the initial all-GREEN capture and its exact producer. Only inherited
# inverse scope prose and the console label were corrected before recapture.
initial = record(PREFIX + 'initial-capture-preservation.json')
initial_producer = read(PREFIX + 'initial-capture.py')
corrected = initial_producer.decode().replace(
    'Each local/delegated seam removed separately, blind aggregate authority, wrong callback, public reference copies, scope retention and cold loading;',
    'Each of nineteen method native definition references removed separately, factory registration omitted, custom target/ref selection bypassed, actual map copied and cold loading introduced;').replace(
    'Constructor inverses PASS:', 'Method defaults inverses PASS:').encode()
assert initial['result'] == 'PASS' and corrected == producer
assert initial['producer_before_sha256'] == digest(initial_producer)
assert initial['producer_after_sha256'] == digest(producer) and len(initial['rows']) == 30
for item in initial['rows']:
    raw = read(item['retained'])
    assert digest(raw) == item['sha256']
    row = json.loads(raw)
    final = record(item['original'])
    if item['original'].endswith('-inverses.json'):
        assert row['result'] == 'PASS' and row['sources'] == index['sources']
        assert row['fixture_assertions'] == index['fixture_assertions']
        assert len(row['rows']) == len(index['rows']) == 24
        assert row['producer_sha256'] == digest(initial_producer)
    else:
        assert row['producer_sha256'] == digest(initial_producer)
        assert row['inputs'] == final['inputs'] and row['command'] == final['command']
        assert row['returncode'] == final['returncode'] and row['unchanged'] is True
        out = base64.b64decode(row['stdout_base64'], validate=True)
        err = base64.b64decode(row['stderr_base64'], validate=True)
        if 'distinguishing_reason' in row:
            count = 6 if row['command'][-1] == COLD else 426
            tap(out, count)
            assert row['returncode'] != 0 and row['distinguishing_reason'].encode() in out
            assert row['source_sha256'] == final['source_sha256']
            assert row['syntax']['returncode'] == 0 and row['syntax']['inputs'] == final['syntax']['inputs']
        elif row['command'][-1] == 'observe':
            assert json.loads(out) == observations[0] and not err
        elif row['command'][0] == 'perl':
            tap(out, 6 if row['command'][-1] == COLD else 426)
            assert not re.search(rb'^not ok ', out, re.MULTILINE) and not err
        else:
            assert b'All tests successful.' in out and re.search(rb'Files=25,', out)

report = {'result': 'PASS', 'base': BASE, 'assertions': 426, 'cold_assertions': 6,
    'maps': 2, 'callbacks_per_map': 19, 'same_name_controls': 19, 'opaque_publication_controls': 19,
    'semantic_source_faults': len(expected), 'consumer_suites': 25, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'initial_captures_preserved': 30,
    'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'MethodLowering default factory and separate definition-owned EmitContext native reference selection only. Complete native/current two-map ledgers preserve keys, actual callback identities/reuse and public map shape. Actual OwnerDispatch map/ref snapshots, nineteen native entries, every same-name replacement/retained reference, custom target/native aliases, opaque equal-text publication controls and bounded scope restoration/cold loading. Initial all-GREEN captures retain their original producer; prose-only correction precedes repeated actual capture with unchanged production/fixtures. No injected call isolation, universal helper behavior, packet production by native helpers, automatic pipeline/output/full-private/mapped/canonical/parent admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained method default review drift'
print('Method default review PASS426/6/24; native2x19; consumers25/144; original244 preserved')
