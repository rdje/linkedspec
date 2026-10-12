"""Readonly composed named dispatch proof; --capture writes once."""
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
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_named_dispatch_probe.pl'
TEST = 't/actionir_named_dispatch_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
OLD = b'my $lowered = $lowerer->($trimmed, $deps);'
NEW = b'my $lowered = _bind_emission_dependency($lowerer)->($trimmed, $deps);'
HELPER = b'sub _lower_block_side_effect_statement {'
NAMES = (
 b'_lower_scalar_assignment_operator_statement',
 b'_lower_array_append_operator_statement',
 b'_lower_array_end_mutation_method_statement',
 b'_lower_hash_index_assignment_operator_statement',
 b'_lower_set_key_statement',
 b'_lower_push_statement',
)
VARIANTS = ('inverse', 'opaque-code', 'copy-trimmed', 'copy-deps', 'list-context',
    'boolean-result', 'defined-result', 'reverse-order', 'late-name-resolution',
    'ast-guard', 'return-guard', 'set-fallback')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

def edit_helper(source, change):
    start = source.index(HELPER)
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    changed = change(body)
    assert changed != body
    return source[:start] + changed + source[end:]

def accepted_source(original):
    def bind(body):
        assert body.count(OLD) == 1 and NEW not in body
        return body.replace(OLD, NEW)
    source = edit_helper(original, bind)
    assert source.count(b'\n') == original.count(b'\n')
    return source

def variant(original, mode):
    if mode == 'before':
        return original
    source = accepted_source(original)
    if mode in ('green', 'consumers'):
        return source
    def change(body):
        if mode == 'inverse':
            return body.replace(NEW, OLD)
        replacements = {
            'opaque-code': (b'_bind_emission_dependency($lowerer)', b'_bind_emission_dependency(sub { return $lowerer->(@_) })'),
            'copy-trimmed': (b'->($trimmed, $deps)', b"->(($trimmed // '') . '', $deps)"),
            'copy-deps': (b'->($trimmed, $deps)', b'->($trimmed, {%$deps})'),
            'list-context': (b'_bind_emission_dependency($lowerer)', b'_bind_emission_dependency(sub { my @values = $lowerer->(@_); return $values[0] })'),
        }
        if mode in replacements:
            needle, value = replacements[mode]
            assert NEW.count(needle) == 1
            return body.replace(NEW, NEW.replace(needle, value))
        guard = b'return $lowered if defined($lowered) && length($lowered);'
        if mode in ('boolean-result', 'defined-result'):
            assert body.count(guard) == 2
            value = b'return $lowered if $lowered;' if mode == 'boolean-result' else b'return $lowered if defined($lowered);'
            return body.replace(guard, value, 1)
        if mode == 'reverse-order':
            lines = b''.join(b'  \\&' + name + b',\n' for name in NAMES)
            assert body.count(lines) == 1
            return body.replace(lines, b''.join(b'  \\&' + name + b',\n' for name in reversed(NAMES)))
        if mode == 'late-name-resolution':
            for name in NAMES:
                needle = b'\\&' + name + b','
                assert body.count(needle) == 1
                body = body.replace(needle, b'sub { return ' + name + b'(@_) },')
            return body
        if mode == 'ast-guard':
            needle = b'return $ast_assign_lowered if defined($ast_assign_lowered) && length($ast_assign_lowered);'
            assert body.count(needle) == 1
            return body.replace(needle, b'')
        if mode == 'return-guard':
            needle = b"return undef if $call && ($call->{method} // '') eq 'return';"
            assert body.count(needle) == 1
            return body.replace(needle, b'')
        if mode == 'set-fallback':
            needle = b"if ($call && (($call->{method} // '') eq 'set') && $trimmed =~ /^\\s*set\\s*\\(/o)"
            assert body.count(needle) == 1
            return body.replace(needle, needle.replace(b'if (', b'if (0 && ', 1))
        raise AssertionError('unknown source fault')
    return edit_helper(source, change)

original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert OLD == b'my $lowered = $lowerer->($trimmed, $deps);'
assert NEW == b'my $lowered = _bind_emission_dependency($lowerer)->($trimmed, $deps);'
assert current_source == accepted_source(original_source), 'only one selected named-helper invocation expression'
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
assert selected[0]['bytes'] == 120245 and selected[0]['intersections'][0]['bindings'] == 522
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Formal trim publication PASS: 522 live inputs; 120245 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 243 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
added = [PROBE, TEST, PREFIX + 'before-native.json']
variants = {mode: variant(original_source, mode) for mode in ('before', 'green', 'consumers') + VARIANTS}
counts = {'before': 132, 'green': 0, 'inverse': 132, 'opaque-code': 60,
    'copy-trimmed': 203, 'copy-deps': 205, 'list-context': 238, 'boolean-result': 12,
    'defined-result': 41, 'reverse-order': 264, 'late-name-resolution': 228,
    'ast-guard': 7, 'return-guard': 3, 'set-fallback': 6}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'487']
    assert [int(row[1]) for row in rows] == list(range(1, 488)), 'complete paired/fault TAP'
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
    assert record['inputs'] == expected and len(expected) == 246, 'complete supplied test inputs'
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
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 76, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [487] and sum(group[2][0] for group in consumer_groups) == 17675
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'76', b'17675')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
assert paired['before']['failures'] == paired['inverse']['failures'], 'exact complete original authority failures restored by sole inverse'
assert paired['before']['numbers'] == paired['inverse']['numbers']
dependent_rows = []
for tail in ('native-review.py', 'book-review.py', 'headers-review.py'):
    command = ['python3', PREFIX + tail]
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly dependent review', tail, process.stderr)
    dependent_rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
native_review = load(PREFIX + 'native-review.json')
book_review = load(PREFIX + 'book-review.json')
assert native_review['result'] == book_review['result'] == 'PASS'
assert native_review['loaded_rows'] == 185 and native_review['cold_rows'] == 28 and native_review['changed_complete_rows'] == 54
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
headers_review = load(PREFIX + 'headers-review.json')
assert headers_review['cards'] == 6 and headers_review['original_orphans'] == 4 and headers_review['current_orphans'] == 0
header_red = load(PREFIX + 'headers-before.json')
assert header_red['producer_sha256'] == sha((ROOT / (PREFIX + 'headers-before.py')).read_bytes())
assert header_red['command'] == ['python3', PREFIX + 'headers-review.py', '--preflight']
assert header_red['returncode'] != 0 and b'current Knowledge header has orphan list entries' in decode(header_red['stderr_base64'])
assert not decode(header_red['stdout_base64'])
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in header_red['inputs'].items())
completion = load(PREFIX + 'outer-completions.json')
assert [(row['name'], row['actual_tool_session'], row['actual_returncode']) for row in completion['rows']] == [('after-native', 98898, 0), ('faults', 82991, 0), ('consumers', 6662, 0)]
expected_logs = [
    b'Named-dispatch after native commands retained: 244 inputs; 2 fresh processes\n',
    ''.join('Named-dispatch ' + mode + ' complete TAP: 487 assertions; ' + str(counts[mode]) + ' RED\n' for mode in VARIANTS).encode(),
    b'Named-dispatch supplied consumers PASS: 76 suites; 246 inputs\n']
assert [decode(row['merged_log_base64']) for row in completion['rows']] == expected_logs
if sys.argv[1:] == ['--preflight']:
    print('Named dispatch readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7.json', 'before-outer-completion.json',
    'observe.py', 'observe-recheck.py', 'before-native.json', 'before-reached.json',
    'before-recheck-native.json', 'before-recheck-reached.json', 'after-native.json', 'after-reached.json',
    'native-review.py', 'native-review.json', 'run.py',
    'book.py', 'book.json', 'book-review.py', 'book-review.json', 'compat.py', 'compat.json', 'review.py',
    'headers.py', 'headers-census.json', 'headers-review.py', 'headers-review.json', 'headers-before.py', 'headers-before.json', 'outer-completions.json')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '.json' for mode in variants)
paths.update(native_review['inputs'])
paths.update(headers_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 487, 'original_red': 132, 'original_controls': 355,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 76, 'consumer_assertions': 17675, 'consumer_inputs': 246,
    'original_claim_bindings': 522, 'original_claim_bytes': 120245, 'dependent_rows': dependent_rows,
    'header_cards': 6, 'original_header_orphans': 4, 'current_header_orphans': 0,
    'scope': 'Exactly one selected named-helper invocation expression, retaining all other source bytes/global lines. Real owner body executes with six explicit localized actual CODE callbacks and controlled secondary AST/assignment/component helpers. Complete185 loaded/28 cold rows repeat byte-exactly before assertions/source writes; only54 authority rows change. Six-reference snapshot/order, actual selected identity, writable local trimmed/deps arguments, caller copies/shared maps/local reference replacement, first defined nonempty/zero/reference result, scalar context, guard/fallback/coercion/error/fatal/localization/cold remain native. Identical487 fixture has132 original authority REDs/355 controls/all GREEN. Twelve complete-source syntax-valid faults, exact inverse132 failure population and all76 ordered supplied suites/246 inputs/17675 full-plan assertions pass. Original522 bindings/full120245 publication and actual baseline remain exact except historical mode/revision at22132b2b. All first outer native/after/fault/consumer actual0 completions/logs are retained. No diagnostic/oracle/producer correction or observation refresh occurred. Six-card original header census/four-orphan actual RED and corrected scalar routing preserve every old fact body and historical route; ambiguous iterator routing names its actual .5 accepted inputs. Transient JS orchestration quoting failed before any nested command executed and changed no artifact. Canonical Knowledge gate hardening .11 remains owned before FlowExpr. Book89/four controls and six current Knowledge routes retained. Supplemental standard Phase01035 has actual channels without complete transitive capsule. No complete named-helper/private/parent/canonical or other-backend admission; all17 original inventory sites have bounded repairs, while independent owners remain open.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Named dispatch review PASS487/132/355; twelve source faults; supplied76/246/17675; original522/120245; book89/4; headers6/4 repaired')
