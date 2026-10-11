"""Readonly composed source/assignment kind proof; --capture writes once."""
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
BASE = 'dd82f9cbced8311dca8ea8610282780e0c0adf3e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-consumers-final.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_source_assignment_kind_probe.pl'
TEST = 't/actionir_source_assignment_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
constants = {}
for node in ast.parse((ROOT / (PREFIX + 'run.py')).read_text()).body:
    if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name) and node.targets[0].id in ('READ_OLD', 'READ_NEW', 'ASSIGN_OLD', 'ASSIGN_NEW'):
        constants[node.targets[0].id] = ast.literal_eval(node.value)
assert len(constants) == 4
read_old, read_new = constants['READ_OLD'], constants['READ_NEW']
assign_old, assign_new = constants['ASSIGN_OLD'], constants['ASSIGN_NEW']
original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert original_source.count(read_old) == original_source.count(assign_old) == 1
assert current_source == original_source.replace(read_old, read_new).replace(assign_old, assign_new), 'only two optional kind invocation lines'
assert current_source.count(b'\n') == original_source.count(b'\n')
owned = {MODULE, 'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/perl-method-assignment-required-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
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
assert selected[0]['bytes'] == 125217 and selected[0]['intersections'][0]['bindings'] == 531
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-publish-claim-final.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Method-kind publication PASS: 531 live inputs; 125217 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 230 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
added = [PROBE, TEST, PREFIX + 'before-native.json']
variants = {'before': original_source, 'green': current_source, 'consumers': current_source,
    'inverse-read': current_source.replace(read_new, read_old),
    'inverse-assign': current_source.replace(assign_new, assign_old),
    'read-late': current_source.replace(read_new, read_new.replace(b'$bare_symbol_kind', b"$deps->{bare_symbol_kind}")),
    'copy-name': current_source.replace(read_new, read_new.replace(b'->($name)', b"->($name . '')")).replace(assign_new, assign_new.replace(b'->($target_name)', b"->($target_name . '')"))}
for mode in ('opaque-code', 'direct-noncode', 'list-context'):
    source = current_source
    term = b"ref($bare_symbol_kind) eq 'CODE' ? $bare_symbol_kind : sub { return $bare_symbol_kind->(@_) }"
    replacement = b'$bare_symbol_kind' if mode == 'direct-noncode' else b'sub { return $bare_symbol_kind->(@_) }'
    if mode == 'list-context': replacement = b'sub { my @result = $bare_symbol_kind->(@_); return $result[0] }'
    for line in (read_new, assign_new):
        assert line.count(term) == source.count(line) == 1
        source = source.replace(line, line.replace(term, replacement))
    variants[mode] = source
start = current_source.index(b'sub _lower_assign_statement {')
end = current_source.index(b'\nsub ', start + 1)
body = current_source[start:end]
block = b"  my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')\n   ? $deps->{bare_symbol_kind}\n   : sub { return undef };\n"
anchor = b' my $target_trimmed = $trim_action_ir_value->($target);'
assert body.count(block) == body.count(anchor) == 1
body = body.replace(block, b'').replace(anchor, block + anchor)
variants['assign-early'] = current_source[:start] + body + current_source[end:]
reserved_line = b' return undef if $name =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o;'
assert current_source.count(reserved_line) == 1
variants['remove-read-reserved'] = current_source.replace(reserved_line, b'')
counts = {'before': 56, 'green': 0, 'inverse-read': 28, 'inverse-assign': 28,
    'opaque-code': 8, 'direct-noncode': 52, 'read-late': 37, 'assign-early': 8,
    'copy-name': 6, 'list-context': 75, 'remove-read-reserved': 18}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'286']
    assert [int(row[1]) for row in rows] == list(range(1, 287)), 'complete paired/fault TAP'
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
    assert record['inputs'] == expected and len(expected) == 233, 'complete supplied test inputs'
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
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 72, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [286] and sum(group[2][0] for group in consumer_groups) == 15893
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'72', b'15893')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
assert set(paired['before']['failures']) == set(paired['inverse-read']['failures']) | set(paired['inverse-assign']['failures'])
assert not set(paired['inverse-read']['failures']) & set(paired['inverse-assign']['failures'])
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
assert native_review['loaded_rows'] == 156 and native_review['cold_rows'] == 6 and native_review['changed_complete_rows'] == 20
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
if sys.argv[1:] == ['--preflight']:
    print('Source-assignment readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3.json',
    'observe.py', 'before-native.json', 'before-reached.json', 'after-native.json', 'after-reached.json',
    'native-review.py', 'native-review.json', 'run.py', 'book.py', 'book.json',
    'book-review.py', 'book-review.json', 'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '.json' for mode in variants)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 286, 'original_red': 56, 'original_controls': 230,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 72, 'consumer_assertions': 15893, 'consumer_inputs': 233,
    'original_claim_bindings': 531, 'original_claim_bytes': 125217, 'dependent_rows': dependent_rows,
    'scope': 'Exactly two source-slot read/assignment optional kind invocation boundaries. Native156 loaded/six cold and20 complete authority-row changes only; full local aliases/mutations/context/coercion/errors/native6883/7156/global lines, optional defaults/tied symbolic dispatch, different lookup timing/reserved/migration/target guards and known CODE eligibility without child packet donation are preserved. First native ledgers precede assertions/source edits and are never refreshed; identical286 pair has56 original RED/230 controls/all GREEN, nine syntax-valid full-source variants and all72 ordered supplied suites/233 inputs/15893 complete-plan assertions pass. Full original531/full125217 publication and actual readonly baseline are retained before bound writes; all original bindings are recoverable from acceptedBASE via the unchanged full original input list, not duplicated. Full fixed original claim population, book89/four controls/current four card routes retained. No fixture/instrument correction or first observation refresh. Supplemental standard1035 retains actual channels without a full transitive capsule. No new authored-language failure/syntax, full-helper/private/parent/canonical or other-backend admission; nine ingress sites .5-.8 and independent obligations remain owned.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Source-assignment review PASS286/56/230; nine source variants; supplied72/233/15893; original531/125217; book89/4')
