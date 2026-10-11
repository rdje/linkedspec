"""Readonly reconstruction of both hash-index boundaries and their complete evidence."""
import base64
import ast
import copy
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '557a7d9e533710c6aae211f905ca2f231a8aedae'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_hash_index_required_probe.pl'
COLD = 't/actionir_hash_index_required_cold_probe.pl'
TEST = 't/actionir_hash_index_required_capture.t'
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-consumers.json'
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
    plans = re.findall(rb'^1\.\.(\d+)$', output, re.MULTILINE)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', output, re.MULTILINE)
    assert len(plans) == 1 and [int(n) for failed, n, label in rows] == list(range(1, int(plans[0]) + 1)), 'complete TAP'
    return [label.decode() for failed, n, label in rows], [label.decode() for failed, n, label in rows if failed]


freeze = record('freeze')
before_claim = old(OLD_CLAIM)
assert read(freeze['before']) == before_claim and len(before_claim) == 108215
assert freeze['base'] == BASE and freeze['claim'] == OLD_CLAIM
assert freeze['original_sha256'] == sha(before_claim)
assert freeze['producer_sha256'] == sha(read(PREFIX + 'freeze.py'))
expected_claim = json.loads(before_claim)
live = [r for r in expected_claim['claims'] if r['durability'].get('mode') == 'live']
assert [r['name'] for r in live] == ['finite-change-history-with-portable-evidence', 'exact-private-array-end-selector-classification']
assert [len(r['durability']['inputs']) for r in live] == [392, 12]
for claim in live:
    for entry in claim['durability']['inputs']:
        assert sha(old(entry['path'])) == entry['sha256'], 'accepted original binding'
    claim['durability'].update(mode='historical', revision=BASE)
assert json.loads(read(OLD_CLAIM)) == expected_claim, 'frozen original claim fields'
assert freeze['after_sha256'] == sha(read(OLD_CLAIM))
baseline = record('baseline')
assert baseline['producer_sha256'] == freeze['producer_sha256']
assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/publish.py']
assert baseline['returncode'] == 0 and not channel(baseline, 'stderr') and b'PASS' in channel(baseline, 'stdout')
assert [(r['name'], r['bindings']) for r in freeze['intersections']] == [(r['name'], len(r['durability']['inputs'])) for r in live]
assert all(r['claim'] == OLD_CLAIM for r in freeze['intersections'])
freezer = ast.parse(read(PREFIX + 'freeze.py'))
write_node = next(node.value for node in freezer.body if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets))
writes = {OLD_CLAIM if isinstance(node, ast.Name) and node.id == 'CLAIM' else ast.literal_eval(node) for node in write_node.elts}
assert freeze['planned_writes'] == sorted(writes)
assert freeze['intersections'] == [{'claim': OLD_CLAIM, 'name': claim['name'],
    'bindings': len(claim['durability']['inputs']),
    'intersections': sorted(writes & {entry['path'] for entry in claim['durability']['inputs']})}
    for claim in live], 'complete preserved intersections'

original = old(MODULE).decode()
expected_source = original
for owner in ('_parse_hash_index_assignment_operator_statement', '_lower_hash_index_assignment_operator_statement'):
    begin = expected_source.index('sub ' + owner + ' {')
    end = expected_source.index('\nsub ', begin + 1)
    body = expected_source[begin:end]
    assert body.count('return $cb;') == 1
    expected_source = expected_source[:begin] + body.replace('return $cb;', 'return _bind_emission_dependency($cb);') + expected_source[end:]
source = read(MODULE).decode()
assert source == expected_source, 'whole module exact two-return change'
seed_raw = read(SEED)
assert seed_raw == old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 203
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha(read(path)) == digest, 'unchanged supplied seed input'
native = record('native')
current = record('current')
before = record('before')
fixture = record('fixture')
consumers = record('consumers')
native_inputs = dict(seed['inputs'])
native_inputs.update({PROBE: sha(read(PREFIX + 'native-draft-probe.pl')), COLD: sha(read(COLD))})
current_inputs = dict(native_inputs, **{PROBE: sha(read(PROBE)), MODULE: sha(source.encode())})
paired_inputs = dict(current_inputs, **{TEST: sha(read(TEST)), PREFIX + 'native.json': sha(read(PREFIX + 'native.json'))})
before_inputs = dict(paired_inputs, **{MODULE: sha(original.encode())})
assert len(native_inputs) == len(current_inputs) == 205 and len(paired_inputs) == 207


def capture(row, population, command):
    assert row['inputs'] == population and row['command'] == command and row['unchanged'], 'complete capture population'
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == sha(seed_raw)
    assert row['producer_sha256'] == sha(read(PREFIX + 'capture.py'))


probe_command = ['perl', '-Iperl', './' + PROBE, 'observe']
capture(native, native_inputs, probe_command)
capture(current, current_inputs, probe_command)
capture(before, before_inputs, ['perl', '-Iperl', TEST])
capture(fixture, paired_inputs, ['perl', '-Iperl', TEST])
capture(consumers, paired_inputs, seed['command'] + [TEST])
assert native['returncode'] == current['returncode'] == fixture['returncode'] == consumers['returncode'] == 0
assert not channel(current, 'stderr') and not channel(fixture, 'stderr')
correction = record('native-correction')
native_review = record('native-review')
assert native_review['result'] == 'PASS'
assert native_review['producer_sha256'] == sha(read(PREFIX + 'native-review.py'))
assert native_review['original_capture_sha256'] == sha(read(PREFIX + 'native.json'))
assert native_review['corrected_capture_sha256'] == sha(read(PREFIX + 'native-correction.json'))
read(PREFIX + 'native-correction.py')
draft_reviewer = read(PREFIX + 'native-review-draft.py').decode()
current_reviewer = read(PREFIX + 'native-review.py').decode()
old_predicate = "if row['name'].split('-', 1)[1].startswith(('missing-', 'noncode-')):"
replacement = "if row['name'] in " + repr(tuple(native_review['locations'])) + ':'
assert draft_reviewer.count(old_predicate) == 1
assert current_reviewer == draft_reviewer.replace(old_predicate, replacement), 'sole reviewer predicate correction'
reviewer_correction = record('reviewer-correction')
assert reviewer_correction['draft_sha256'] == sha(draft_reviewer.encode())
assert reviewer_correction['current_sha256'] == sha(current_reviewer.encode())
assert reviewer_correction['producer_sha256'] == sha(read(PREFIX + 'reviewer-correction.py'))
assert reviewer_correction['returncode'] == 1 and not channel(reviewer_correction, 'stdout')
assert b"TypeError: expected string or bytes-like object, got 'NoneType'" in channel(reviewer_correction, 'stderr')
spec = importlib.util.spec_from_file_location('native_review', ROOT / (PREFIX + 'native-review.py'))
component = importlib.util.module_from_spec(spec)
spec.loader.exec_module(component)
observed_native = json.loads(channel(native, 'stdout'))
observed_current = json.loads(channel(current, 'stdout'))
left, locations, addresses = component.normalized(observed_native)
right, current_locations, current_addresses = component.normalized(observed_current)
assert locations == current_locations and addresses == current_addresses
for name in ('callbacks', 'branches', 'public', 'cold'):
    assert left[name] == right[name], 'native callback values aliases effects errors'
ordinary = {'target': 'meta', 'key': 'key', 'value': 'value'}
statement = 'SET(meta,KEY(key),VALUE(value))'
roles = [('parser', 'trim_action_ir_value', 3), ('lowerer', 'trim_action_ir_value', 4), ('lowerer', 'lower_scalar_access_key_expr', 1)]
expected_authority = []
for owner, role, calls in roles:
    for known in (0, 1):
        value = json.dumps(ordinary, separators=(',', ':'), sort_keys=True) if owner == 'parser' else statement
        expected_authority.append({'owner': owner, 'role': role, 'known': known, 'value': value,
            'ordinary': ordinary if owner == 'parser' else statement, 'eligible': [known] * calls,
            'parent_packet': 0, 'selected_calls': calls, 'map_identity': 1})
assert observed_current['authority'] == expected_authority, 'actual current authority boundaries'
names, red = tap(before)
positive_names, positive_red = tap(fixture)
expected_red = [f'hash-index authority {owner} {role} known{known} {reason}'
                for owner, role, calls in roles for known in (0, 1)
                for reason in ('no child publication donation', 'actual callback identity')
                if known == 0 or reason == 'no child publication donation']
assert len(names) == 413 and names == positive_names and red == expected_red and before['returncode'] == 9
assert not positive_red, 'positive runtime TAP'

consumer_review = record('consumer-review')
assert consumer_review['result'] == 'PASS' and consumer_review['suites'] == 66 and consumer_review['assertions'] == 13361
assert consumer_review['producer_sha256'] == sha(read(PREFIX + 'consumer-review.py'))
assert consumer_review['consumer_sha256'] == sha(read(PREFIX + 'consumers.json'))
assert consumer_review['supplied_inputs'] == paired_inputs and consumer_review['suite_paths'] == consumers['command'][3:]
assert channel(consumers, 'stderr') == channel(seed, 'stderr')
headers = re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', channel(consumers, 'stdout'), re.MULTILINE)
assert headers == [p.encode() for p in consumers['command'][3:]], 'all66 actual command paths including checkpoint fixture'
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', channel(consumers, 'stdout'), re.MULTILINE) == [(b'66', b'13361')]
assert len(re.findall(rb'^1\.\.\d+$', channel(consumers, 'stdout'), re.MULTILINE)) == 66
assert channel(consumers, 'stdout').endswith(b'Result: PASS\n') and b'All tests successful.\n' in channel(consumers, 'stdout')
assert not re.search(rb'^not ok ', channel(consumers, 'stdout'), re.MULTILINE)

inverses = record('inverses')
assert inverses['producer_sha256'] == sha(read(PREFIX + 'faults.py'))
assert inverses['fixture_sha256'] == sha(read(PREFIX + 'fixture.json'))
assert inverses['inputs'] == paired_inputs and inverses['unchanged'] and len(inverses['rows']) == 10
mutations = {
    'raw-callback': ('return _bind_emission_dependency($cb);', 'return $cb;'),
    'wrapper-identity': ('return _bind_emission_dependency($cb);', 'return _bind_emission_dependency(sub { return $cb->(@_) });'),
    'copied-arguments': ('return _bind_emission_dependency($cb);', 'return _bind_emission_dependency(sub { my @args=@_; return $cb->(@args) });'),
    'late-map-selection': ('return _bind_emission_dependency($cb);', 'return _bind_emission_dependency(sub { return $deps->{$name}->(@_) });'),
    'missing-diagnostic': ('::_require_dep)', '::_wrong_dep)'),
}
fault_counts = {'parser': [4, 2, 6, 4, 6], 'lowerer': [6, 2, 39, 4, 14]}
expected_order = [(owner, label, count) for owner, counts in fault_counts.items() for label, count in zip(mutations, counts)]
for entry, (owner, label, count) in zip(inverses['rows'], expected_order):
    raw = read(entry['path'])
    row = json.loads(raw)
    assert row['owner'] == entry['owner'] == owner and row['label'] == entry['label'] == label
    assert entry['sha256'] == sha(raw), 'inverse artifact binding'
    function = ('_parse_' if owner == 'parser' else '_lower_') + 'hash_index_assignment_operator_statement'
    begin = source.index('sub ' + function + ' {')
    end = source.index('\nsub ', begin + 1)
    body = source[begin:end]
    old_text, new_text = mutations[label]
    assert body.count(old_text) == 1
    mutant = (source[:begin] + body.replace(old_text, new_text) + source[end:]).encode()
    assert channel(row, 'source') == mutant and row['source_sha256'] == sha(mutant), 'whole exact mutant source'
    assert row['inputs'] == dict(paired_inputs, **{MODULE: sha(mutant)}) and row['unchanged']
    assert row['producer_sha256'] == inverses['producer_sha256'] and row['fixture_sha256'] == inverses['fixture_sha256']
    assert row['syntax_command'] == ['perl', '-Iperl', '-c', MODULE]
    assert row['syntax']['returncode'] == 0 and b'syntax OK' in channel(row['syntax'], 'stderr')
    fault_names, failures = tap(row)
    assert fault_names == names and row['returncode'] != 0 and entry['failed'] == len(failures) == count and row['reason'] == entry['reason'] and row['reason'] in failures, 'effective named semantic fault'
    assert row['command'] == fixture['command']

book = record('book-review')
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
assert book['producer_sha256'] == sha(read(PREFIX + 'book-review.py'))
assert book['book_capture_sha256'] == sha(read(PREFIX + 'book.json'))
assert book['book_producer_sha256'] == sha(read(PREFIX + 'book.py'))
for path, digest in book['source_inputs'].items():
    assert sha(read(path)) == digest, 'complete current book input'
commands = []
for tail in ('native-review.py', 'consumer-review.py', 'book-review.py'):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert result.returncode == 0 and not result.stderr, 'actual readonly component review'
    commands.append({'command': command, 'returncode': result.returncode,
                     'stdout_base64': base64.b64encode(result.stdout).decode(),
                     'stderr_base64': base64.b64encode(result.stderr).decode()})
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'base': BASE,
    'preserved_claim_bytes': 108215, 'preserved_bindings': [392, 12], 'native_inputs': 205,
    'paired_inputs': 207, 'callbacks': 12, 'branches': 96, 'authority_rows': 6, 'public_rows': 3,
    'cold_rows': 4, 'assertions': 413, 'original_red': 9, 'original_controls': 404,
    'supplied_suites': 66, 'supplied_assertions': 13361, 'faults': fault_counts,
    'book_sources': 89, 'book_controls': 3, 'actual_component_reviews': commands,
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(used)},
    'scope': 'Only two required hash-index resolver returns. Actual parser integration, eager and nested selection, regex RHS magic, parsed key/value slots, contexts/maps/errors/results and separate publication remain native. Original warning, failed whole-byte comparison and overbroad predicate are exact and explicitly limited; only ten temporary prefixes/two stringified addresses normalize, with original observations retained. All four original .7 claims/392+12 accepted bindings stay exact except two live mode/revision pairs. Public Toolbox rows are source controls only. Standard compatibility, optional/direct, complete helper/AST/language/private, pipeline/output/mapping/parent and canonical admissions remain separate.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Hash-index review PASS413/9 RED/404 controls; native12/branches96/authority6/public3/cold4; ten faults;66/207/13361;book89/3; original392+12 preserved')
