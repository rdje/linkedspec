"""Readonly composed optional AST proof; --capture writes once."""
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
BASE = '15197dfdf0f198a4eb25517e278edba491d12db7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_ast_optional_stable_probe.pl'
TEST = 't/actionir_ast_optional_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
constants = {}
for node in ast.parse((ROOT / (PREFIX + 'run.py')).read_text()).body:
    if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name) and node.targets[0].id in ('PIPE_OLD', 'PIPE_NEW', 'ASSIGN_OLD', 'ASSIGN_NEW'):
        constants[node.targets[0].id] = ast.literal_eval(node.value)
assert len(constants) == 4
pipe_old, pipe_new = constants['PIPE_OLD'], constants['PIPE_NEW']
assign_old, assign_new = constants['ASSIGN_OLD'], constants['ASSIGN_NEW']
original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert original_source.count(pipe_old) == original_source.count(assign_old) == 1
assert current_source == original_source.replace(pipe_old, pipe_new).replace(assign_old, assign_new), 'only two optional AST invocation lines'
assert current_source.count(b'\n') == original_source.count(b'\n')
owned = {MODULE, 'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/perl-method-ast-call-capture.md', 'docs/knowledge/perl-method-block-component-capture.md', 'docs/knowledge/perl-method-assignment-required-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
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
assert selected[0]['bytes'] == 114980 and selected[0]['intersections'][0]['bindings'] == 498
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Source-assignment publication PASS: 498 live inputs; 114980 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 233 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
added = ['t/actionir_ast_optional_probe.pl', PROBE, TEST, PREFIX + 'before-stable-native.json']
variants = {'before': original_source, 'green': current_source, 'consumers': current_source,
    'inverse-pipeline': current_source.replace(pipe_new, pipe_old),
    'inverse-assign': current_source.replace(assign_new, assign_old)}
term = b"ref($lower_assign_statement) eq 'CODE' ? $lower_assign_statement : sub { return $lower_assign_statement->(@_) }"
for mode, assignment, pipeline in (
    ('opaque-code', b'sub { return $lower_assign_statement->(@_) }', b'sub { return $lower_array_pipeline_expr->(@_) }'),
    ('direct-noncode', b'$lower_assign_statement', None),
    ('list-context', b'sub { my @result = $lower_assign_statement->(@_); return $result[0] }', b'sub { my @result = $lower_array_pipeline_expr->(@_); return $result[0] }')):
    source = current_source.replace(assign_new, assign_new.replace(term, assignment))
    if pipeline is not None:
        source = source.replace(pipe_new, pipe_new.replace(b'_bind_emission_dependency($lower_array_pipeline_expr)', b'_bind_emission_dependency(' + pipeline + b')'))
    variants[mode] = source
variants['copy-source'] = current_source.replace(pipe_new, pipe_new.replace(b'->($node->{source},', b"->(($node->{source} // '') . '',"))
variants['copy-span'] = current_source.replace(pipe_new, pipe_new.replace(b'$node->{source_span});', b"(ref($node->{source_span}) eq 'HASH' ? {%{$node->{source_span}}} : $node->{source_span}));"))
variants['copy-effective'] = current_source.replace(assign_new, assign_new.replace(b'->($effective_args->[0], $effective_args->[1])', b"->(($effective_args->[0] // '') . '', ($effective_args->[1] // '') . '')"))
start = current_source.index(b'sub _lower_ast_call_statement {')
end = current_source.index(b'\nsub ', start + 1)
body = current_source[start:end]
block = b"  my $lower_assign_statement = (ref($deps) eq 'HASH' && ref($deps->{lower_assign_statement}) eq 'CODE')\n   ? $deps->{lower_assign_statement}\n   : sub { return _lower_assign_statement($_[0], $_[1], $deps) };\n"
anchor = b'  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);'
assert body.count(block) == body.count(anchor) == 1
variants['assign-early'] = current_source[:start] + body.replace(block, b'').replace(anchor, block + anchor) + current_source[end:]
variants['fallback-map'] = current_source[:start] + body.replace(block, block.replace(b'$_[1], $deps)', b'$_[1], {})')) + current_source[end:]
start = current_source.index(b'sub _lower_ast_block_side_effect_statement {')
end = current_source.index(b'\nsub ', start + 1)
body = current_source[start:end]
guard = b"if (ref($lower_array_pipeline_expr) eq 'CODE') {"
assert body.count(guard) == 1
variants['pipeline-guard'] = current_source[:start] + body.replace(guard, b'if (1) {') + current_source[end:]
counts = {'before': 44, 'green': 0, 'inverse-pipeline': 10, 'inverse-assign': 34,
    'opaque-code': 8, 'direct-noncode': 26, 'copy-source': 37, 'copy-span': 35,
    'copy-effective': 47, 'list-context': 82, 'assign-early': 2, 'pipeline-guard': 36, 'fallback-map': 11}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'272']
    assert [int(row[1]) for row in rows] == list(range(1, 273)), 'complete paired/fault TAP'
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
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    expected = dict(seed['inputs']); expected[MODULE] = sha(source)
    expected.update({path: sha((ROOT / path).read_bytes()) for path in added})
    assert record['inputs'] == expected and len(expected) == 237, 'complete supplied test inputs'
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
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 73, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [272] and sum(group[2][0] for group in consumer_groups) == 16165
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'73', b'16165')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
assert set(paired['before']['failures']) == set(paired['inverse-pipeline']['failures']) | set(paired['inverse-assign']['failures'])
assert not set(paired['inverse-pipeline']['failures']) & set(paired['inverse-assign']['failures'])
dependent_rows = []
for tail in ('iterator-review.py', 'native-review.py', 'book-review.py'):
    command = ['python3', PREFIX + tail]
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly dependent review', tail, process.stderr)
    dependent_rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
native_review = load(PREFIX + 'native-review.json')
book_review = load(PREFIX + 'book-review.json')
assert native_review['result'] == book_review['result'] == 'PASS'
assert native_review['loaded_rows'] == 148 and native_review['cold_rows'] == 6 and native_review['changed_complete_rows'] == 16
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
if sys.argv[1:] == ['--preflight']:
    print('AST optional readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4.json',
    'observe.py', 'observe-recheck.py', 'observe-stable.py', 'before-native.json', 'before-reached.json', 'before-recheck-native.json', 'before-recheck-reached.json', 'before-stable-native.json', 'before-stable-reached.json', 'before-recheck-stable-native.json', 'before-recheck-stable-reached.json', 'after-stable-native.json', 'after-stable-reached.json', 'iterator-review.py', 'iterator-review.json',
    'native-review.py', 'native-review.json', 'run.py', 'book.py', 'book.json',
    'book-review.py', 'book-review.json', 'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST, 't/actionir_ast_optional_probe.pl'}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '.json' for mode in variants)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 272, 'original_red': 44, 'original_controls': 228,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 73, 'consumer_assertions': 16165, 'consumer_inputs': 237,
    'original_claim_bindings': 498, 'original_claim_bytes': 114980, 'dependent_rows': dependent_rows,
    'scope': 'Exactly two optional AST invocation boundaries. Pipeline retains its single selected CODE guard/source/span aliases/first nonempty/fallback order; assignment retains required acquisition/normalization/two map reads/actual effective ARRAY aliases/local fallback thunk. Actual CODE identity stays direct; tied-selected symbolic/blessed assignment calls stay opaque and caller-local. Native148 loaded/six cold changes only16 authority rows; exact context/coercion/errors/native2170/global lines/fatal/cold behavior retained. Original unordered234-input probe/observations stay exact; distinct235-input sorted iterator differs only in its two iterator bodies and repeats complete148/six rows/stdout bytes before authored expectations/source edits. Identical272 pair has44 original RED/228 controls/all GREEN. Eleven syntax-valid full-source variants and all73 ordered supplied suites/237 inputs/16165 complete-plan assertions pass. Full original498/full114980 publication and actual baseline remain exact except historical mode/revision at15197dfd; fixed original claim namespace/bindings are recovered from BASE without duplication. Full book89/four controls/six current card routes retained. Supplemental standard1035 has actual channels without a full transitive capsule. Secondary helper controls confer no full-helper/private/parent/canonical or other-backend admission; seven original ingress sites .6-.8 and independent obligations remain owned.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('AST optional review PASS272/44/228; eleven source variants; supplied73/237/16165; original498/114980; book89/4')
