"""Readonly composed tracking predicate proof; --capture writes once."""
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
BASE = '99f2939ac1d5e543bc2aa7f9c38b8166d5d510cc'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_tracking_predicate_probe.pl'
TEST = 't/actionir_tracking_predicate_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
constants = {}
for node in ast.parse((ROOT / (PREFIX + 'run-final.py')).read_text()).body:
    if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name) and node.targets[0].id in ('OLD', 'NEW'):
        constants[node.targets[0].id] = ast.literal_eval(node.value)
assert len(constants) == 2
old_line, new_line = constants['OLD'], constants['NEW']
assert old_line == b"return ref($predicate) eq 'CODE' && $predicate->($target) ? 1 : 0"
assert new_line == b"return ref($predicate) eq 'CODE' && _bind_emission_dependency($predicate)->($target) ? 1 : 0"
original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert original_source.count(old_line) == 2
assert current_source == original_source.replace(old_line, new_line), 'only two predicate invocation expressions'
assert current_source.count(b'\n') == original_source.count(b'\n')
owned = {MODULE, 'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/perl-method-ast-call-capture.md', 'docs/knowledge/perl-method-block-component-capture.md', 'docs/knowledge/perl-method-assignment-required-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'}
preservation = load(PREFIX + 'preservation-final.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha((ROOT / (PREFIX + 'preserve-final.py')).read_bytes())
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
assert selected[0]['bytes'] == 119899 and selected[0]['intersections'][0]['bindings'] == 517
baseline_raw = (ROOT / (PREFIX + 'baseline-final.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'AST optional publication PASS: 517 live inputs; 119899 bytes\n', 'actual original publication baseline'

first_failure = load(PREFIX + 'first-preservation-failure.json')
assert first_failure['actual_returncode'] == 1 and first_failure['actual_tool_session'] == 5080
assert first_failure['producer_sha256'] == sha((ROOT / (PREFIX + 'preserve.py')).read_bytes())
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in first_failure['inputs'].items())
assert b'115170' in (ROOT / (PREFIX + 'preserve.py')).read_bytes()
assert b'AssertionError' in decode(first_failure['merged_log_base64'])
first_baseline = load(PREFIX + 'baseline.json')
assert first_baseline['returncode'] == 0 and not decode(first_baseline['stderr_base64'])
assert first_baseline['stdout_base64'] == baseline['stdout_base64']
run_failure = load(PREFIX + 'first-run-failure.json')
assert run_failure['actual_returncode'] == 1 and run_failure['actual_tool_session'] == 81207
assert run_failure['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
assert b'AssertionError' in decode(run_failure['merged_log_base64'])
failed_run = (ROOT / (PREFIX + 'run.py')).read_text()
assert failed_run.count(' ? 1 : 0;"') == 2
assert (ROOT / (PREFIX + 'run-final.py')).read_text() == failed_run.replace(' ? 1 : 0;"', ' ? 1 : 0"'), 'sole first run instrument correction'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 237 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
added = [PROBE, TEST, PREFIX + 'before-native.json']
variants = {'before': original_source, 'green': current_source, 'consumers': current_source}
helpers = {'receiver': '_receiver_mutation_target_is_tracked', 'nested': '_nested_write_target_is_tracked'}
def transform(source, owner, mutation):
    start = source.index(('sub ' + helpers[owner] + ' {').encode())
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    assert body.count(new_line) == 1
    changed = mutation(body)
    assert changed != body
    return source[:start] + changed + source[end:]
for owner in helpers:
    variants['inverse-' + owner] = transform(current_source, owner, lambda body: body.replace(new_line, old_line))
for mode in ('opaque-code', 'copy-target', 'code-guard', 'early-lookup', 'reread-selection', 'list-context', 'raw-return', 'defined-truth'):
    source = current_source
    for owner, role in (('receiver', b'receiver_mutation_target'), ('nested', b'nested_write_target')):
        def mutation(body):
            replacements = {
                'opaque-code': (b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency(sub { return $predicate->(@_) })'),
                'copy-target': (b'->($target)', b"->(($target // '') . '')"),
                'code-guard': (b"ref($predicate) eq 'CODE' && ", b''),
                'reread-selection': (b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency($deps->{' + role + b'})'),
                'list-context': (b'_bind_emission_dependency($predicate)', b'_bind_emission_dependency(sub { my @value = $predicate->(@_); return $value[0] })'),
                'raw-return': (b' ? 1 : 0', b''),
                'defined-truth': (b'_bind_emission_dependency($predicate)->($target)', b'defined(_bind_emission_dependency($predicate)->($target))')}
            if mode == 'early-lookup':
                lines = body.splitlines(keepends=True)
                guard = next(line for line in lines if b'return 0 unless defined($target)' in line)
                selected = next(line for line in lines if b'my $predicate =' in line)
                return body.replace(guard, b'').replace(selected, selected + guard)
            needle, value = replacements[mode]
            assert new_line.count(needle) == 1
            return body.replace(new_line, new_line.replace(needle, value))
        source = transform(source, owner, mutation)
    variants[mode] = source
counts = {'before': 156, 'green': 0, 'inverse-receiver': 78, 'inverse-nested': 78,
    'opaque-code': 72, 'copy-target': 198, 'code-guard': 56, 'early-lookup': 24,
    'reread-selection': 40, 'list-context': 230, 'raw-return': 76, 'defined-truth': 80}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'516']
    assert [int(row[1]) for row in rows] == list(range(1, 517)), 'complete paired/fault TAP'
    failures = [row[2].decode() for row in rows if row[0]]
    assert len(failures) == expected_count, 'actual distinguishing source failure population'
    assert (record['returncode'] != 0 and failures) if expected_count else (record['returncode'] == 0 and not err)
    return {'labels': [row[2].decode() for row in rows], 'failures': failures,
        'numbers': [int(row[1]) for row in rows if row[0]]}
paired = {}
consumer_groups = []
for mode, source in variants.items():
    record = load(PREFIX + mode + '.json')
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'run-final.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    expected = dict(seed['inputs']); expected[MODULE] = sha(source)
    expected.update({path: sha((ROOT / path).read_bytes()) for path in added})
    assert record['inputs'] == expected and len(expected) == 240, 'complete supplied test inputs'
    assert set(record['modes']) == set(expected) and all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
    assert record['modes'] == load(PREFIX + 'green.json')['modes']
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
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 74, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [516] and sum(group[2][0] for group in consumer_groups) == 16681
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'74', b'16681')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
assert set(paired['before']['failures']) == set(paired['inverse-receiver']['failures']) | set(paired['inverse-nested']['failures'])
assert not set(paired['inverse-receiver']['failures']) & set(paired['inverse-nested']['failures'])
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
assert native_review['loaded_rows'] == 280 and native_review['cold_rows'] == 16 and native_review['changed_complete_rows'] == 64
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
if sys.argv[1:] == ['--preflight']:
    print('Tracking predicate readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'first-preservation-failure.json', 'preserve-final.py', 'preservation-final.json',
    'baseline.json', 'baseline-final.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5.json',
    'observe.py', 'observe-recheck.py', 'before-native.json', 'before-reached.json',
    'before-recheck-native.json', 'before-recheck-reached.json', 'after-native.json', 'after-reached.json',
    'native-review.py', 'native-review.json', 'run.py', 'first-run-failure.json', 'run-final.py',
    'book.py', 'book.json', 'book-review.py', 'book-review.json', 'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '.json' for mode in variants)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 516, 'original_red': 156, 'original_controls': 360,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 74, 'consumer_assertions': 16681, 'consumer_inputs': 240,
    'original_claim_bindings': 517, 'original_claim_bytes': 119899, 'dependent_rows': dependent_rows,
    'scope': 'Exactly two predicate invocation expressions, preserving all other source bytes/global lines. Both real validators/single map reads/CODE guards/local target slots/boolean1-or-0 and immediate receiver-guard/scalar-assignment consumers execute without secondary stubs. Actual selected CODE identity and child publication separation are the only native changes:280 loaded/16 cold repeat byte-exactly before assertions/source writes,64 complete authority rows change afterward. Identical516 fixture has156 original authority REDs/360 controls/all GREEN. Ten syntax-valid complete-source faults and all74 ordered supplied suites/240 inputs/16681 full-plan assertions pass. Original517 bindings/full119899 publication and actual readonly baseline remain exact except historical mode/revision at99f2939ac; fixed original claim namespace is recovered without duplicating all old bindings. First preservation byte-substitution and run semicolon-constant guard failures remain exact with distinct corrected producers; no actual runtime observation or fixture expectation is refreshed. Book89/four controls and six current Knowledge routes retained. Supplemental standard Phase01035 has actual channels without a complete transitive capsule. No complete helper/private/parent/canonical or other-backend admission; five original ingress sites .7-.8 and independent obligations remain open.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Tracking predicate review PASS516/156/360; ten source faults; supplied74/240/16681; original517/119899; book89/4')
