"""Readonly composed main-method kind review; --capture writes its first report."""
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
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_method_kind_probe.pl'
TEST = 't/actionir_method_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
load = lambda p: json.loads((ROOT / p).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
constants = {}
for node in ast.parse((ROOT / (PREFIX + 'run-final.py')).read_text()).body:
    if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name) and node.targets[0].id in ('OUTER_OLD', 'OUTER_NEW', 'INNER_OLD', 'INNER_NEW'):
        constants[node.targets[0].id] = ast.literal_eval(node.value)
assert len(constants) == 4
outer_old, outer_new = constants['OUTER_OLD'], constants['OUTER_NEW']
inner_old, inner_new = constants['INNER_OLD'], constants['INNER_NEW']
original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert original_source.count(outer_old) == original_source.count(inner_old) == 1
assert current_source == original_source.replace(outer_old, outer_new).replace(inner_old, inner_new), 'only two injected invocation boundaries'
assert current_source.count(b'\n') == original_source.count(b'\n')
first_fixture = (ROOT / (PREFIX + 'fixture-first.t')).read_bytes()
expected_fixture = first_fixture.replace(
    b"if ($group eq 'authority' && $expected->{id} =~ /known-0$/) {\n    $expected->{eligible} = [0];\n    $expected->{parent_packet} = 0;\n   }",
    b"if ($group eq 'authority') {\n    $expected->{eligible} = [0] if $expected->{id} =~ /known-0$/;\n    $expected->{parent_packet} = 0;\n   }")
expected_fixture = expected_fixture.replace(b'$expected->{parent_packet} = $known_code;', b'$expected->{parent_packet} = 0;')
expected_fixture = expected_fixture.replace(
    b'is($actual->{parent_packet}, $known_code, "$expected->{id} owns only its authorized publication");',
    b'is($actual->{parent_packet}, 0, "$expected->{id} child cannot donate a parent publication");')
assert expected_fixture != first_fixture and (ROOT / TEST).read_bytes() == expected_fixture, 'sole first-fixture parent-packet correction'
owned = {MODULE, 'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'}
preservation = load(PREFIX + 'preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha((ROOT / (PREFIX + 'preserve.py')).read_bytes())
assert preservation['owned_bound_paths'] == sorted(owned)
claim_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
assert [r['path'] for r in preservation['census']] == sorted(claim_paths), 'complete fixed original claim population'
selected = []
for row in preservation['census']:
    path = row['path']
    raw = old(path)
    assert row['sha256'] == sha(raw), 'original namespace claim content'
    record = json.loads(raw)
    frozen = copy.deepcopy(record)
    intersections = []
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live': continue
        hits = sorted(owned & {item['path'] for item in durability['inputs']})
        if not hits: continue
        for item in durability['inputs']:
            assert sha(old(item['path'])) == item['sha256'], 'original historical binding'
        intersections.append({'claim_index': index, 'paths': hits, 'bindings': len(durability['inputs'])})
        frozen['claims'][index]['durability']['mode'] = 'historical'
        frozen['claims'][index]['durability']['revision'] = BASE
    assert row['intersections'] == intersections, 'complete original live intersections'
    if intersections:
        before = PREFIX + 'before-' + Path(path).name
        assert (ROOT / before).read_bytes() == raw, 'exact original full publication'
        assert (ROOT / path).read_bytes() == (json.dumps(frozen, indent=2) + '\n').encode(), 'sole original mode/revision pair'
        selected.append({'path': path, 'before': before, 'sha256': sha(raw), 'bytes': len(raw), 'intersections': intersections})
    else:
        assert (ROOT / path).read_bytes() == raw, 'unrelated original publication unchanged'
assert preservation['selected'] == selected and len(selected) == 1
assert selected[0]['bytes'] == 113730 and selected[0]['intersections'][0]['bindings'] == 490
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Container-target publication PASS: 490 live inputs; 113730 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 225 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
extra_probe = 't/actionir_method_kind_authority_probe.pl'
added = [PROBE, extra_probe, TEST, PREFIX + 'before-native.json', PREFIX + 'before-authority-native.json']
variants = {'before': original_source, 'green': current_source, 'consumers': current_source,
    'inverse-outer': current_source.replace(outer_new, outer_old),
    'inverse-inner': current_source.replace(inner_new, inner_old),
    'outer-late': current_source.replace(outer_new, outer_new.replace(b'$base_bare_symbol_kind', b'$deps->{bare_symbol_kind}')),
    'inner-early': current_source.replace(inner_new, inner_new.replace(b'$bare_symbol_kind', b'$base_bare_symbol_kind')),
    'inner-copy': current_source.replace(inner_new, inner_new.replace(b'->($target_name)', b"->($target_name . '')")),
    'no-first-refusal': current_source.replace(b"  return 'scalar' if _user_function_scalar_value_name($deps, $name);", b'')}
for mode in ('opaque-code', 'direct-noncode', 'list-context'):
    source = current_source
    for name, line in ((b'base_bare_symbol_kind', outer_new), (b'bare_symbol_kind', inner_new)):
        term = b"ref($" + name + b") eq 'CODE' ? $" + name + b" : sub { return $" + name + b"->(@_) }"
        assert line.count(term) == source.count(line) == 1
        replacement = b'$' + name if mode == 'direct-noncode' else b'sub { return $' + name + b'->(@_) }'
        if mode == 'list-context': replacement = b'sub { my @result = $' + name + b'->(@_); return $result[0] }'
        source = source.replace(line, line.replace(term, replacement))
    variants[mode] = source
counts = {'before': 50, 'green': 0, 'inverse-outer': 25, 'inverse-inner': 25,
          'opaque-code': 6, 'direct-noncode': 53, 'outer-late': 41, 'inner-early': 2,
          'inner-copy': 2, 'list-context': 74, 'no-first-refusal': 32}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'229']
    assert [int(row[1]) for row in rows] == list(range(1, 230)), 'complete paired/fault TAP'
    failures = [row[2].decode() for row in rows if row[0]]
    assert len(failures) == expected_count, 'actual distinguishing source failure population'
    assert (record['returncode'] != 0 and failures) if expected_count else (record['returncode'] == 0 and not err)
    return {'labels': [row[2].decode() for row in rows], 'failures': failures,
            'numbers': [int(row[1]) for row in rows if row[0]]}
paired = {}
consumer_groups = []
for mode, source in variants.items():
    record = load(PREFIX + mode + '-final.json')
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'run-final.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    expected = dict(seed['inputs']); expected[MODULE] = sha(source)
    expected.update({path: sha((ROOT / path).read_bytes()) for path in added})
    assert record['inputs'] == expected and len(expected) == 230, 'complete supplied test inputs'
    assert set(record['modes']) == set(expected) and all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
    assert record['modes'] == load(PREFIX + 'green-final.json')['modes']
    assert decode(record['module_base64']) == source, 'exact complete executed source variant'
    assert record['syntax_command'] == ['perl', '-c', '-Iperl', MODULE]
    assert record['syntax']['returncode'] == 0 and not decode(record['syntax']['stdout_base64'])
    assert decode(record['syntax']['stderr_base64']) == (MODULE + ' syntax OK\n').encode()
    if mode != 'consumers':
        assert record['command'] == ['perl', '-Iperl', TEST]
        paired[mode] = tap(record, counts[mode])
        continue
    assert record['command'] == seed['command'] + [TEST] and record['returncode'] == 0
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    assert err == decode(seed['stderr_base64']) and b'All tests successful.' in out and b'Result: PASS' in out
    current, assertions, plans = None, [], []
    for line in out.splitlines():
        header = re.match(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', line)
        if header:
            if current is not None: consumer_groups.append((current, assertions, plans))
            current, assertions, plans = header[1].decode(), [], []
            continue
        if current is None: continue
        assertion = re.match(rb'^(not )?ok (\d+)(?: - (.*))?$', line)
        if assertion:
            assert not assertion[1], 'actual consumer assertion failure'
            assertions.append(int(assertion[2]))
        plan = re.match(rb'^1\.\.(\d+)$', line)
        if plan: plans.append(int(plan[1]))
    if current is not None: consumer_groups.append((current, assertions, plans))
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 71, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [229] and sum(group[2][0] for group in consumer_groups) == 15607
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'71', b'15607')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
assert set(paired['before']['failures']) == set(paired['inverse-outer']['failures']) | set(paired['inverse-inner']['failures'])
assert not set(paired['inverse-outer']['failures']) & set(paired['inverse-inner']['failures'])
first_before, first_green = load(PREFIX + 'before.json'), load(PREFIX + 'green.json')
for record, source in ((first_before, original_source), (first_green, current_source)):
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
    assert record['inputs'][TEST] == sha(first_fixture) and decode(record['module_base64']) == source and record['unchanged']
first_before_tap, first_green_tap = tap(first_before, 44), tap(first_green, 6)
assert first_before_tap['labels'] == first_green_tap['labels']
assert first_green_tap['numbers'] == [84, 86, 121, 123, 175, 177]
assert set(first_before_tap['numbers']) | set(first_green_tap['numbers']) == set(paired['before']['numbers'])
failures = load(PREFIX + 'first-run-failures.json')
assert failures['first_fixture_sha256'] == sha(first_fixture)
assert [row['name'] for row in failures['rows']] == ['green', 'opaque-code', 'direct-noncode']
for row in failures['rows']:
    assert row['actual_outer_returncode'] == 1 and row['separate_outer_channels'] == 'unavailable'
    assert row['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
    assert 'AssertionError' in row['available_merged_outer_channel']
first_consumer = load(PREFIX + 'consumers.json')
assert first_consumer['returncode'] != 0 and first_consumer['inputs'][TEST] == sha(first_fixture)
assert first_consumer['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
assert decode(first_consumer['module_base64']) == current_source and first_consumer['unchanged']
consumer_failure = load(PREFIX + 'first-consumer-failure.json')
assert consumer_failure['actual_outer_returncode'] == 1 and consumer_failure['first_consumer_result_sha256'] == sha((ROOT / (PREFIX + 'consumers.json')).read_bytes())
dependent_rows = []
for tail in ('native-review.py', 'book-review.py'):
    command = ['python3', PREFIX + tail]
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly dependent review', tail, process.stderr)
    dependent_rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
native_review = load(PREFIX + 'native-review.json')
book_review = load(PREFIX + 'book-review.json')
assert native_review['result'] == book_review['result'] == 'PASS'
assert native_review['loaded_rows'] == 91 and native_review['supplemental_rows'] == 36 and native_review['cold_rows'] == 6 and native_review['changed_complete_rows'] == 20
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
if sys.argv[1:] == ['--preflight']:
    print('Method-kind readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9.json',
    'native-review.py', 'native-review.json', 'run.py', 'run-final.py', 'fixture-first.t',
    'first-run-failures.json', 'first-consumer-failure.json', 'before.json', 'green.json', 'consumers.json',
    'inverse-outer.json', 'inverse-inner.json', 'outer-late.json', 'inner-early.json', 'inner-copy.json',
    'list-context.json', 'no-first-refusal.json', 'book.py', 'book.json', 'book-review.py', 'book-review.json',
    'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, extra_probe, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '-final.json' for mode in variants)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 229, 'original_red': 50, 'original_controls': 179,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 71, 'consumer_assertions': 15607, 'consumer_inputs': 230,
    'original_claim_bindings': 490, 'original_claim_bytes': 113730, 'dependent_rows': dependent_rows,
    'scope': 'Only two injected main-method kind invocation boundaries. Full native91+36/cold6 and20 authority changes, original symbolic/blessed dispatch/errors/locations/aliases/timing/early refusal, corrected229 paired assertions50 original RED/179 controls/all GREEN and nine effective full-source variants, all71 ordered supplied suites/230 inputs/15607 assertions, full original490/full113730 publication/baseline and fixed claim namespace, book89/four controls/current routes. First wrong known-parent oracle, actual first44/six failures, first failed consumers and two pre-execution fault-builder failures remain exact. Full predecessor binding list is reused with acceptedBASE provenance rather than duplicated. Supplemental standard1035 retains channels without a full transitive capsule. No authored-language/new-syntax, full-helper/private/parent/canonical or other-backend admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Method-kind review PASS229/50/179; nine source variants; supplied71/230/15607; original490/113730; book89/4')
