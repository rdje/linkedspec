"""Readonly assignment acceptance, exact native pairing and original array-end preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4fde89c1958faf4057ab80eb7e7cd50962c7ac3c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_ast_assignment_capture.t'
COLD = 't/actionir_method_ast_assignment_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNER = '_lower_ast_assignment_operator_statement'
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
assert len(original) == 164 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 166 and 't/trace_emit_context_bridge.t' in inputs
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
assert [r['outcome'] for r in observations[0]['callbacks']] == ['string', 'undefined', 'fatal']
expected_branches = [kind + '/' + label for kind in ('assign_scalar', 'assign_array_append', 'assign_hash_index')
                     for label in ('baseline', 'untracked', 'guard-undefined', 'guard-empty', 'guard-zero',
                                   'guard-reference', 'missing-span', 'malformed-span')]
expected_branches += [kind + '/' + role + '-' + label
                      for kind, binding in (('assign_scalar', 'binding'), ('assign_array_append', 'payload'))
                      for label in ('undefined', 'empty', 'zero') for role in ('source', binding, 'assembly')]
expected_branches += ['assign_hash_index/source-' + role + '-' + label for role in ('key', 'value')
                      for label in ('undefined', 'empty', 'zero')]
expected_branches += ['assign_hash_index/' + role + '-' + label for role in ('key-result', 'payload')
                      for label in ('undefined', 'empty', 'zero')]
expected_branches += ['assign_hash_index/scalar-held-' + label for label in ('empty', 'zero', 'string', 'untracked')]
expected_branches += ['assign_scalar/variable-' + label for label in ('fast', 'empty', 'zero', 'not-user-function')]
expected_branches += ['assign_nested_access/nested-' + label for label in ('undefined', 'empty', 'zero', 'reference')]
assert len(expected_branches) == len(set(expected_branches)) == 66
assert [r['case'] for r in observations[0]['branches']] == expected_branches
positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 864)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive AST assignment capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 2
assert out.count(b'target callback keeps native invocation count') == 3
assert out.count(b'callback keeps local key scalar copy') == 3
assert out.count(b'node/expected-kind guard precedes dependency validation') == 6
assert out.count(b'invalid target precedes required validation') == 12
assert out.count(b'keeps bounded native branch result') == 66
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 864)
assert before_row['returncode'] == 3 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [OWNER + '/0 required dependency cannot donate nested publication',
                     OWNER + '/0 actual callback has its own identity boundary',
                     OWNER + '/1 required dependency cannot donate nested publication']
assert failed_names == expected_failures and len(failed_names) == 3, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 8)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=46,', out), 'direct consumer population'

diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
source = read(MODULE).decode()
variants = [
    ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
     OWNER + '/0 required dependency cannot donate nested publication'),
    ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                      ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
     OWNER + '/1 actual callback has its own identity boundary'),
    ('diagnostic', edit(source, diagnostic, ''),
     OWNER + ' required dependency diagnostic remains exact'),
]
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 864
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
    tap(out, 864)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 283
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
assert names == freeze['live_claims'] == ['method-required-ast-array-end-isolation']
assert len(bindings) == 283
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 864, 'cold_assertions': 8,
    'actual_caller_modes': 3, 'bounded_branch_modes': 66, 'required_callers': 1,
    'required_callback_roles': 1, 'actually_invoked_roles': 1, 'validated_only_roles': 0,
    'paired_original_semantic_failures': 3, 'paired_original_passing_controls': 861,
    'semantic_source_faults': 3, 'consumer_suites': 46, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'One required key resolver on the AST hash-index assignment fallback. Three complete native-current callback rows and66 controlled branch rows compare exactly; scalar context/local key copy, lazy validation after source/fast-path guards, helper/node/map/callback/fatal identities, new target-span construction and direct results survive. Exactly3 original publication REDs/861 passing controls become864 current GREEN. Three syntax-valid complete source faults, original164 accepted supplied inputs plus two bounded fixtures (46 suites/166 files), evidence controls and original283 array-end binding preservation. Explicit secondary-helper controls cover scalar/append/hash-fast/hash-fallback/nested and variable-source paths without complete helper/AST grammar/language or optional/direct/other owner admission. Output/mapped/full-private/canonical/parent admissions remain open. Read-only toolchain and repository-volume scratch.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained assignment review drift'
print('AST assignment review PASS864/8/3; callbacks3/branches66; paired3RED/864GREEN; consumers46/166; original283 preserved')
