"""Readonly review of native bridge channels, actual identities and source faults."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b21b3bb9f6a414d50c71468c3e4193d04ad9b56a'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-final-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.1.json'
MODULE = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
TEST = 't/actionir_emit_context_capture.t'
COLD = 't/actionir_emit_context_capture_cold.t'
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
assert len(original) == 136 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST)), COLD: digest(read(COLD))})
assert len(inputs) == 138 and 't/trace_emit_context_bridge.t' in original
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
    population = dict(inputs, **{MODULE: seed['inputs'][MODULE]}) if name == 'native' else inputs
    out, err = channel(row, population, ['perl', '-Iperl', TEST, 'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native bridge observation changed'
assert [(r['with_deps'], r['context'], r['outcome']) for r in observations[0]] == [
    (d, c, o) for d in (0, 1) for c in ('scalar', 'list', 'void')
    for o in ('string', 'reference', 'undefined', 'values', 'fatal')]

positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 345)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive bridge capture failed'
assert out.count(b'actual definition-owned reference reaches registration once') == 28
assert out.count(b'opaque resolved call cannot donate nested publication') == 6
assert not err
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 5)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=19,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct only the retained pure edit definitions; never invoke the writer.
tree = ast.parse(producer)
edit = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'edit')
variants = next(n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                and any(isinstance(t, ast.Name) and t.id == 'variants' for t in n.targets))
namespace = {'source': read(MODULE).decode(), 'TEST': TEST, 'COLD': COLD}
exec(compile(ast.Module(body=[edit, variants], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _, _ in expected] == ['accept-any-reference', 'lost-native-reference', 'follow-public-name',
    'owner-boundary', 'factory-boundary', 'list-context', 'void-context', 'with-deps-context',
    'caller-copies', 'factory-map', 'incoming-error', 'fatal-object', 'cold-loading']
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['fixture_assertions'] == {TEST: 345, COLD: 5}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 5 if fixture == COLD else 345
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
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 233
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
assert len(bindings) == 233
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

# A duplicate already-supplied Trace fixture stopped the first harness preflight.
# It never produced a runtime observation; retain and identify it separately.
draft = record(PREFIX + 'draft0-preflight.json')
assert draft['producer_sha256'] == digest(read(PREFIX + 'draft0-capture.py'))
assert draft['returncode'] != 0 and b'assert path not in files' in base64.b64decode(draft['stderr_base64'], validate=True)
assert not base64.b64decode(draft['stdout_base64'], validate=True)
assert draft['command'] == ['bash', 'tools/run_python_project_data.sh', PREFIX + 'capture.py', 'native']

report = {'result': 'PASS', 'base': BASE, 'assertions': 345, 'cold_assertions': 5,
    'native_differential_modes': 30, 'definition_owned_callbacks': 28, 'opaque_publication_modes': 6,
    'semantic_source_faults': len(expected), 'consumer_suites': 19, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'EmitContext prerequisite only: actual definition-owned native callback references and separate actual owner/default-factory calls. Complete native observations preserve existing argument copies/context/returns/effects/errors and exact factory map. Cold require, Trace and supplied direct suites remain compatible. No Contracts construction/dependency, other owner, pipeline/output/mapped/full-private/canonical admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained bridge review drift'
print('EmitContext review PASS345/5/13; native30; consumers19/138; original233 preserved')
