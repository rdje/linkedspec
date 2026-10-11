"""Readonly composed container-target review; --capture writes its first report."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
LEGACY = 't/actionir_small_kind_capture.t'
PROBE = 't/actionir_uniform_target_probe.pl'
TEST = 't/actionir_uniform_target.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
load = lambda p: json.loads((ROOT / p).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'])
old_line = rb'return undef unless $target_expr =~ /^\Q$container\E\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;'
new_line = old_line.replace(b'$/o;', b'$/;')
original_source = old(MODULE)
current_source = (ROOT / MODULE).read_bytes()
assert original_source.count(old_line) == 1 and current_source == original_source.replace(old_line, new_line), 'sole current-container source correction'
original_fixture = old(LEGACY)
expected_fixture = original_fixture.replace(b'bare-name spaced-name container-empty);', b'bare-name spaced-name);')
before_assertion = b'  is_deeply($row, $native->{$group}[$index], "$label complete native observation");'
after_assertion = b'''  my $expected_native = $native->{$group}[$index];
  if ($row->{name} eq 'target/container-empty') {
   # PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9: current empty container rejects before lookup.
   $expected_native = {%$expected_native, eligible => [], events => [], trace => [],
    success_error => 'incoming small kind', value => undef};
  }
  is_deeply($row, $expected_native, "$label complete native observation");'''
assert original_fixture.count(before_assertion) == 1
expected_fixture = expected_fixture.replace(before_assertion, after_assertion)
assert (ROOT / LEGACY).read_bytes() == expected_fixture, 'sole authored legacy fixture migration'

owned = {MODULE, LEGACY, 'docs/knowledge/perl-legacy-hash-kind-callback.md',
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
assert selected[0]['bytes'] == 97759 and selected[0]['intersections'][0]['bindings'] == 422
baseline_raw = (ROOT / (PREFIX + 'baseline.json')).read_bytes()
assert preservation['baseline_sha256'] == sha(baseline_raw)
baseline = json.loads(baseline_raw)
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-publish-claim.py']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Fixed claim census publication PASS: 422 live inputs; 97759 bytes\n', 'actual original publication baseline'

seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 223 and seed['returncode'] == 0 and seed['unchanged']
assert (ROOT / SEED).read_bytes() == seed_raw
for path, digest in seed['inputs'].items():
    assert sha(old(path)) == digest
    if path not in (MODULE, LEGACY): assert sha((ROOT / path).read_bytes()) == digest, 'unrelated runtime/consumer input unchanged'
variants = {'before': original_source, 'green': current_source, 'consumers': current_source,
    'inverse': current_source.replace(new_line, old_line),
    'unquoted': current_source.replace(new_line, new_line.replace(rb'\Q$container\E', b'$container')),
    'hardcoded': current_source.replace(new_line, new_line.replace(b'$container', b'array'))}
paired = {}
consumer_groups = []
for mode, source in variants.items():
    record = load(PREFIX + mode + '.json')
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'run.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    expected = dict(seed['inputs'])
    expected[MODULE] = sha(source)
    expected[LEGACY] = sha(original_fixture if mode == 'before' else expected_fixture)
    expected.update({p: sha((ROOT / p).read_bytes()) for p in (PROBE, TEST)})
    assert record['inputs'] == expected and len(expected) == 225, 'complete supplied test inputs'
    assert set(record['modes']) == set(expected) and all(m in (0o640, 0o644, 0o750, 0o755) for m in record['modes'].values())
    assert decode(record['module_base64']) == source, 'exact complete executed source variant'
    assert decode(record['legacy_fixture_base64']) == (original_fixture if mode == 'before' else expected_fixture)
    assert record['syntax_command'] == ['perl', '-c', '-Iperl', MODULE]
    assert record['syntax']['returncode'] == 0 and not decode(record['syntax']['stdout_base64'])
    assert decode(record['syntax']['stderr_base64']) == (MODULE + ' syntax OK\n').encode(), 'actual full-source syntax command'
    out, err = decode(record['stdout_base64']), decode(record['stderr_base64'])
    if mode != 'consumers':
        assert record['command'] == ['perl', '-Iperl', TEST]
        rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
        plans = re.findall(rb'^1\.\.(\d+)$', out, re.M)
        assert plans == [b'285'] and [int(r[1]) for r in rows] == list(range(1, 286)), 'complete paired/fault TAP'
        failures = [r[2].decode() for r in rows if r[0]]
        expected_count = {'before': 98, 'green': 0, 'inverse': 98, 'unquoted': 8, 'hardcoded': 67}[mode]
        assert len(failures) == expected_count, 'actual distinguishing source failure population'
        assert (record['returncode'] != 0 and failures) if expected_count else (record['returncode'] == 0 and not err)
        paired[mode] = {'labels': [r[2].decode() for r in rows], 'failures': failures}
    else:
        assert record['command'] == seed['command'] + [TEST], 'complete original69 plus new suite command'
        assert record['returncode'] == 0 and err == decode(seed['stderr_base64'])
        assert b'All tests successful.' in out and b'Result: PASS' in out
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
        assert [g[0] for g in consumer_groups] == record['command'][3:] and len(consumer_groups) == 70, 'complete actual consumer header population'
        for path, assertions, plans in consumer_groups:
            assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual consumer numeric plan', path)
        assert consumer_groups[-1][2] == [285] and sum(g[2][0] for g in consumer_groups) == 15378
        assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'70', b'15378')]
assert all(p['labels'] == paired['green']['labels'] for p in paired.values()), 'identical complete paired/fault assertion population'
assert paired['before']['failures'] == paired['inverse']['failures'], 'exact original source inverse RED set'
assert all(re.match(r'^(array|hash) ', name) for name in paired['before']['failures']), 'public controls unaffected by original defect'

first_failure = load(PREFIX + 'first-native-review-failure.json')
assert first_failure['returncode'] == 1 and first_failure['separate_outer_channels'] == 'unavailable'
assert first_failure['producer_sha256'] == sha((ROOT / (PREFIX + 'native-review.py')).read_bytes())
assert b"all(m in (0o644, 0o755)" in decode(first_failure['merged_log_base64']), 'actual first reviewer mode rejection'
dependent_rows = []
for tail in ('native-review-final.py', 'book-review.py'):
    command = ['python3', PREFIX + tail]
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly dependent review', tail, process.stderr)
    dependent_rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
native_review = load(PREFIX + 'native-review-final.json')
book_review = load(PREFIX + 'book-review.json')
assert native_review['result'] == book_review['result'] == 'PASS'
assert native_review['native_rows'] == 40 and native_review['changed_native_rows'] == 26
assert book_review['source_count'] == 89 and book_review['actual_controls'] == 4
cards = sorted(p for p in owned if p.startswith('docs/knowledge/'))
for path in cards:
    head, body = (ROOT / path).read_bytes().split(b'\n---\n', 1)
    original_body = old(path).split(b'\n---\n', 1)[1]
    assert body.startswith(original_body), 'original Knowledge fact body retained'
    assert (PREFIX + 'publish-claim.py').encode() in head
    assert b'native-review-final.py' in head and b'book-review.py' in head and b'evidence.py' in head, 'current readonly helper routing'
compat = load(PREFIX + 'compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert [r['command'] for r in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(r['returncode'] == 0 for r in compat['rows'])
standard_out = decode(compat['rows'][2]['stdout_base64'])
assert b'Result: PASS' in standard_out and re.findall(rb'^Files=(\d+), Tests=(\d+),', standard_out, re.M) == [(b'1', b'1035')], 'actual supplemental standard Phase0 reach'
proofs = ('preserve.py', 'preservation.json', 'baseline.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10.json',
    'observe.py', 'before-observations.json', 'before-reached.json', 'after-observations.json', 'after-reached.json',
    'legacy.py', 'legacy.json', 'legacy-reached.json', 'native-review.py', 'first-native-review-failure.json',
    'native-review-final.py', 'native-review-final.json', 'run.py', 'before.json', 'green.json', 'inverse.json',
    'unquoted.json', 'hardcoded.json', 'consumers.json', 'book.py', 'book.json', 'book-review.py', 'book-review.json',
    'compat.py', 'compat.json', 'review.py')
paths = set(seed['inputs']) | set(book_review['source_inputs']) | set(claim_paths) | set(cards) | {SEED, PROBE, TEST}
paths.update(PREFIX + tail for tail in proofs)
paths.update(native_review['inputs'])
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'input_metadata': {p: sha((ROOT / p).read_bytes()) for p in sorted(paths)},
    'paired_assertions': 285, 'original_red': 98, 'original_controls': 187,
    'fault_failures': {m: len(paired[m]['failures']) for m in ('inverse', 'unquoted', 'hardcoded')},
    'consumer_plans': [{'path': p, 'assertions': plans[0]} for p, _, plans in consumer_groups],
    'consumer_suites': 70, 'consumer_assertions': 15378, 'consumer_inputs': 225,
    'original_claim_bindings': 422, 'original_claim_bytes': 97759, 'dependent_rows': dependent_rows,
    'scope': 'Sole current-container regex /o removal and one exact five-field legacy fixture migration. Native/public/legacy proofs, identical285 paired TAP98 original RED/187 controls/all GREEN, three syntax-valid full-source faults98/8/67, every ordered70-suite225-input15378 plan, original422/full97759 publication and actual baseline, full book89/four controls/current routes pass. Full original predecessor binding list is retained in its reused complete publication and recoverable atBASE; no observation or producer refreshed. Supplemental standard commands retain channels without a full transitive capsule. No authored-language failure, new syntax, full-helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current readonly composed report'
print('Container-target review PASS285/98/187; faults98/8/67; supplied70/225/15378; original422/97759; book89/4')
