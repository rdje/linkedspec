"""Read-only independent review of supplied composition inputs and actual channels."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4f0499d2634e9c04e6a3d07ee85f4159f5380834'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SEED = PREFIX.replace('.3-', '.2-') + 'final-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_input_composition_acceptance.t'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(path):
    return json.loads(read(path))


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


seed_raw = blob(SEED)
assert read(SEED) == seed_raw
seed = json.loads(seed_raw)
original = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(original) == 134 and {p: digest(b) for p, b in original.items()} == seed['inputs']
for path, raw in original.items():
    assert read(path) == raw, 'live production/consumer changed: ' + path
inputs = dict(seed['inputs'], **{TEST: digest(read(TEST))})
assert len(inputs) == 135
producer = read(PREFIX + 'capture.py')


def channel(row, population, command):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(producer), 'capture producer identity'
    assert row['inputs'] == population, 'supplied input population/content mismatch'
    assert row['command'] == command and row['unchanged'] is True
    return (base64.b64decode(row['stdout_base64'], validate=True),
            base64.b64decode(row['stderr_base64'], validate=True))


def tap(raw):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [b'140'], 'incomplete TAP plan'
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)] == list(range(1, 141)), 'incomplete TAP population'


positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive composition capture failed'
assert out.count(b'actual event population excludes quoted executable twin') == 4
for phrase in (b'complete independently labelled cross-capture frame population',
               b'independent output character and occurrence ledger', b'exact deep child consumption ledger'):
    assert out.count(phrase) == 8, 'authored composition oracle population'
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=16,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct only pure fault definitions from the retained instrument, in RAM.
# No capture program is imported or executed and no supplied source is changed.
tree = ast.parse(producer)
edit = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'edit')
variants = next(n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                and any(isinstance(t, ast.Name) and t.id == 'variants' for t in n.targets))
namespace = {'source': original[MODULE].decode()}
exec(compile(ast.Module(body=[edit, variants], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _ in expected] == ['rebase', 'occurrence', 'parent', 'cached-native', 'append-event',
                                     'consume-event', 'consume-child', 'callback-once', 'aliases', 'opaque-release']
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['fixture_sha256'] == inputs[TEST] and index['source_sha256'] == inputs[MODULE]
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    assert item == {'case': name, 'path': path, 'sha256': digest(raw),
                    'source_sha256': source_hash, 'reason': reason, 'observed': 'RED'}, 'inverse index identity'
    assert row['case'] == name and row['source_sha256'] == source_hash and row['distinguishing_reason'] == reason
    population = dict(inputs, **{MODULE: source_hash})
    syntax_out, syntax_err = channel(row['syntax'], population, ['perl', '-Iperl', '-c', MODULE])
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in syntax_err, 'invalid source fault'
    out, err = channel(row, population, ['perl', '-Iperl', TEST])
    tap(out)
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['producer_sha256'] == digest(read(PREFIX + 'freeze.py'))
assert len(freeze['records']) == 1
item = freeze['records'][0]
old_path = 'docs/claims/' + LEAF[:-1] + '2.json'
assert item['path'] == old_path and item['verified_bindings'] == 287
before = read(item['before'])
assert before == blob(old_path) and digest(before) == item['original_sha256']
old = json.loads(before)
bindings = []
for claim in old['claims']:
    durability = claim['durability']
    if durability['mode'] == 'live':
        bindings.extend(durability['inputs'])
        durability.update(mode='historical', revision=BASE)
assert len(bindings) == 287
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(old_path)
assert digest(after) == item['after_sha256'] and json.loads(after) == old, 'original claim changed beyond mode/revision'
report = {'result': 'PASS', 'base': BASE, 'assertions': 140, 'cases': 4, 'actual_executable_events': 8,
          'selected_frame_joins': 64, 'semantic_source_faults': len(expected), 'consumer_suites': 16,
          'supplied_files': len(inputs), 'historical_bindings_preserved': len(bindings),
          'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Actual original Git capsule, independently authored frame/output/consumption populations, complete semantic RED plans/channels, exact fault bytes and original claim preservation. No production change or factory/output/full-private/mapped/canonical admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_text()) == report, 'retained independent review drift'
print('Independent input composition review PASS140/10; consumers16/135; original287 preserved')
