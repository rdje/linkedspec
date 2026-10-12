"""Readonly independent full-population FlowExpr review; --capture writes once."""
import base64
import copy
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '81b356cef997ea2bb65a8fb120c77506fed9241e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
MODULE = 'perl/LinkedSpec/ActionIR/FlowExpr.pm'
NATIVE = 't/actionir_flow_required_native.pl'
FIXTURE = 't/actionir_flow_required_capture.t'
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
read = lambda path: (ROOT / path).read_bytes()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
inputs = {}

def retain(path):
    raw = read(path)
    inputs[path] = {'sha256': sha(raw), 'mode': (ROOT / path).stat().st_mode & 0o7777}
    return raw

def load(tail):
    raw = retain(PREFIX + tail)
    return json.loads(gzip.decompress(raw) if tail.endswith('.gz') else raw)

def capsule(tail, metadata, current=False):
    data = load(tail)
    expected = {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in data.items()}
    assert metadata == expected, ('complete capsule membership/modes', tail)
    for p, item in data.items():
        raw = decode(item['bytes_base64'])
        assert sha(raw) == item['sha256'], ('recoverable input bytes', p)
        assert item['mode'] in (0o640, 0o644, 0o750, 0o755), ('actual supplied mode', p)
        if current:
            assert retain(p) == raw and inputs[p]['mode'] == item['mode'], ('current supplied input', p)
    return data

def tap(channel, expected_failures):
    out, err = decode(channel['stdout_base64']), decode(channel['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+) - (.*)$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'1795'], 'complete paired/fault plan'
    assert [int(row[1]) for row in rows] == list(range(1, 1796)), 'complete paired/fault assertions'
    failures = [{'number': int(number), 'name': name.decode()} for no, number, name in rows if no]
    assert len(failures) == expected_failures, 'actual distinguishing semantic failure population'
    assert not re.search(rb'^Bail out!|^Dubious', out, re.M)
    if expected_failures:
        assert channel['returncode'] != 0 and b'Failed test' in err
    else:
        assert channel['returncode'] == 0 and not err
    return failures, [name.decode() for _, _, name in rows]

# Fixed accepted claim namespace, complete original record and every original binding.
preservation = load('preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha(retain(PREFIX + 'preserve.py'))
namespace = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
assert [row['path'] for row in preservation['census']] == sorted(namespace), 'fixed original claim namespace'
selected = []
for row in preservation['census']:
    raw = old(row['path'])
    assert sha(raw) == row['sha256']
    record, intersections = json.loads(raw), []
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        hits = sorted(set(preservation['owned_bound_paths']) & {item['path'] for item in durability['inputs']})
        if hits:
            for item in durability['inputs']:
                assert sha(old(item['path'])) == item['sha256'], 'complete original accepted binding recoverability'
            intersections.append({'claim_index': index, 'paths': hits, 'bindings': len(durability['inputs'])})
    assert row['intersections'] == intersections
    if intersections:
        selected.append(row['path'])
assert selected == ['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json']
prior = preservation['selected'][0]
original_claim = load('before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json')
assert retain(prior['before']) == old(prior['path']), 'complete original publication bytes'
assert prior['bytes'] == 58582 and prior['sha256'] == sha(read(prior['before']))
assert sum(row['bindings'] for row in prior['intersections']) == 218
historical = copy.deepcopy(original_claim)
for row in prior['intersections']:
    historical['claims'][row['claim_index']]['durability'].update(mode='historical', revision=BASE)
assert json.loads(retain(prior['path'])) == historical, 'only historical durability mode/revision changed'
baseline = load('baseline.json')
assert preservation['baseline_sha256'] == sha(read(PREFIX + 'baseline.json'))
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Parent-owned Knowledge/documentation publication PASS: 218 live inputs; 58582 bytes\n'

# Native facts are joined at every row, argument, value, context, map, effect and error.
native = {}
for stage, producer in [('before', 'observe.py'), ('after', 'observe-after.py')]:
    record = load(stage + '-native.json')
    assert record['base'] == BASE and record['result'] == 'captured'
    assert record['producer_sha256'] == sha(retain(PREFIX + producer))
    cap = capsule(stage + '-native-inputs.json.gz', record['inputs'], stage == 'after')
    assert len(cap) == 100 and record['capsule_sha256'] == sha(read(PREFIX + stage + '-native-inputs.json.gz'))
    assert record['instrument_sha256'] == cap[NATIVE]['sha256'] == sha(retain(NATIVE)), 'unchanged first native instrument'
    expected_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines())
    expected_paths.update([NATIVE, PREFIX + producer, 'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', '.knowledge_map.conf'])
    assert set(cap) == expected_paths, 'complete original parent Perl runtime namespace'
    if stage == 'before':
        assert decode(cap[MODULE]['bytes_base64']) == old(MODULE), 'native before any production edit'
    channels = load(stage + '-native-data.json.gz')
    assert record['data_sha256'] == sha(read(PREFIX + stage + '-native-data.json.gz'))
    commands = [['perl', '-c', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE, 'cold'], ['perl', '-Iperl', NATIVE, 'cold']]
    assert [row['command'] for row in channels] == commands
    assert all(row['returncode'] == 0 for row in channels)
    assert not decode(channels[0]['stdout_base64']) and decode(channels[0]['stderr_base64']) == (NATIVE + ' syntax OK\n').encode()
    for row in channels[1:]:
        assert not decode(row['stderr_base64'])
        assert json.loads(decode(row['stdout_base64'])) == row['observation'], 'actual complete native JSON channel'
        assert set(row['observation']['loaded_project_modules']) <= set(cap)
    assert channels[1] == channels[2] and channels[3] == channels[4], 'exact complete native recurrence'
    native[stage] = (cap, channels)
native_counts = {}
for index, mode, count, calls_count in [(1, 'warm', 387, 1995), (3, 'cold', 235, 959)]:
    before = native['before'][1][index]['observation']
    after = native['after'][1][index]['observation']
    assert before['mode'] == after['mode'] == mode
    assert before['emission_loaded'] == after['emission_loaded'] == (mode == 'warm')
    assert before['trace_loaded'] == after['trace_loaded'] == 0
    assert len(before['rows']) == len(after['rows']) == count
    labels = [row['label'] for row in before['rows']]
    assert len(set(labels)) == count and labels == [row['label'] for row in after['rows']]
    assert sum(len(row['native']['calls']) for row in before['rows']) == calls_count
    for original, current in zip(before['rows'], after['rows']):
        assert {k: v for k, v in original.items() if k != 'authority'} == {k: v for k, v in current.items() if k != 'authority'}, 'complete native compatibility ledger'
        assert all(call['context'] == 'scalar' for call in current['native']['calls'])
        assert all(not call['first_is_caller_slot'] for call in current['native']['calls'])
        if mode == 'cold':
            assert original['authority'] == current['authority']
            continue
        options = current['options']
        expected = [{'key': call['key'], 'number': call['number'], 'actual_callback': 1,
                     'eligible': int(bool(options.get('known') and call['key'] == options.get('key')))} for call in current['authority']['calls']]
        assert current['authority']['calls'] == expected, 'actual callback identity and own eligibility'
        assert current['authority']['parent_packet'] == 0, 'no child publication donated to parent'
        assert current['authority']['child_packets'] == int(current['label'] == 'retained-child/1'), 'only registered matching child keeps its packet'
        assert all(call['actual_callback'] == 0 and call['eligible'] == 1 for call in original['authority']['calls'])
        assert original['authority']['parent_packet'] == int(bool(options.get('authority')))
        assert original['authority']['child_packets'] == 0
    assert sum(row['label'].startswith('validation/') and row['native']['fatal'] is not None for row in after['rows']) == 50
    assert sum(row['label'].endswith('/fatal') and row['native']['fatal'] is not None for row in after['rows']) == 25
    assert all(row['native']['fatal'] is None or row['label'].startswith('validation/') or row['label'].endswith('/fatal') for row in after['rows'])
    native_counts[mode] = {'rows': count, 'scalar_callbacks': calls_count}

# The sole runtime change is five resolver returns and an appended lazy helper.
original_source = old(MODULE)
source = retain(MODULE)
marker = b'\n# Keep public dependency maps intact and invoke the retained actual callback.'
assert source.count(marker) == 1 and source.count(b'return _bind_emission_dependency($cb);') == 5
assert source.split(marker)[0] == original_source[:original_source.rfind(b'\n1;')].replace(b'return $cb;', b'return _bind_emission_dependency($cb);'), 'exact original bodies except five required returns'
for name in re.findall(rb'^sub (\w+) \{', original_source, re.M):
    token = b'sub ' + name + b' {'
    assert source[:source.index(token)].count(b'\n') == original_source[:original_source.index(token)].count(b'\n'), 'original global function line locations'
assert retain('perl/LinkedSpec/RuleIR/EmitContext.pm') == old('perl/LinkedSpec/RuleIR/EmitContext.pm'), 'default selection owner unchanged'

paired = {}
for stage, failures in [('before', 490), ('after', 0)]:
    record = load(stage + '.json')
    assert record['stage'] == stage and record['result'] == ('RED' if failures else 'GREEN')
    assert record['producer_sha256'] == sha(retain(PREFIX + 'run.py'))
    cap = capsule(stage + '-inputs.json.gz', record['inputs'], stage == 'after')
    assert len(cap) == 106 and record['capsule_sha256'] == sha(read(PREFIX + stage + '-inputs.json.gz'))
    channels = load(stage + '-channels.json.gz')
    assert record['channels_sha256'] == sha(read(PREFIX + stage + '-channels.json.gz'))
    assert channels[0]['command'] == ['perl', '-c', '-Iperl', FIXTURE]
    assert channels[0]['returncode'] == 0 and not decode(channels[0]['stdout_base64'])
    assert decode(channels[0]['stderr_base64']) == (FIXTURE + ' syntax OK\n').encode()
    assert channels[1]['command'] == ['perl', '-Iperl', FIXTURE]
    failed, labels = tap(channels[1], failures)
    assert failed == record['failures'] and record['assertions'] == record['plan'] == 1795
    assert record['controls'] == 1795 - failures
    paired[stage] = (cap, failed, labels)
assert paired['before'][2] == paired['after'][2], 'identical paired assertions'
assert set(paired['before'][0]) == set(paired['after'][0])
assert [p for p in paired['before'][0] if paired['before'][0][p] != paired['after'][0][p]] == [MODULE], 'only production changes between paired executions'
first = load('first-red.json.gz')
assert first['actual_outer_session'] == 55712 and first['actual_outer_returncode'] == 1
assert re.findall(r"^#   Failed test '(.*)'$", decode(first['merged_log_base64']).decode(), re.M) == [row['name'] for row in paired['before'][1]], 'exact original first prove failure order'
assert all(any(row['name'].endswith(tail) for tail in ['captures each actual callback independently with only its own registration', 'cannot lend a dependency publication to its enclosing callback', "retains only an actually registered matching child's own packet"]) for row in paired['before'][1])

# Retained full-source faults and actual complete TAP, not summary acceptance flags.
faults = load('faults.json')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(retain(PREFIX + 'faults.py'))
assert faults['positive_capsule_sha256'] == sha(read(PREFIX + 'after-inputs.json.gz'))
assert faults['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in paired['after'][0].items()}
rows = load('faults-data.json.gz')
assert faults['data_sha256'] == sha(read(PREFIX + 'faults-data.json.gz'))
assert load('faults-reached.json.gz') == rows
helper_start = source.index(b'sub _bind_emission_dependency {\n')
helper_end = source.index(b'\n1;', helper_start)
helper = source[helper_start:helper_end]
variants = {'inverse': original_source}
owners = ['_looks_like_array_value_expr', '_looks_like_hash_value_expr', '_lower_is_empty_expr', '_lower_defined_target_expr', '_lower_flow_composite_expr']
for name in owners:
    start = source.index(('sub ' + name + ' {\n').encode())
    end = source.index(b'\nsub ', start + 1)
    variants['bypass-' + name] = source[:start] + source[start:end].replace(b'return _bind_emission_dependency($cb);', b'return $cb;', 1) + source[end:]
changed_helpers = {
 'opaque-wrapper-identity': helper.replace(b'_invoke_emission_dependency($callback, @_)', b'_invoke_emission_dependency(sub { return $callback->(@_) }, @_)', 1),
 'copied-argument-slots': helper.replace(b'return sub {\n', b'return sub {\n  my @args = @_;\n', 1).replace(b'($callback, @_)', b'($callback, @args)').replace(b'$callback->(@_)', b'$callback->(@args)'),
 'localized-error-effects': helper.replace(b'return sub {\n', b'return sub {\n  local $@;\n', 1),
 'twice-only-effects': helper.replace(b'return sub {\n', b'return sub {\n  $callback->(@_);\n', 1),
 'eager-emission-loading': helper.replace(b'return sub {\n', b'return sub {\n  require LinkedSpec::ActionIR::SourceEmissions;\n', 1),
}
variants.update({name: source[:helper_start] + changed + source[helper_end:] for name, changed in changed_helpers.items()})
variants['public-map-rebinding'] = source.replace(b'return _bind_emission_dependency($cb);', b'return $deps->{$name} = _bind_emission_dependency($cb);')
variants['disabled-required-validation'] = source.replace(b"unless ref($cb) eq 'CODE';", b'if 0;')
counts = [490, 111, 119, 117, 74, 126, 338, 18, 522, 1012, 2, 602, 100]
assert [row['name'] for row in rows] == list(variants) and len(rows) == 13
fault_results = []
for row, failures in zip(rows, counts):
    assert decode(row['module_base64']) == variants[row['name']], 'exact complete semantic source variant'
    assert row['module_sha256'] == sha(variants[row['name']]) and row['unchanged'] is True
    syntax, channel = row['channels']
    assert syntax['command'] == ['perl', '-c', '-Iperl', MODULE] and syntax['returncode'] == 0
    assert not decode(syntax['stdout_base64']) and decode(syntax['stderr_base64']) == (MODULE + ' syntax OK\n').encode()
    assert channel['command'] == ['perl', '-Iperl', FIXTURE]
    failed, labels = tap(channel, failures)
    assert failed == row['failures'] and labels == paired['after'][2], 'full actual source-fault failures'
    assert row['assertions'] == 1795 and row['plan'] == ['1795']
    if row['name'] == 'inverse':
        assert failed == paired['before'][1], 'sole inverse restores every original failure name/number'
    fault_results.append({'name': row['name'], 'failures': failures})
assert faults['variants'] == [{'name': row['name'], 'assertions': 1795, 'failures': len(row['failures']), 'module_sha256': row['module_sha256']} for row in rows]

consumer = load('consumers.json')
assert consumer['result'] == 'PASS' and consumer['base'] == BASE and consumer['returncode'] == 0 and consumer['unchanged'] is True
assert consumer['producer_sha256'] == sha(retain(PREFIX + 'consumers.py'))
seed = json.loads(retain(consumer['seed']))
assert sha(read(consumer['seed'])) == consumer['seed_sha256']
cap = capsule('consumers-inputs.json.gz', {p: {'sha256': h, 'mode': consumer['modes'][p]} for p, h in consumer['inputs'].items()}, True)
assert len(cap) == 256 and consumer['capsule_sha256'] == sha(read(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['command'] == seed['command'] + [FIXTURE]
assert all(consumer['inputs'][p] == h for p, h in seed['inputs'].items() if p != MODULE), 'unchanged complete accepted consumer inputs'
channels = load('consumers-channels.json.gz')
assert consumer['channels_sha256'] == sha(read(PREFIX + 'consumers-channels.json.gz'))
assert channels['command'] == consumer['command'] and channels['returncode'] == 0
out, err = decode(channels['stdout_base64']), decode(channels['stderr_base64'])
assert err == decode(seed['stderr_base64']) and b'All tests successful.' in out and b'Result: PASS' in out
groups, current, assertions, plans = [], None, [], []
for line in out.splitlines():
    header = re.match(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', line)
    if header:
        if current is not None:
            groups.append((current, assertions, plans))
        current, assertions, plans = header[1].decode(), [], []
        continue
    if current is None:
        continue
    assertion = re.match(rb'^(not )?ok (\d+)(?: - (.*))?$', line)
    if assertion:
        assert not assertion[1], 'actual consumer assertion failure'
        assertions.append(int(assertion[2]))
    plan = re.match(rb'^1\.\.(\d+)$', line)
    if plan:
        plans.append(int(plan[1]))
if current is not None:
    groups.append((current, assertions, plans))
assert [row[0] for row in groups] == consumer['command'][3:] and len(groups) == 77, 'complete ordered consumer header population'
for path, assertions, plans in groups:
    assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete consumer numeric plan', path)
total = sum(row[2][0] for row in groups)
assert groups[-1][2] == [1795] and total == 19470
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'77', b'19470')]

# Complete current Knowledge population, syntax, retained original headers and bodies.
knowledge = load('knowledge.json')
assert knowledge['base'] == BASE and knowledge['markdown'] == 1485
assert knowledge['producer_sha256'] == sha(retain(PREFIX + 'knowledge.py'))
population = load('knowledge-inputs.json.gz')
assert knowledge['capsule_sha256'] == sha(read(PREFIX + 'knowledge-inputs.json.gz'))
assert knowledge['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in population['current'].items()}
paths = sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions') for p in (ROOT / directory).rglob('*.md') if p.is_file())
assert paths == sorted(population['original']) and len(paths) == 1485, 'complete current Knowledge population'
facts, changed = 0, []
for p in paths:
    raw = read(p)
    original = decode(population['original'][p]['bytes_base64'])
    current = population['current'][p]
    assert raw == decode(current['bytes_base64']) and sha(raw) == current['sha256'], 'full current Knowledge byte identity'
    if raw != original:
        changed.append(p)
        retain(p)
        old_end = original.index(b'\n---', 4) + 4
        new_end = raw.index(b'\n---', 4) + 4
        assert original[:old_end] in raw[new_end:], 'whole original Knowledge header retained'
        if not p.endswith('/perl-factory-capture-framework.md'):
            assert raw[new_end:].startswith(original[old_end:]), 'whole original route-card body retained'
        assert (PREFIX + 'publish-claim.py').encode() in raw[:new_end]
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        continue
    owner, fact = None, False
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            assert owner is not None, ('orphan current Knowledge header', p, number)
            fact |= owner == 'answers'
        elif re.match(r'^[A-Za-z_][A-Za-z_0-9]*\s*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                fact = True
    facts += fact
assert facts == 1349 and changed == knowledge['changed_cards'] and len(changed) == 7
for p, item in population['current'].items():
    if p not in paths:
        assert retain(p) == decode(item['bytes_base64']) and inputs[p]['mode'] == item['mode']
assert knowledge['returncode'] == 0 and not decode(knowledge['stdout_base64'])
assert decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert knowledge['command'] == ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
# The complete original accepted population is independently checked against its immutable Git tree.
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source_archive:
    original_population = {item.name: {'bytes_base64': base64.b64encode(source_archive.extractfile(item).read()).decode(), 'mode': item.mode} for item in source_archive if item.isfile() and item.name.endswith('.md')}
assert population['original'] == original_population, 'complete original accepted Knowledge custody'

process = subprocess.run(['python3', PREFIX + 'book-review.py'], cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr, ('actual readonly full book review', process.stderr)
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
for p, digest in book['source_inputs'].items():
    assert sha(retain(p)) == digest
retain(PREFIX + 'book.py'); retain(PREFIX + 'book-review.py'); retain(PREFIX + 'book.json')
retain(PREFIX + 'review.py')

if sys.argv[1:] == ['--preflight']:
    print('FlowExpr independent preflight PASS:622 native rows;1795 paired/490 original RED;13 source faults;77 suites/256 inputs/19470 assertions;Knowledge1485/1349;book89/4;original218/full58582')
    sys.exit(0)

compat = load('compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha(retain(PREFIX + 'compat.py'))
assert [row['command'] for row in compat['rows']] == [['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(row['returncode'] == 0 for row in compat['rows'])
phase = decode(compat['rows'][2]['stdout_base64'])
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', phase, re.M) == [(b'1', b'1035')] and b'Result: PASS' in phase
phase_rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', phase, re.M)
assert re.findall(rb'^1\.\.(\d+)$', phase, re.M) == [b'1035']
assert [int(row[1]) for row in phase_rows] == list(range(1, 1036)) and not any(row[0] for row in phase_rows), 'complete supplemental Phase0 plan'
report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(read(PREFIX + 'review.py')),
          'native': native_counts, 'paired_assertions': 1795, 'original_red': 490, 'original_controls': 1305,
          'source_faults': fault_results, 'consumer_suites': 77, 'consumer_inputs': 256,
          'consumer_assertions': total, 'consumer_plans': [{'path': p, 'assertions': plan[0]} for p, _, plan in groups],
          'original_bindings': 218, 'original_publication_bytes': 58582,
          'knowledge_markdown': 1485, 'knowledge_facts': 1349, 'knowledge_overlays': 7,
          'book_sources': 89, 'book_controls': 4, 'supplemental_phase0': 1035, 'inputs': inputs,
          'scope': 'Required injected FlowExpr callbacks only. Complete real helper bodies, all parent Perl runtime inputs and actual dependency references are exercised; controlled callbacks remain explicit. Every original/current native row, exact recurrence, paired/fault name/number, full consumer header/plan, original publication/binding, current Knowledge scan/header lineage and complete book control is reviewed. Optional kind and default registration, complete helpers/private/parent/pipeline/canonical and other backends remain separate. System tools are reused read-only; no immutable toolchain claim. Standard Phase0 is supplemental without a complete transitive input capsule. All first capture writers are retired.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    assert not target.exists(), 'one-shot independent report capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact current independent review publication'
print('FlowExpr independent review PASS:1795 paired/490 original RED;13 faults;77 suites/256 inputs/19470 assertions;622 native rows;original218/full58582;Knowledge1485/1349;book89/4; supplemental Phase01035')
