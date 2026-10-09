"""Read-only review of actual framework channels, faults and original bindings."""
import ast
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '02345ee21f9cd674dea073b5e25f6200bd0a6ead'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-'
OLD = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3'
SEED = 'docs/checkpoints/' + OLD + '-consumers.json'
CLAIM = 'docs/claims/' + OLD + '.json'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_factory_capture.t'
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
original = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(original) == 135 and {p: digest(b) for p, b in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST))})
assert len(inputs) == 136
producer = read(PREFIX + 'capture.py')


def channel(row, population, command, instrument=producer):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(instrument), 'capture producer identity'
    assert row['inputs'] == population, 'supplied input population/content mismatch'
    assert row['command'] == command and row['unchanged'] is True
    return (base64.b64decode(row['stdout_base64'], validate=True),
            base64.b64decode(row['stderr_base64'], validate=True))


def tap(raw):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [b'224'], 'incomplete TAP plan'
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)] == list(range(1, 225)), 'incomplete TAP population'


positive = record(PREFIX + 'final-fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE), 'positive framework capture failed'
assert out.count(b'native differential context aliases effects returns and errors') == 30
assert out.count(b'opaque dependency cannot donate nested publication') == 3
assert not err
consumers = record(PREFIX + 'final-consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=17,', out), 'direct consumer population'
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3

# Reconstruct the retained pure fault definitions without invoking the writer.
tree = ast.parse(producer)
edit = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'edit')
variants = next(n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                and any(isinstance(t, ast.Name) and t.id == 'variants' for t in n.targets))
namespace = {'source': read(MODULE).decode()}
exec(compile(ast.Module(body=[edit, variants], type_ignores=[]), '<retained-pure-faults>', 'exec'), namespace)
expected = namespace['variants']
assert [n for n, _, _ in expected] == ['registration-token', 'callback-identity', 'scalar-boundary',
    'list-boundary', 'void-boundary', 'list-context', 'void-context', 'aliases', 'once',
    'success-error', 'callback-retention']
index = record(PREFIX + 'final-inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['fixture_sha256'] == inputs[TEST] and index['source_sha256'] == inputs[MODULE]
assert index['assertions'] == 224 and len(index['rows']) == len(expected), 'missing inverse'
for (name, changed, reason), item in zip(expected, index['rows']):
    path = PREFIX + 'final-inverse-' + name + '.json'
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
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 232
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
assert len(bindings) == 232
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

# The failed draft is evidence of a fixture identity assumption, not product RED.
draft_producer = read(PREFIX + 'draft1-capture.py')
draft_fixture = read(PREFIX + 'draft1-fixture.t')
draft_source = read(PREFIX + 'draft1-SourceEmissions.pm')
assert draft_source == read(MODULE), 'fixture correction must not hide a production change'
draft_inputs = dict(seed['inputs'], **{MODULE: digest(draft_source), TEST: digest(draft_fixture)})
draft_raw = read(PREFIX + 'draft1-fixture.json')
assert read(PREFIX + 'fixture.json') == draft_raw
draft = json.loads(draft_raw)
out, err = channel(draft, draft_inputs, ['perl', '-Iperl', TEST], draft_producer)
tap(out)
failures = [line for line in out.splitlines() if line.startswith(b'not ok ')]
assert draft['returncode'] != 0 and len(failures) == 4
assert [int(re.match(rb'not ok (\d+)', line)[1]) for line in failures] == [6, 10, 14, 16]
probe = record(PREFIX + 'closure-probe.json')
assert probe['producer_sha256'] == digest(read(PREFIX + 'closure-probe.py'))
assert probe['fixture'] == PREFIX + 'draft1-fixture.t' and probe['fixture_sha256'] == digest(draft_fixture)
assert probe['command'][:2] == ['perl', '-e']
factory = re.search(rb'^sub factory \{.*\}$', draft_fixture, re.MULTILINE).group()
assert probe['command'][2].encode().startswith(b'use Scalar::Util qw(refaddr);\n' + factory + b'\n')
assert probe['returncode'] == 0
assert base64.b64decode(probe['stdout_base64'], validate=True) == b'same_actual_callback=1\ndistinct_lexical_callbacks=1\n'
assert not base64.b64decode(probe['stderr_base64'], validate=True)

report = {'result': 'PASS', 'base': BASE, 'assertions': 224, 'native_differential_modes': 30,
    'semantic_source_faults': len(expected), 'consumer_suites': 17, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'draft_failed_identity_checks': len(failures),
    'checked': dict(sorted(checked.items())), 'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Private actual-callback registration and scalar/list/void dependency framework. Actual source-bound channels, complete semantic REDs, native differential effects and retained draft identity diagnosis. No production factory/pipeline/output/mapped/full-private/canonical integration or universal native closure-caching claim.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained framework review drift'
print('Framework review PASS224/11; native30; consumers17/136; original232 preserved')
