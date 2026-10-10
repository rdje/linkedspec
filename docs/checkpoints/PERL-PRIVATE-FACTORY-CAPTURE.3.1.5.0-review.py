"""Readonly bare/mutation required acceptance, native pairing and original main method/value preservation."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4b48593b59acb7aba4d616ae1bdc4320fbbf5364'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-consumers.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_slot_capture.t'
COLD = 't/actionir_method_slot_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNERS = ['_lower_source_slot_bare_scalar_read_expr', '_lower_mutation_slot_value_expr']
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
assert len(original) == 168 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed: ' + path
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, COLD)})
assert len(inputs) == 170 and 't/trace_emit_context_bridge.t' in inputs
assert len([p for p in inputs if p.startswith('docs/checkpoints/') and p.endswith('.json')]) == 3
for path in (PUBLIC_TEST, PUBLIC_CONTRACT):
    assert read(path) == blob(path), 'public uniform-binding input changed'
producer = read(PREFIX + 'capture.py')


def edit(source, owner, old, new):
    start = source.index('sub ' + owner + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


expected_source = original[MODULE].decode()
for label, owner in zip(('bare', 'mutation'), OWNERS):
    indent = '\t ' if label == 'bare' else ' '
    expected_source = edit(expected_source, owner, indent + ' return $cb;',
                           indent + ' return _bind_emission_dependency($cb);')
assert read(MODULE) == expected_source.encode(), 'production exceeds two required return seams'


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
roles = [(OWNERS[0], 'trim_action_ir_value'), (OWNERS[1], 'trim_action_ir_value'),
         (OWNERS[1], 'lower_primitive_literal_expr')]
assert [(r['owner'], r['role'], r['outcome']) for r in observations[0]['callbacks']] == [
    (('bare' if owner == OWNERS[0] else 'mutation'), role, outcome)
    for owner, role in roles for outcome in ('string', 'undefined', 'fatal')]
expected_branches = ['kind-' + name for name in ('array', 'hash', 'scalar', 'other', 'undefined')]
expected_branches += ['kind-name-mutation']
reserved = 'undef true false descr STRING info minfo IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS CAPTURE'.split()
assert len(reserved) == 18
expected_branches += ['reserved-' + name for name in reserved]
expected_branches += ['source-' + name for name in ('undefined', 'empty', '0', 'bad name', 'call()', ':slot')]
expected_branches += ['mutation-source-' + name for name in ('undefined', '', ':slot')]
expected_branches += [owner + '-trim-' + value for owner in ('bare', 'mutation') for value in ('', '0')]
expected_branches += ['mutation-bare-' + value for value in ('FAST', '0', '', 'undefined')]
expected_branches += ['mutation-literal-' + value for value in ('', '0', 'undefined')]
expected_branches += ['mutation-bare-guard']
expected_branches += ['mutation-flow-' + value for value in ('FLOW', '0', '', 'undefined', 'equal', 'noncode', 'mutation', 'mutated-fallback')]
expected_branches += ['mutation-method-' + value for value in ('undefined', '', '0')]
expected_branches += ['mutation-literal-reference', 'mutation-method-reference']
assert len(expected_branches) == len(set(expected_branches)) == 58
assert [r['case'] for r in observations[0]['branches']] == expected_branches
for owner, required in zip(OWNERS, (['trim_action_ir_value'], ['trim_action_ir_value', 'lower_primitive_literal_expr'])):
    text = original[MODULE].decode()
    start = text.index('sub ' + owner + ' {')
    end = text.index('\nsub ', start + 1)
    body = text[start:end]
    assert re.findall(r"\$require_dep->\('([^']+)'\)", body) == required, 'required acquisition population'
    assert body.index("$require_dep->('") < body.index('return undef unless defined $expr;')
positive = record(PREFIX + 'fixture.json')
out, err = channel(positive, inputs, ['perl', '-Iperl', TEST])
tap(out, 455)
assert positive['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err, 'positive bare/mutation required capture failed'
assert out.count(b'required dependency cannot donate nested publication') == 6
assert out.count(b'eager diagnostic precedes undefined-input guard') == 6
positive_out = out
before_row = record(PREFIX + 'before.json')
before_population = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
before_out, before_err = channel(before_row, before_population, ['perl', '-Iperl', TEST])
tap(before_out, 455)
assert before_row['returncode'] == 9 and before_err, 'original caller isolation RED missing'
failed_names = [line.split(b' - ', 1)[1].decode() for line in before_out.splitlines() if line.startswith(b'not ok ')]
expected_failures = [reason for owner, role in roles for reason in (
    owner + '/' + role + '/0 required dependency cannot donate nested publication',
    owner + '/' + role + '/0 actual callback has its own identity boundary',
    owner + '/' + role + '/1 required dependency cannot donate nested publication')]
assert failed_names == expected_failures and len(failed_names) == 9, 'unexpected original failure set'
normalize = lambda raw: [line.removeprefix(b'not ') for line in raw.splitlines()
                         if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
assert normalize(before_out) == normalize(positive_out), 'paired assertion populations differ'
cold = record(PREFIX + 'cold.json')
out, err = channel(cold, inputs, ['perl', '-Iperl', COLD])
tap(out, 11)
assert cold['returncode'] == 0 and not re.search(rb'^not ok ', out, re.MULTILINE) and not err
consumers = record(PREFIX + 'consumers.json')
out, err = channel(consumers, inputs, seed['command'] + [TEST, COLD])
assert consumers['returncode'] == 0 and b'All tests successful.' in out, 'direct consumers failed'
assert re.search(rb'Files=50,', out), 'direct consumer population'

source = read(MODULE).decode()
variants = []
for label, owner in zip(('bare', 'mutation'), OWNERS):
    indent = '\t ' if label == 'bare' else ' '
    seam = indent + ' return _bind_emission_dependency($cb);'
    diagnostic = indent + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indent + "  unless ref($cb) eq 'CODE';"
    variants.extend([
        (label + '-required', edit(source, owner, seam, indent + ' return $cb;'),
         owner + '/trim_action_ir_value/0 required dependency cannot donate nested publication'),
        (label + '-identity', edit(source, owner, seam, indent + ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
         owner + '/trim_action_ir_value/1 actual callback has its own identity boundary'),
        (label + '-diagnostic', edit(source, owner, diagnostic, ''),
         owner + '/trim_action_ir_value eager diagnostic precedes undefined-input guard'),
    ])
index = record(PREFIX + 'inverses.json')
assert index['result'] == 'PASS' and index['producer_sha256'] == digest(producer)
assert index['source_sha256'] == inputs[MODULE] and index['assertions'] == 455
assert len(index['rows']) == 6, 'missing inverse'
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
    tap(out, 455)
    assert normalize(out) == normalize(positive_out), 'source-fault assertion population changed'
    failures = [line.decode() for line in out.splitlines() if line.startswith(b'not ok ') and reason.encode() in line]
    assert row['returncode'] != 0 and failures, 'missing distinguishing semantic RED'
    assert row['semantic_failures'] == failures, 'semantic failure identity'

freeze = record(PREFIX + 'freeze.json')
assert freeze['revision'] == BASE and freeze['claim'] == CLAIM and freeze['verified_bindings'] == 299
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
assert names == freeze['live_claims'] == ['main-method-required-isolation']
assert len(bindings) == 299
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original claim input identity'
after = read(CLAIM)
assert json.loads(after) == old, 'original claim changed beyond mode/revision'
assert digest(after) == freeze['after_sha256']

report = {'result': 'PASS', 'base': BASE, 'assertions': 455, 'cold_assertions': 11,
    'actual_caller_modes': 9, 'bounded_branch_modes': 58, 'required_callers': 2,
    'required_callback_roles': 3, 'actually_invoked_roles': 3, 'validated_only_roles': 0,
    'paired_original_semantic_failures': 9, 'paired_original_passing_controls': 446,
    'semantic_source_faults': 6, 'consumer_suites': 50, 'supplied_files': len(inputs),
    'historical_bindings_preserved': len(bindings), 'checked': dict(sorted(checked.items())),
    'reviewer_sha256': digest(Path(__file__).read_bytes()),
    'scope': 'Only two required resolver returns in bare-source and mutation-slot owners. Three invoked callback roles in9 exact native-current string/undefined/fatal rows and58 enumerated guard/kind/reserved/zero/alias/reference/fallback branches. Local source copies, actual public maps, eager validation before undefined guard and scalar context/errors/fatal identity remain native. Actual optional kind/package-flow selection remains unchanged; secondary helpers are explicit controls. No optional isolation, complete helper/AST/language, output/mapped/full-private/canonical/parent admission. Paired9 original publication REDs/446 passing controls become455 current GREEN. Six syntax-valid source faults, supplied50 suites/170 files and all299 original main bindings remain recoverable. Read-only toolchain; repository-volume scratch.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review already captured'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'retained bare/mutation required review drift'
print('Bare/mutation required review PASS455/11/6; callbacks9/branches58; paired9RED/455GREEN; consumers50/170; original299 preserved')
