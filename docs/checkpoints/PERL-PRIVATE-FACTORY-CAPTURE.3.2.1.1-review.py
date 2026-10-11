"""Readonly exact native/current caller, full-source fault and preservation review."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '354c15530fd1445ebfa8c6c0683e7b8d066caced'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_dropped_trim_probe.pl'
COLD = 't/actionir_dropped_trim_cold_probe.pl'
TEST = 't/actionir_dropped_trim_capture.t'
NATIVE = PREFIX + 'native.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0.json'
OLD_GAP = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-gap.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])


def read(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def channels(row):
    return tuple(base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64'))


def tap(row):
    stdout, stderr = channels(row)
    plan = re.findall(rb'^1\.\.(\d+)$', stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', stdout, re.M)
    assert len(plan) == 1 and int(plan[0]) == 298, 'complete298 TAP plan'
    assert [int(n) for _, n, _ in rows] == list(range(1, 299)), 'complete298 TAP members'
    return [label.decode() for _, _, label in rows], [label.decode() for failed, _, label in rows if failed]


original = old(MODULE)
source = (ROOT / MODULE).read_bytes()
start = original.index(b'sub _lower_dropped_value_statement {')
end = original.index(b'\nsub _lower_ast_call_statement {', start)
old_call = b'my $trimmed = $trim_action_ir_value->($expr);'
new_call = b'my $trimmed = _bind_emission_dependency($trim_action_ir_value)->($expr);'
owner = original[start:end]
assert owner.count(old_call) == 1
assert source == original[:start] + owner.replace(old_call, new_call, 1) + original[end:], 'exact one required invocation change'
assert source.count(b'\n') == original.count(b'\n'), 'original source line count'
seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 211 and seed['returncode'] == 0 and seed['unchanged']
base_files = {p: old(p) for p in seed['inputs']}
assert {p: sha(raw) for p, raw in base_files.items()} == seed['inputs']
for p, raw in base_files.items():
    if p != MODULE:
        assert (ROOT / p).read_bytes() == raw, 'unchanged accepted consumer input'
for p in (PROBE, COLD):
    base_files[p] = (ROOT / p).read_bytes()
records = {}
for tail in ('native', 'current', 'before', 'fixture', 'consumers'):
    row = read(tail + '.json')
    expected = dict(base_files)
    if tail not in ('native', 'before'):
        expected[MODULE] = source
    if tail not in ('native', 'current'):
        expected.update({p: (ROOT / p).read_bytes() for p in (TEST, NATIVE)})
    assert row['inputs'] == {p: sha(raw) for p, raw in expected.items()}, 'exact complete runtime capsule: ' + tail
    assert row['unchanged'] is True and row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == sha(seed_raw)
    producer = 'native-capture.py' if tail == 'native' else 'capture.py'
    assert row['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes()), 'actual capture producer'
    command = ['perl', '-Iperl', './' + PROBE, 'observe'] if tail in ('native', 'current') else (
        seed['command'] + [TEST] if tail == 'consumers' else ['perl', '-Iperl', TEST])
    assert row['command'] == command, 'exact recorded runtime command'
    records[tail] = row
native, current = (json.loads(channels(records[tail])[0]) for tail in ('native', 'current'))
for tail in ('native', 'current'):
    assert records[tail]['returncode'] == 0 and not channels(records[tail])[1], 'native/current probe must pass'
assert len(native['callbacks']) == 6 and len(native['branches']) == 33
assert len({row['name'] for row in native['callbacks'] + native['branches']}) == 39
assert current['callbacks'] == native['callbacks'] and current['branches'] == native['branches'], 'all complete native caller observations'
assert current['cold'] == native['cold'] and native['cold']['returncode'] == 0 and not native['cold']['stderr']
assert native['cold']['value']['loaded_before'] == native['cold']['value']['loaded_after'] == 0
assert len(native['cold']['value']['rows']) == 3
gap = json.loads(old(OLD_GAP))
assert (ROOT / OLD_GAP).read_bytes() == old(OLD_GAP)
assert native['authority'] == json.loads(base64.b64decode(gap['stdout_base64']))['rows'], 'exact original two-row gap diagnosis'
expected_authority = copy.deepcopy(native['authority'])
for row in expected_authority:
    row['parent_packet'] = 0
    row['eligible'] = [row['known']]
assert current['authority'] == expected_authority, 'actual callback authority and ordinary identities'
before_names, before_failures = tap(records['before'])
after_names, after_failures = tap(records['fixture'])
assert before_names == after_names and before_failures == [
    'dropped trim known0 child cannot donate parent packet',
    'dropped trim known0 actual callback controls eligibility',
    'dropped trim known1 child cannot donate parent packet'], 'exact original isolation RED membership'
assert records['before']['returncode'] == 3 and records['fixture']['returncode'] == 0 and not after_failures, 'positive fixture must pass'
assert not channels(records['fixture'])[1]

inverse = read('inverses.json')
assert inverse['result'] == 'PASS' and len(inverse['rows']) == 6
assert inverse['producer_sha256'] == sha((ROOT / (PREFIX + 'faults.py')).read_bytes())
assert inverse['module_sha256'] == sha(source)
current_start = source.index(b'sub _lower_dropped_value_statement {')
current_end = source.index(b'\nsub _lower_ast_call_statement {', current_start)
current_owner = source[current_start:current_end]
call = b'_bind_emission_dependency($trim_action_ir_value)->($expr)'
guard = (b' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'trim_action_ir_value\'"\n'
         b"  unless ref($trim_action_ir_value) eq 'CODE';")
cases = [
    ('raw-call', call, b'$trim_action_ir_value->($expr)', 'dropped trim known0 child cannot donate parent packet'),
    ('wrapper-identity', call, b'_bind_emission_dependency(sub { $trim_action_ir_value->(@_) })->($expr)', 'dropped trim known1 actual callback controls eligibility'),
    ('coerced-argument', call, b"_bind_emission_dependency($trim_action_ir_value)->(''.$expr)", 'dropped trim reference-input complete native observation'),
    ('removed-code-validation', guard, b'\n', 'dropped trim deps-missing keeps its required diagnostic'),
    ('removed-input-guard', b' return undef unless defined $expr;', b'', 'dropped trim undefined-tied stops before dependency lookup'),
    ('caller-equality', b'return undef if $lowered eq $trimmed;', b'return undef if $lowered eq $expr;', 'dropped trim method-mutated-original authored result'),
]
assert [row['name'] for row in inverse['rows']] == [name for name, _, _, _ in cases]
proof_paths = set()
for index, (name, old_text, new_text, reason) in enumerate(cases):
    entry = inverse['rows'][index]
    raw = (ROOT / entry['artifact']).read_bytes()
    assert sha(raw) == entry['artifact_sha256'], 'actual fault artifact identity'
    fault = json.loads(raw)
    assert current_owner.count(old_text) == 1
    mutated = source[:current_start] + current_owner.replace(old_text, new_text, 1) + source[current_end:]
    assert base64.b64decode(fault['module_base64'], validate=True) == mutated, 'exact full-source fault reconstruction'
    if name == 'raw-call':
        assert mutated == original, 'raw fault equals the actual accepted original source'
    assert fault['replacement'] == {'old_base64': base64.b64encode(old_text).decode(), 'new_base64': base64.b64encode(new_text).decode()}
    expected_inputs = dict(records['fixture']['inputs'])
    expected_inputs[MODULE] = sha(mutated)
    assert fault['inputs'] == expected_inputs and fault['unchanged'], 'complete215 fault input population'
    assert fault['producer_sha256'] == inverse['producer_sha256']
    assert fault['syntax']['command'] == ['perl', '-Iperl', '-c', MODULE]
    assert fault['syntax']['returncode'] == 0 and b'syntax OK' in channels(fault['syntax'])[1]
    assert fault['probe']['command'] == ['perl', '-Iperl', './' + PROBE, 'observe']
    assert fault['probe']['returncode'] == 0 and not channels(fault['probe'])[1]
    assert json.loads(channels(fault['probe'])[0])
    assert fault['fixture']['command'] == ['perl', '-Iperl', TEST] and fault['fixture']['returncode'] != 0
    names, failures = tap(fault['fixture'])
    assert names == before_names, 'all fault assertion labels preserved'
    assert failures == fault['failures'] and len(failures) == entry['failure_count'], 'fault failure membership matches actual TAP'
    assert fault['required_reason'] == entry['required_reason'] == reason, 'actual named source-fault reason'
    assert reason in failures, 'distinguishing fault semantic reason'
    assert len(failures) == (3, 1, 2, 14, 9, 4)[index], 'complete actual fault failure population'
    proof_paths.add(entry['artifact'])

before_raw = (ROOT / (PREFIX + 'before-inventory.json')).read_bytes()
assert before_raw == old(CLAIM) and len(before_raw) == 78574, 'original full inventory publication'
before = json.loads(before_raw)
assert len(before['claims']) == 1 and len(before['claims'][0]['durability']['inputs']) == 339
for entry in before['claims'][0]['durability']['inputs']:
    assert sha(old(entry['path'])) == entry['sha256'], 'original339 binding identity'
frozen = copy.deepcopy(before)
frozen['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert (ROOT / CLAIM).read_bytes() == (json.dumps(frozen, indent=2) + '\n').encode(), 'sole original mode/revision change'
freeze = read('freeze.json')
assert freeze['original_sha256'] == sha(before_raw) and freeze['after_sha256'] == sha((ROOT / CLAIM).read_bytes())
assert freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'freeze.py')).read_bytes())
baseline = read('baseline.json')
assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-publish-claim.py']
assert baseline['producer_sha256'] == freeze['producer_sha256'] and baseline['returncode'] == 0
assert not channels(baseline)[1] and b'PASS' in channels(baseline)[0], 'actual accepted publisher baseline'
for tail in ('consumer-review.py', 'book-review.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly direct-dependent proof', tail, result.stderr)
consumer = read('consumer-review.json')
book = read('book-review.json')
assert consumer['suites'] == 68 and consumer['assertions'] == 13958 and consumer['inputs'] == 215
assert book['source_count'] == 89 and book['actual_controls'] == 3
proof_paths.update(PREFIX + tail for tail in (
    'native-capture.py', 'native.json', 'capture.py', 'current.json', 'before.json', 'fixture.json', 'consumers.json',
    'faults.py', 'inverses.json', 'freeze.py', 'freeze.json', 'before-inventory.json', 'baseline.json',
    'consumer-review.py', 'consumer-review.json', 'book.py', 'book.json', 'book-review.py', 'book-review.json', 'review.py'))
proof_paths.update((OLD_GAP, CLAIM, 'docs/knowledge/perl-method-trim-capture.md'))
input_metadata = dict(records['fixture']['inputs'])
input_metadata.update(book['source_inputs'])
input_metadata.update({p: sha((ROOT / p).read_bytes()) for p in proof_paths})
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in input_metadata.items())
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'native_callbacks': 6, 'native_branches': 33, 'authority_rows': 2, 'cold_cases': 3,
    'paired_assertions': 298, 'original_red': before_failures, 'original_controls': 295,
    'fault_failures': [row['failure_count'] for row in inverse['rows']],
    'consumer_suites': 68, 'consumer_assertions': 13958, 'book_inputs': 89,
    'original_bindings': 339, 'original_record_bytes': 78574, 'input_metadata': input_metadata,
    'scope': 'One direct required trim invocation, immutable native/current caller ledgers, actual reference/slot/context/map/guard effects, original paired isolation RED and exact full-source interventions. Secondary AST/helper calls remain explicit controls; standard public compatibility is supplemental and independently retained. No full-helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact readonly composed review'
print('Dropped trim review PASS298/3 original RED/295 controls/native6/33/2/cold3; six faults; supplied68/215/13958/book89/3/original339')
