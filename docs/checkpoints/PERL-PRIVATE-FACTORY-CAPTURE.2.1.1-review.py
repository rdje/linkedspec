"""Readonly constructor acceptance: complete catalogues, semantic faults, old bindings."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'be7d70719856e76b7cb5a427ad6061a7109028ea'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0-final-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/Contracts.pm'
STAGED = 'perl/LinkedSpec/ActionIR/StagedParseJob.pm'
PROGRESSIVE = 'perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm'
MODULES = (MODULE, STAGED, PROGRESSIVE)
TEST = 't/actionir_contract_factory_capture.t'
COLD = 't/actionir_contract_factory_capture_cold.t'
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
assert len(original) == 140 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path not in MODULES:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (*MODULES, TEST, COLD)})
assert len(inputs) == 142
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
assert observations[0] == observations[1], 'native catalogue observation changed'
assert len(observations[0]) == 2 and [len(rows) for rows in observations[0]] == [174, 174]
assert [r['metadata']['id'] for r in observations[0][0]] == [r['metadata']['id'] for r in observations[0][1]]
assert b'push @live_catalogues, $contracts;' in read(TEST), 'actual callback identities require live references'

positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 447)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive constructor capture failed'
assert out.count(b'actual returned callback is selected in its producer scope') == 174
assert out.count(b'substituted factory cannot register its opaque callback') == 14
assert out.count(b'preserves actual public lower references') == 12 and not err
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 6)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=23,', out), 'direct consumer population'
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
namespace = {'sources': {p: read(p).decode() for p in MODULES}, 'MODULE': MODULE, 'STAGED': STAGED,
             'PROGRESSIVE': PROGRESSIVE, 'TEST': TEST, 'COLD': COLD}
exec(compile(ast.Module(body=[edit, *pure], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _, _, _ in expected] == [
    'local-call_and_dispatch_contracts', 'local-recursive_observation_contracts',
    'local-inter_match_gap_contracts', 'local-recognition_transaction_contracts',
    'local-return_contracts', 'local-capture_and_cursor_contracts',
    'local-passthrough_ir_contracts', 'local-assignment_and_regex_contracts',
    'local-array_pipeline_contracts', 'local-dropped_value_contracts',
    'local-flow_control_contracts', 'local-emit_and_declare_contracts',
    'staged-registration', 'progressive-registration', 'blind-catalogue', 'wrong-callback',
    'copied-array', 'copied-callback', 'callback-retention', 'cold-loading']
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['sources'] == {p: inputs[p] for p in MODULES}
assert index['fixture_assertions'] == {TEST: 447, COLD: 6}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, module, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 6 if fixture == COLD else 447
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
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 248
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
assert len(bindings) == 248
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 447, 'cold_assertions': 6,
    'catalogues': 2, 'entries_per_catalogue': 174, 'local_construction_seams': 12,
    'substituted_factory_controls': 14, 'semantic_source_faults': len(expected),
    'consumer_suites': 23, 'supplied_files': len(inputs), 'historical_bindings_preserved': len(bindings),
    'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Actual local/delegated lower construction registration only. Complete native/current catalogues preserve metadata, order, ordinary values and actual callback reuse patterns; local helper snapshots preserve actual array/hash/lower references. All174 actual returned callbacks select in their scope; fourteen substituted factories cannot register opaque callbacks. Scope expiry/restoration/release and cold loading are bounded controls. No other dependency owner, pipeline/output/mapped/full-private/canonical admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained constructor review drift'
print('Constructor review PASS447/6/20; native2x174; consumers23/142; original248 preserved')
