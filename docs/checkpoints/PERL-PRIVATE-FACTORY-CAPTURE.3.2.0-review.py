"""Readonly reconstruction of the single package-flow binding and all bounded proof."""
import ast
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4cc0b5a2a39ef3eec8baafbf874e43bd855e8b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_package_flow_probe.pl'
COLD = 't/actionir_package_flow_cold_probe.pl'
TEST = 't/actionir_package_flow_capture.t'
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5.json'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-consumers.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
channel = lambda row, name: base64.b64decode(row[name + '_base64'], validate=True)
used = set()
assert sys.argv[1:] in ([], ['--capture'])


def read(path):
    used.add(path)
    return (ROOT / path).read_bytes()


def record(tail):
    return json.loads(read(PREFIX + tail + '.json'))


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def tap(row):
    output = channel(row, 'stdout')
    plans = re.findall(rb'^1\.\.(\d+)$', output, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', output, re.M)
    assert len(plans) == 1 and [int(n) for failed, n, label in rows] == list(range(1, int(plans[0]) + 1)), 'complete TAP'
    return [label.decode() for failed, n, label in rows], [label.decode() for failed, n, label in rows if failed]


freeze = record('freeze')
before_claim = old(OLD_CLAIM)
assert read(freeze['before']) == before_claim and len(before_claim) == 84391
assert freeze['base'] == BASE and freeze['claim'] == OLD_CLAIM
assert freeze['original_sha256'] == sha(before_claim)
assert freeze['producer_sha256'] == sha(read(PREFIX + 'freeze.py'))
expected_claim = json.loads(before_claim)
live = [row for row in expected_claim['claims'] if row['durability'].get('mode') == 'live']
assert len(live) == 1 and live[0]['name'] == 'hash-index-required-callback-isolation'
assert len(live[0]['durability']['inputs']) == 350
for entry in live[0]['durability']['inputs']:
    assert sha(old(entry['path'])) == entry['sha256'], 'accepted original binding'
live[0]['durability'].update(mode='historical', revision=BASE)
assert json.loads(read(OLD_CLAIM)) == expected_claim, 'frozen original claim fields'
assert freeze['after_sha256'] == sha(read(OLD_CLAIM))
baseline = record('baseline')
assert baseline['producer_sha256'] == freeze['producer_sha256']
assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-publish-claim.py']
assert baseline['returncode'] == 0 and not channel(baseline, 'stderr') and b'PASS' in channel(baseline, 'stdout')
tree = ast.parse(read(PREFIX + 'freeze.py'))
writes = ast.literal_eval(next(node.value for node in tree.body if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets)))
assert freeze['planned_writes'] == sorted(writes)
assert freeze['intersections'] == [{'claim': OLD_CLAIM, 'name': live[0]['name'], 'bindings': 350,
    'intersections': sorted(set(writes) & {entry['path'] for entry in live[0]['durability']['inputs']})}]

original = old(MODULE)
old_call = b'$lower_flow_composite_expr->($trimmed)'
new_call = b'_bind_emission_dependency($lower_flow_composite_expr)->($trimmed)'
start = original.index(b'sub _lower_mutation_slot_value_expr {')
end = original.index(b'\nsub ', start + 1)
body = original[start:end]
assert body.count(old_call) == 1
source = read(MODULE)
assert source == original[:start] + body.replace(old_call, new_call, 1) + original[end:], 'whole module exact one-call change'
assert source.count(b'\n') == original.count(b'\n'), 'unrelated diagnostic line identities survive'
first_source = read(PREFIX + 'module-first.pm')
line = b'  my $flow_expr = ' + new_call + b';'
assert source.count(line) == 1 and first_source == source.replace(line, b'      ' + line, 1), 'sole indentation correction'
failures = record('first-review-failures')
assert len(failures['rows']) == 2
for row, name, reason in zip(failures['rows'], ('review', 'consumer-review'),
                            (b'whole module exact one-call change', b'complete consumer summary')):
    assert row['command'] == ['python3', PREFIX + name + '.py', '--capture'] and row['returncode'] == 1
    assert row['producer_sha256'] == sha(read(PREFIX + name + '-first.py'))
    assert reason in channel(row, 'merged_channel'), 'retained first reviewer failure'
first_consumer = read(PREFIX + 'consumer-review-first.py')
assert read(PREFIX + 'consumer-review.py') == first_consumer.replace(b'13670', b'13660').replace(
    b"PREFIX+'consumers.json'", b"PREFIX+'consumers-final.json'").replace(
    b"PREFIX+'capture.py'", b"PREFIX+'capture-final.py'"), 'sole consumer count/final-target correction'
seed_raw = read(SEED)
assert seed_raw == old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 207
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha(read(path)) == digest, 'unchanged supplied seed input'
native, first_current, before, first_fixture, first_consumers = [record(name) for name in ('native', 'current', 'before', 'fixture', 'consumers')]
current, fixture, consumers = [record(name) for name in ('current-final', 'fixture-final', 'consumers-final')]
native_inputs = dict(seed['inputs'], **{PROBE: sha(read(PROBE)), COLD: sha(read(COLD))})
current_inputs = dict(native_inputs, **{MODULE: sha(source)})
paired_inputs = dict(current_inputs, **{TEST: sha(read(TEST)), PREFIX + 'native.json': sha(read(PREFIX + 'native.json'))})
before_inputs = dict(paired_inputs, **{MODULE: sha(original)})
first_current_inputs = dict(current_inputs, **{MODULE: sha(first_source)})
first_paired_inputs = dict(paired_inputs, **{MODULE: sha(first_source)})
assert len(native_inputs) == 209 and len(paired_inputs) == 211
native_producer = read(PREFIX + 'capture-native.py')
producer = read(PREFIX + 'capture.py')
assert producer == native_producer.replace(b'Only the two required package-flow/lowerer resolver returns',
    b'Only the direct package-flow invocation'), 'sole copied scope-wording correction'
final_producer = read(PREFIX + 'capture-final.py')
assert final_producer == producer.replace(b"PREFIX + mode + '.json'", b"PREFIX + mode + '-final.json'"), 'separate final captures only'
probe_command = ['perl', '-Iperl', './' + PROBE, 'observe']
for row, inputs, command, instrument in (
    (native, native_inputs, probe_command, native_producer),
    (first_current, first_current_inputs, probe_command, producer),
    (before, before_inputs, ['perl', '-Iperl', TEST], native_producer),
    (first_fixture, first_paired_inputs, ['perl', '-Iperl', TEST], producer),
    (first_consumers, first_paired_inputs, seed['command'] + [TEST], producer),
    (current, current_inputs, probe_command, final_producer),
    (fixture, paired_inputs, ['perl', '-Iperl', TEST], final_producer),
    (consumers, paired_inputs, seed['command'] + [TEST], final_producer)):
    assert row['inputs'] == inputs and row['command'] == command and row['unchanged'], 'complete capture population'
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == sha(seed_raw)
    assert row['producer_sha256'] == sha(instrument)
assert native['returncode'] == current['returncode'] == fixture['returncode'] == consumers['returncode'] == 0
assert all(not channel(row, 'stderr') for row in (native, current, fixture))
assert all(row['returncode'] == 0 for row in (first_current, first_fixture, first_consumers))
assert channel(first_current, 'stdout') == channel(current, 'stdout') and not channel(first_current, 'stderr'), 'native callback values aliases effects errors'
assert channel(first_fixture, 'stdout') == channel(fixture, 'stdout') and not channel(first_fixture, 'stderr'), 'positive runtime TAP'
assert channel(first_consumers, 'stderr') == channel(seed, 'stderr')
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', channel(first_consumers, 'stdout'), re.M) == [(b'67', b'13660')]
left, right = [json.loads(channel(row, 'stdout')) for row in (native, current)]
assert [len(left[k]) for k in ('callbacks', 'branches', 'authority')] == [4, 32, 2]
assert len({row['name'] for row in left['branches']}) == 32
for name in ('callbacks', 'branches', 'public', 'cold'):
    assert left[name] == right[name], 'native callback values aliases effects errors'
for known, (old_row, row) in enumerate(zip(left['authority'], right['authority'])):
    expected = copy.deepcopy(old_row)
    assert old_row['known'] == known and old_row['eligible'] == [1] and old_row['parent_packet'] == 1
    expected.update(eligible=[known], parent_packet=0)
    assert row == expected, 'actual current authority boundaries'
names, red = tap(before)
positive_names, positive_red = tap(fixture)
assert len(names) == 299 and names == positive_names and before['returncode'] == 3
assert red == ['package-flow known0 child cannot donate parent packet',
               'package-flow known0 actual callback controls eligibility',
               'package-flow known1 child cannot donate parent packet']
assert not positive_red, 'positive runtime TAP'

consumer_review = record('consumer-review')
assert consumer_review['result'] == 'PASS' and consumer_review['suites'] == 67 and consumer_review['assertions'] == 13660
assert consumer_review['producer_sha256'] == sha(read(PREFIX + 'consumer-review.py'))
assert consumer_review['consumer_sha256'] == sha(read(PREFIX + 'consumers-final.json'))
assert consumer_review['supplied_inputs'] == paired_inputs and consumer_review['suite_paths'] == consumers['command'][3:]
assert channel(consumers, 'stderr') == channel(seed, 'stderr')
headers = re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', channel(consumers, 'stdout'), re.M)
assert headers == [path.encode() for path in consumers['command'][3:]], 'all67 actual command paths including checkpoint fixture'
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', channel(consumers, 'stdout'), re.M) == [(b'67', b'13660')]
assert len(re.findall(rb'^1\.\.\d+$', channel(consumers, 'stdout'), re.M)) == 67
assert channel(consumers, 'stdout').endswith(b'Result: PASS\n') and b'All tests successful.\n' in channel(consumers, 'stdout')
assert not re.search(rb'^not ok ', channel(consumers, 'stdout'), re.M)

inverses = record('inverses')
assert inverses['producer_sha256'] == sha(read(PREFIX + 'faults.py'))
assert inverses['fixture_sha256'] == sha(read(PREFIX + 'fixture.json'))
assert inverses['inputs'] == first_paired_inputs and inverses['unchanged'] and len(inverses['rows']) == 6
bound = new_call.decode()
mutations = [
 ('raw-callback', bound, old_call.decode(), 3, 'package-flow known0 child cannot donate parent packet'),
 ('wrapper-identity', bound, '_bind_emission_dependency(sub { return $lower_flow_composite_expr->(@_) })->($trimmed)', 1,
  'package-flow known1 actual callback controls eligibility'),
 ('copied-arguments', bound, '_bind_emission_dependency(sub { my @args=@_; return $lower_flow_composite_expr->(@args) })->($trimmed)', 35,
  'package-flow effect complete native observation'),
 ('map-selection', bound, '_bind_emission_dependency($deps->{lower_flow_composite_expr})->($trimmed)', 85,
  'package-flow string authored result'),
 ('removed-branch', "ref($lower_flow_composite_expr) eq 'CODE'", '0', 55,
  'package-flow public override remains reachable'),
 ('caller-equality', '$flow_expr ne $trimmed', '$flow_expr ne $expr', 7,
  'package-flow mutated-original authored result'),
]
for entry, (label, old_text, new_text, count, reason) in zip(inverses['rows'], mutations):
    raw = read(entry['path'])
    row = json.loads(raw)
    assert row['label'] == entry['label'] == label and entry['path'] == PREFIX + 'inverse-' + label + '.json'
    assert entry['sha256'] == sha(raw), 'inverse artifact binding'
    selected = first_source[start:first_source.index(b'\nsub ', start + 1)]
    assert selected.count(old_text.encode()) == 1
    mutant = first_source[:start] + selected.replace(old_text.encode(), new_text.encode(), 1) + first_source[start + len(selected):]
    assert channel(row, 'source') == mutant and row['source_sha256'] == sha(mutant), 'whole exact mutant source'
    assert row['inputs'] == dict(first_paired_inputs, **{MODULE: sha(mutant)}) and row['unchanged']
    assert row['producer_sha256'] == inverses['producer_sha256'] and row['fixture_sha256'] == inverses['fixture_sha256']
    assert row['syntax_command'] == ['perl', '-Iperl', '-c', MODULE]
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in channel(row['syntax'], 'stderr')
    fault_names, failures = tap(row)
    assert fault_names == names and row['returncode'] != 0 and entry['failed'] == len(failures) == count and row['reason'] == entry['reason'] == reason and reason in failures, 'effective named semantic fault'
    assert row['command'] == fixture['command']

book = record('book-review')
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
assert book['producer_sha256'] == sha(read(PREFIX + 'book-review.py'))
assert book['book_capture_sha256'] == sha(read(PREFIX + 'book.json'))
assert book['book_producer_sha256'] == sha(read(PREFIX + 'book.py'))
for path, digest in book['source_inputs'].items():
    assert sha(read(path)) == digest, 'complete current book input'
# The original diagnosis remains historical; its reviewer explicitly binds4b48593b5.
flow_prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-'
flow_report = json.loads(read(flow_prefix + 'flow-review.json'))
assert flow_report['base'] == '4b48593b59acb7aba4d616ae1bdc4320fbbf5364' and flow_report['result'] == 'PASS'
assert flow_report['producer_sha256'] == sha(read(flow_prefix + 'flow-review.py'))
for path, digest in flow_report['checked'].items():
    assert sha(read(path)) == digest, 'historical diagnostic artifact binding'
commands = []
for path in (PREFIX + 'consumer-review.py', PREFIX + 'book-review.py', flow_prefix + 'flow-review.py'):
    result = subprocess.run(['python3', path], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, 'actual readonly component review'
    commands.append({'command': ['python3', path], 'returncode': result.returncode,
                     'stdout_base64': base64.b64encode(result.stdout).decode(),
                     'stderr_base64': base64.b64encode(result.stderr).decode()})
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'base': BASE,
    'preserved_claim_bytes': 84391, 'preserved_bindings': 350, 'native_inputs': 209, 'paired_inputs': 211,
    'callbacks': 4, 'branches': 32, 'authority_rows': 2, 'public_rows': 2, 'cold_rows': 2,
    'assertions': 299, 'original_red': 3, 'original_controls': 296,
    'supplied_suites': 67, 'supplied_assertions': 13660, 'faults': {row[0]: row[3] for row in mutations},
    'book_sources': 89, 'book_controls': 3, 'actual_component_reviews': commands,
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(used)},
    'scope': 'Only one legacy package-flow invocation changes. Actual CODE selection, local trimmed-slot aliases, scalar context, maps/package references/replacement/localization, ordinary results/errors/effects and public generated source remain native. First observations and all channels remain exact with no normalization. The original capture producer copied an inaccurate two-resolver scope phrase; its exact source remains capture-native.py, and only that descriptive phrase changes in capture.py. Initial consumer reviewer count typo and source indentation denial retain exact instruments/merged channels; distinct final current/fixture/consumer runs verify the sole whitespace correction. Six actual source faults retain the first semantically identical source and every original channel. No observation/hash is refreshed. Original350/full84391 record remains exact except one live mode/revision pair. Earlier rejected compact public argument premise and its six historical replay channels remain explicit at4b48593b5. Complete helpers/language, other optional/direct, full-private, pipeline/output/mapping/parent and canonical admissions remain separate.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'package-flow review drift'
print('Package-flow review PASS299/3 RED/296 controls; native4/branches32/authority2/public2/cold2; six faults;67/211/13660;book89/3; original350 preserved')
