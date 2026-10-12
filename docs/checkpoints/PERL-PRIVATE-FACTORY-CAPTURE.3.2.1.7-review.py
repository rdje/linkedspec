"""Readonly composed formal trim proof; --capture writes once."""
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
BASE = 'b1133da422bbf19b54818c97c2b67a5e6a402012'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_formal_trim_probe.pl'
TEST = 't/actionir_formal_trim_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
ARGUMENT = b"ref($trim_action_ir_value) eq 'CODE' ? $trim_action_ir_value : sub { return $trim_action_ir_value->(@_) }"
BOUND = b'_bind_emission_dependency(' + ARGUMENT + b')'
OLD_FIRST = b'my $trimmed = $trim_action_ir_value->($expr);'
OLD_RECEIVER = b'my $receiver = $trim_action_ir_value->(substr($trimmed, 0, $idx));'
OLD_CALL = b'my $call_expr = $trim_action_ir_value->(substr($trimmed, $idx + 1));'
OLD = {'brace-first': OLD_FIRST, 'dot-first': OLD_FIRST, 'dot-receiver': OLD_RECEIVER, 'dot-call': OLD_CALL}
NEW = {site: line.replace(b'$trim_action_ir_value->(', BOUND + b'->(', 1) for site, line in OLD.items()}
HELPERS = {'brace': '_extract_outer_brace_payload', 'dot': '_split_receiver_dot_method_expr'}
SITES = {'brace': ('brace-first',), 'dot': ('dot-first', 'dot-receiver', 'dot-call')}
VARIANTS = tuple('inverse-' + site for site in OLD) + ('opaque-code', 'direct-noncode', 'copy-expr', 'copy-receiver', 'copy-call', 'list-context', 'early-receiver-guard', 'brace-depth', 'dot-quote', 'dot-decimal')
def edit_helper(source, owner, change):
    start = source.index(('sub ' + HELPERS[owner] + ' {').encode())
    end = source.index(b'\nsub ', start + 1)
    body = source[start:end]
    changed = change(body)
    assert changed != body
    return source[:start] + changed + source[end:]

def accepted_source(original):
    source = original
    for owner, sites in SITES.items():
        def bind(body):
            for site in sites:
                assert body.count(OLD[site]) == 1 and body.count(NEW[site]) == 0
                body = body.replace(OLD[site], NEW[site])
            return body
        source = edit_helper(source, owner, bind)
    assert source.count(b'\n') == original.count(b'\n')
    return source

def variant(original, mode):
    if mode == 'before':
        return original
    source = accepted_source(original)
    if mode in ('green', 'consumers'):
        return source
    if mode.startswith('inverse-'):
        site = mode.removeprefix('inverse-')
        return edit_helper(source, site.split('-')[0], lambda body: body.replace(NEW[site], OLD[site]))
    owners = ('brace',) if mode == 'brace-depth' else ('dot',) if mode in ('copy-receiver', 'copy-call', 'early-receiver-guard', 'dot-quote', 'dot-decimal') else tuple(HELPERS)
    for owner in owners:
        def change(body):
            if mode == 'early-receiver-guard':
                guard = b'  return undef unless defined($receiver) && length($receiver);\n'
                anchor = b'  ' + NEW['dot-receiver'] + b'\n'
                assert body.count(guard) == body.count(anchor) == 1
                return body.replace(guard, b'').replace(anchor, anchor + guard)
            if mode == 'brace-depth':
                assert body.count(b'++$depth;') == 1
                return body.replace(b'++$depth;', b'$depth = 1;')
            if mode == 'dot-quote':
                needle = b"if ($ch eq \"'\") { $in_single_quote = 1; next; }"
                assert body.count(needle) == 1
                return body.replace(needle, needle.replace(b'= 1;', b'= 0;'))
            if mode == 'dot-decimal':
                needle = b'next if $prev_ch =~ /\\d/o && $next_ch =~ /\\d/o;'
                assert body.count(needle) == 1
                return body.replace(needle, needle.replace(b'next if ', b'next if 0 && '))
            for site in SITES[owner]:
                line = NEW[site]
                if mode in ('opaque-code', 'direct-noncode', 'list-context'):
                    term = b'$trim_action_ir_value' if mode == 'direct-noncode' else b'sub { return $trim_action_ir_value->(@_) }'
                    if mode == 'list-context':
                        term = b'sub { my @values = $trim_action_ir_value->(@_); return $values[0] }'
                    line = line.replace(ARGUMENT, term)
                elif mode == 'copy-expr' and site.endswith('-first'):
                    line = line.replace(b'->($expr)', b"->(($expr // '') . '')")
                elif mode == 'copy-receiver' and site == 'dot-receiver':
                    line = line.replace(b'->(substr($trimmed, 0, $idx))', b"->(('' . substr($trimmed, 0, $idx)))")
                elif mode == 'copy-call' and site == 'dot-call':
                    line = line.replace(b'->(substr($trimmed, $idx + 1))', b"->(('' . substr($trimmed, $idx + 1)))")
                if line != NEW[site]:
                    assert body.count(NEW[site]) == 1
                    body = body.replace(NEW[site], line)
            return body
        source = edit_helper(source, owner, change)
    return source

original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert current_source == accepted_source(original_source), 'only four scoped formal trim invocation expressions'
assert current_source.count(b'\n') == original_source.count(b'\n')
assert OLD_FIRST == b'my $trimmed = $trim_action_ir_value->($expr);'
assert OLD_RECEIVER == b'my $receiver = $trim_action_ir_value->(substr($trimmed, 0, $idx));'
assert OLD_CALL == b'my $call_expr = $trim_action_ir_value->(substr($trimmed, $idx + 1));'
assert ARGUMENT == b"ref($trim_action_ir_value) eq 'CODE' ? $trim_action_ir_value : sub { return $trim_action_ir_value->(@_) }"
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
assert selected[0]['bytes'] == 119936 and selected[0]['intersections'][0]['bindings'] == 519
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Tracking predicate publication PASS: 519 live inputs; 119936 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 240 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path != MODULE:
        assert sha((ROOT / path).read_bytes()) == digest, 'unrelated accepted runtime input'
added = [PROBE, TEST, PREFIX + 'before-native.json']
variants = {mode: variant(original_source, mode) for mode in ('before', 'green', 'consumers') + VARIANTS}
counts = {'before': 144, 'green': 0, 'inverse-brace-first': 36, 'inverse-dot-first': 80,
    'inverse-dot-receiver': 78, 'inverse-dot-call': 76, 'opaque-code': 24, 'direct-noncode': 86,
    'copy-expr': 232, 'copy-receiver': 12, 'copy-call': 9, 'list-context': 250,
    'early-receiver-guard': 7, 'brace-depth': 3, 'dot-quote': 3, 'dot-decimal': 2}
def tap(record, expected_count):
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'507']
    assert [int(row[1]) for row in rows] == list(range(1, 508)), 'complete paired/fault TAP'
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
    assert record['inputs'] == expected and len(expected) == 243, 'complete supplied test inputs'
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
    assert [group[0] for group in consumer_groups] == record['command'][3:] and len(consumer_groups) == 75, 'complete actual consumer header population'
    for path, assertions, plans in consumer_groups:
        assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
    assert consumer_groups[-1][2] == [507] and sum(group[2][0] for group in consumer_groups) == 17188
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'75', b'17188')]
assert all(value['labels'] == paired['green']['labels'] for value in paired.values())
inverse_sets = {mode: set(paired[mode]['failures']) for mode in VARIANTS if mode.startswith('inverse-')}
assert set(paired['before']['failures']) == set.union(*inverse_sets.values()), 'complete four-inverse authority coverage'
assert not inverse_sets['inverse-brace-first'] & set.union(*(value for key, value in inverse_sets.items() if key != 'inverse-brace-first'))
# Dot call sites share whole-row assertions; retain rather than hide their overlap.
inverse_overlap = {a + ' / ' + b: len(inverse_sets[a] & inverse_sets[b]) for a in inverse_sets for b in inverse_sets if a < b}
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
assert native_review['loaded_rows'] == 230 and native_review['cold_rows'] == 68 and native_review['changed_complete_rows'] == 52
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
if sys.argv[1:] == ['--preflight']:
    print('Formal trim readonly preflight PASS; standard compatibility remains required before report capture')
    sys.exit(0)
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6.json', 'before-outer-completion.json',
    'observe.py', 'observe-recheck.py', 'before-native.json', 'before-reached.json',
    'before-recheck-native.json', 'before-recheck-reached.json', 'after-native.json', 'after-reached.json',
    'native-review.py', 'native-review.json', 'run.py',
    'book.py', 'book.json', 'book-review.py', 'book-review.json', 'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(PREFIX + mode + '.json' for mode in variants)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'paired_assertions': 507, 'original_red': 144, 'original_controls': 363,
    'fault_failures': {mode: counts[mode] for mode in counts if mode not in ('before', 'green')},
    'inverse_overlap': inverse_overlap,
    'consumer_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in consumer_groups],
    'consumer_suites': 75, 'consumer_assertions': 17188, 'consumer_inputs': 243,
    'original_claim_bindings': 519, 'original_claim_bytes': 119936, 'dependent_rows': dependent_rows,
    'scope': 'Exactly four formal trim invocation expressions, retaining all other source bytes/global lines. Real brace/dot native helpers execute without stubs. Complete230 loaded/68 cold rows repeat byte-exactly before assertions/source writes; only20 actual-CODE and32 symbolic authority rows change. Writable local expression and shared substr lvalues, callback snapshot, scalar context, guards, quotes/nesting/decimal scan, native callable/error/fatal behavior, reference identity, lazy cold loading and already-bound nesting remain exact. Identical507 fixture has144 original authority REDs/363 controls/all GREEN. Fourteen complete-source syntax-valid faults and all75 ordered supplied suites/243 inputs/17188 full-plan assertions pass. Original519 bindings/full119936 publication and actual baseline remain exact except historical mode/revision atb1133da42. First outer native completion is retained; no fixture/oracle/producer correction occurred. Provisional task source-position transcription was corrected from actual source before assertions. Book89/four controls and six current Knowledge routes retained. Supplemental standard Phase01035 has actual channels without complete transitive capsule. No complete helper/private/parent/canonical or other-backend admission; one named-helper ingress .8 and independent obligations remain open.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Formal trim review PASS507/144/363; fourteen source faults; supplied75/243/17188; original519/119936; book89/4')
