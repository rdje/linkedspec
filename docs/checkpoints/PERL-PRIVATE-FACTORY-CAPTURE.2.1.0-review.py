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
BASE = '2d878478028fc417ac5b7790c016543c18c1f48b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/Contracts.pm'
TEST = 't/actionir_contract_dependency_capture.t'
COLD = 't/actionir_contract_dependency_capture_cold.t'
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
assert len(original) == 138 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST)), COLD: digest(read(COLD))})
assert len(inputs) == 140 and 't/trace_emit_context_bridge.t' in original
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
    row = record(PREFIX + 'final-' + name + '.json')
    population = dict(inputs, **{MODULE: seed['inputs'][MODULE]}) if name == 'native' else inputs
    out, err = channel(row, population, ['perl', '-Iperl', TEST, 'observe'])
    assert row['returncode'] == 0 and not err
    observations.append(json.loads(out))
assert observations[0] == observations[1], 'native bridge observation changed'
assert [(r['context'], r['outcome']) for r in observations[0]] == [
    (c, o) for c in ('scalar', 'list', 'void')
    for o in ('string', 'reference', 'undefined', 'values', 'fatal')]

positive = record(PREFIX + 'final-fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 312)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive Contracts capture failed'
assert out.count(b'caller map and actual callback fields stay unchanged') == 27
assert b'actual input_slice opaque dependency cannot donate nested publication' in out
assert b'custom default target cannot register even aliased native callbacks' in out
assert not err
cold = record(PREFIX + 'final-cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 6)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'final-consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=21,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct only the retained pure edit definitions; never invoke the writer.
tree = ast.parse(producer)
edit = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'edit')
variants = next(n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                and any(isinstance(t, ast.Name) and t.id == 'variants' for t in n.targets))
namespace = {'source': read(MODULE).decode(), 'TEST': TEST, 'COLD': COLD}
exec(compile(ast.Module(body=[edit, variants], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _, _ in expected] == ['required-boundary', 'optional-boundary', 'fallback-boundary',
    'bare-boundary', 'custom-default-target', 'same-name-default', 'missing-native-default', 'alias-copies',
    'list-context', 'void-context', 'once', 'incoming-error', 'successful-error', 'fatal-object',
    'callback-retention', 'cold-loading']
index = record(PREFIX + 'final-inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['fixture_assertions'] == {TEST: 312, COLD: 6}
assert len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, fixture, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'final-inverse-' + name + '.json'
    raw = read(path)
    row = json.loads(raw)
    source_hash = digest(changed.encode())
    count = 6 if fixture == COLD else 312
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
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 235
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
assert len(bindings) == 235
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

# Preserve the actual failed lifetime premise and source-bound native diagnosis.
draft_producer = read(PREFIX + 'draft1-capture.py')
draft_fixture = read(PREFIX + 'draft1-fixture.t')
draft_source = read(PREFIX + 'draft1-Contracts.pm')
assert draft_source == read(MODULE), 'fixture correction must not hide production changes'
draft_inputs = dict(inputs, **{TEST: digest(draft_fixture)})
draft = record(PREFIX + 'fixture.json')
out, err = channel(draft, draft_inputs, ['perl', '-Iperl', TEST], draft_producer)
tap(out, 312)
failures = [line for line in out.splitlines() if line.startswith(b'not ok ')]
assert draft['returncode'] != 0 and len(failures) == 1
assert failures[0].startswith(b'not ok 312 - private binding release')
draft_consumers = record(PREFIX + 'consumers.json')
out, err = channel(draft_consumers, draft_inputs, seed['command'] + [TEST, COLD], draft_producer)
assert draft_consumers['returncode'] != 0 and b'Files=21,' in out and b'Failed 1/312' in out
for name in ('native', 'observe', 'cold'):
    row = record(PREFIX + name + '.json')
    population = dict(draft_inputs, **{MODULE: seed['inputs'][MODULE]}) if name == 'native' else draft_inputs
    command = ['perl', '-Iperl', COLD] if name == 'cold' else ['perl', '-Iperl', TEST, 'observe']
    out, err = channel(row, population, command, draft_producer)
    assert row['returncode'] == 0 and not err
    if name == 'cold':
        tap(out, 6)
    else:
        assert json.loads(out) == observations[0]
probe = record(PREFIX + 'closure-probe.json')
assert probe['result'] == 'PASS' and probe['base'] == BASE
assert probe['producer_sha256'] == digest(read(PREFIX + 'closure-probe.py'))
assert probe['fixture_sha256'] == digest(draft_fixture) and probe['current_source_sha256'] == digest(draft_source)
assert [(r['boundary'], r['kind']) for r in probe['rows']] == [
    (b, k) for b in ('original', 'current') for k in ('no-lexical-state', 'lexical-state')]
prefix = draft_fixture[:draft_fixture.index(b'sub capture')]
block = draft_fixture[draft_fixture.rindex(b"\n{\n my $actual = sub"):draft_fixture.index(b'\ndone_testing;')]
lexical = block.replace(b"my $actual = sub { return 'same' };",
    b"my $identity = {}; my $actual = sub { return $identity ? 'same' : undef };")
for row in probe['rows']:
    population = dict(draft_inputs, **{MODULE: seed['inputs'][MODULE]}) if row['boundary'] == 'original' else draft_inputs
    assert row['inputs'] == population and row['unchanged'] is True
    body = block if row['kind'] == 'no-lexical-state' else lexical
    assert row['command'] == ['perl', '-Iperl', '-e', (prefix + body + b'\ndone_testing;\n').decode()]
    out = base64.b64decode(row['stdout_base64'], validate=True)
    err = base64.b64decode(row['stderr_base64'], validate=True)
    tap(out, 2)
    if row['kind'] == 'no-lexical-state':
        assert row['returncode'] != 0 and b'not ok 2 - private binding release' in out
    else:
        assert row['returncode'] == 0 and b'not ok' not in out and not err

report = {'result': 'PASS', 'base': BASE, 'assertions': 312, 'cold_assertions': 6,
    'native_differential_modes': 15, 'dependency_slots': 27, 'semantic_source_faults': len(expected),
    'consumer_suites': 21, 'supplied_files': len(inputs), 'historical_bindings_preserved': len(bindings),
    'draft_failed_lifetime_checks': 1, 'lifetime_probe_modes': 4, 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Contracts private injected required/optional/bare bindings and built-in native default selection only. Actual callback references, contexts, caller aliases, effects, values/errors/fatal identity, cold loading and map preservation. Original input_slice dynamic-inheritance diagnosis now has an actual boundary. Failed no-lexical-state lifetime premise is preserved and diagnosed at original/current source boundaries; production bytes do not change for its fixture correction. Actual lower construction, other owners, pipeline/output/mapped/full-private/canonical admission remain open.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained Contracts review drift'
print('Contracts review PASS312/6/16; native15; consumers21/140; original235 preserved')
