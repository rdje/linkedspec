"""Readonly block-value acceptance and exact original273-input preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de3b50dd06d4aff6babf379282f90368810d49e5'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_block_value_capture.t'
COLD = 't/actionir_method_block_value_capture_cold.t'
OWNER = '_lower_block_value_expr'
KEYS = ('trim_action_ir_value', 'split_action_ir_statements', 'parse_method_function_expr')
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
assert len(original) == 154 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{MODULE: digest(read(MODULE)), TEST: digest(read(TEST)), COLD: digest(read(COLD))})
assert len(inputs) == 156 and 't/trace_emit_context_bridge.t' in inputs
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3
producer = read(PREFIX + 'capture.py')


def edit(source, old, new):
    start = source.index('sub ' + OWNER + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


expected_source = edit(original[MODULE].decode(), ' return $cb;', ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds one required return seam'


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
assert [(r['key'], r['outcome']) for r in observations[0]['callbacks']] == [
    (key, outcome) for key in KEYS for outcome in ('string', 'undefined', 'fatal')]
assert len(observations[0]['callbacks']) == 9
assert [r['case'] for r in observations[0]['branches']] == ['ast-string', 'ast-zero', 'ast-reference', 'ast-undefined', 'ast-empty', 'ast-other', 'bridge-guard', 'nonfinal-return', 'final-return', 'ordinary', 'brace-component', 'invalid-return', 'empty-payload', 'fat-arrow', 'malformed-brace', 'empty-split']
positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 222)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive block value capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 6
assert out.count(b'target callback keeps native invocation count') == 9
assert out.count(b'actual split-array alias keeps native identity') == 9
assert out.count(b'independent execution preserves guarded side effects') == 3
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 222)
assert before_row['returncode'] == 9 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = []
for key in KEYS:
    expected_failures.extend([OWNER + '/' + key + '/0 required dependency cannot donate nested publication',
        OWNER + '/' + key + '/0 actual callback has its own identity boundary',
        OWNER + '/' + key + '/1 required dependency cannot donate nested publication'])
assert failed_names == expected_failures and len(failed_names) == 9, 'unexpected original failure set'
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
assert re.search(rb'Files=37,', out), 'direct consumer population'

diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
source = read(MODULE).decode()
variants = [
    ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
     OWNER + '/trim_action_ir_value/0 required dependency cannot donate nested publication'),
    ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                      ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
     OWNER + '/trim_action_ir_value/1 actual callback has its own identity boundary'),
    ('diagnostic', edit(source, diagnostic, ''),
     OWNER + '/normalize_method_args_with_optional_scope required dependency diagnostic remains exact'),
]
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 222
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
    tap(out, 222)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 273
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
assert names == freeze['live_claims'] == ['method-required-local-return-isolation']
assert len(bindings) == 273
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 222, 'cold_assertions': 5,
    'actual_caller_modes': 9, 'bounded_branch_modes': 16, 'required_callers': 1, 'required_callback_roles': 4,
    'actually_invoked_roles': 3, 'validated_only_roles': 1,
    'paired_original_semantic_failures': 9, 'paired_original_passing_controls': 213,
    'semantic_source_faults': 3, 'consumer_suites': 37, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Exactly one block-value required resolver; trim/split/parse invoked, normalizer validated only. Nine native/current callback ledgers and16 bounded branch ledgers compare in full. Actual scalar context, top-level copy, split-array slot alias, public callback references, native effects, incoming/successful error effects and fatal object identity survive. AST parse/secondary lowerers have explicit controlled results; actual copied bridge map and early zero/reference results observed. Actual brace/fat-arrow helpers run only on supplied bounded cases. Independent Perl execution of three controlled generated blocks observes return value and guarded side effects. Exactly9 original publication-isolation REDs/213 passing controls become222 current GREEN; single trim publication avoids ambiguity-guard confounding. Three syntax-valid complete semantic source faults. Original154 supplied Git inputs retain three JSON reader artifacts; only MethodLowering overlaid plus two fixtures. Every original273 claim binding/proof field stays historical at de3b50dd; already historical claims unchanged. Read-only interpreter/core/toolchain reused with repository-volume scratch. No complete secondary-helper, grammar/language, optional/direct, pipeline/output/mapped/full-private/canonical/parent admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained block value review drift'
print('Block value review PASS222/5/3; callbacks9/branches16; paired9RED/222GREEN; consumers37/156; original273 preserved')
