"""Readonly independent review with a fixed input inventory and no self-result census."""
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

ROOT = Path(__file__).resolve().parents[3]
BASE = 'c7570b71642e1889ab03ee07c29273dabdf16989'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
INSTRUMENT = 't/actionir_control_single_native.pl'
FIXTURE = 't/actionir_control_single_capture.t'
OWNER = '_lower_flow_branch_single_statement'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/consumers.json'
SEED_CHANNELS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/consumers-channels.json.gz'
sha = lambda value: hashlib.sha256(value).hexdigest()
raw = lambda path: (ROOT / path).read_bytes()
load = lambda name: json.loads(raw(PREFIX + name))
packed = lambda name: json.loads(gzip.decompress(raw(PREFIX + name)))
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'], ['--inventory'])
preflight = sys.argv[1:] in (['--preflight'], ['--inventory'])
inputs = set()


def channel(record, name):
    return base64.b64decode(record[name + '_base64'], validate=True)


def component(name):
    p = subprocess.run(['bash', 'tools/run_python_project_data.sh', PREFIX + name],
                       cwd=ROOT, capture_output=True)
    assert p.returncode == 0 and not p.stderr, ('readonly component rejection', name, p.stderr)
    return {'script': name, 'returncode': p.returncode,
            'stdout_base64': base64.b64encode(p.stdout).decode()}


def capsule(name, record=None):
    value = packed(name)
    for path, item in value.items():
        payload = base64.b64decode(item['bytes_base64'], validate=True)
        assert sha(payload) == item['sha256'], ('complete capsule identity', name, path)
        if path == MODULE:
            continue
        current = path
        assert raw(current) == payload and (ROOT / current).stat().st_mode & 0o7777 == item['mode']
        inputs.add(current)
    if record is not None:
        assert record['inputs'] == {p: {'sha256': x['sha256'], 'mode': x['mode']} for p, x in value.items()}
        assert record['capsule_sha256'] == sha(raw(PREFIX + name))
    return value


def tap(record, plan):
    text = channel(record, 'stdout').decode()
    rows = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == [str(plan)]
    assert len(rows) == plan and [int(n) for _, n, _ in rows] == list(range(1, plan + 1))
    assert not re.search(r'^Bail out!', text, re.M)
    return [{'number': int(n), 'name': title} for bad, n, title in rows if bad]


preservation = load('preservation.json')
assert preservation['base'] == BASE and preservation['result'] == 'PASS'
assert preservation['producer_sha256'] == sha(raw(PREFIX + 'preserve.py'))
claim_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                    cwd=ROOT, text=True).splitlines()
census, selected = [], {}
owned = set(preservation['owned_bound_paths'])
for path in sorted(claim_paths):
    payload = old(path)
    record = json.loads(payload)
    hits = []
    for index, claim in enumerate(record['claims']):
        d = claim['durability']
        if d.get('mode') != 'live':
            continue
        overlap = sorted(owned & {x['path'] for x in d['inputs']})
        if overlap:
            for item in d['inputs']:
                assert sha(old(item['path'])) == item['sha256'], 'accepted Git input custody'
                # Historical predecessor inputs resolve through accepted Git; current runtime inputs are independently supplied below.
            hits.append({'claim_index': index, 'paths': overlap, 'bindings': len(d['inputs'])})
    census.append({'path': path, 'sha256': sha(payload), 'intersections': hits})
    if hits:
        selected[path] = (payload, hits)
assert census == preservation['census']
expected_prior = {
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json': (461, 110981,
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/publish.py',
        b'ControlFlow attached-parser publication PASS: 461 live inputs; 110981 bytes\n'),
}
assert set(selected) == set(expected_prior) and len(preservation['selected']) == 1
for entry in preservation['selected']:
    path = entry['path']
    payload, hits = selected[path]
    count, size, producer, suffix = expected_prior[path]
    assert raw(entry['before']) == payload, 'whole accepted publication custody'
    assert entry['sha256'] == sha(payload) and entry['bytes'] == len(payload) == size
    assert entry['intersections'] == hits and sum(h['bindings'] for h in hits) == count
    changed = json.loads(payload)
    for hit in hits:
        changed['claims'][hit['claim_index']]['durability'].update(mode='historical', revision=BASE)
    assert json.loads(raw(path)) == changed, 'only historical mode/revision changes'
    baseline = load('baseline-' + Path(path).stem + '.json')
    assert baseline in preservation['baselines'] and baseline['claim'] == path
    assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh', producer]
    assert baseline['returncode'] == 0 and not channel(baseline, 'stderr')
    assert channel(baseline, 'stdout').endswith(suffix)
    inputs.add(path)

original_source, source = old(MODULE), raw(MODULE)
a = original_source.index(('sub ' + OWNER + ' {\n').encode())
b = original_source.index(b'\nsub ', a + 1)
body = original_source[a:b]
assert body.count(b'return $cb;') == 1
expected_source = original_source[:a] + body.replace(b'return $cb;', b'return _bind_emission_dependency($cb);', 1) + original_source[b:]
assert source == expected_source, 'only the original parser validator return changes'
assert source.count(b'return _bind_emission_dependency($cb);') == 6
assert source.count(b'return $cb;') == original_source.count(b'return $cb;') - 1 == 16
assert re.findall(rb"\$require_dep->\('([a-z_]+)'\)", body) == [b'trim_action_ir_value']
assert b'my $trimmed = $trim_action_ir_value->($expr);' in body
parent_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines())
wrapper_paths = {'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', '.knowledge_map.conf'}

native = {}
for stage, stem, producer in [('before', 'before', 'observe.py'), ('after', 'after', 'observe-after.py')]:
    record = load(stem + '-native.json')
    cap = capsule(stem + '-native-inputs.json.gz', record)
    assert set(cap) == parent_paths | wrapper_paths | {INSTRUMENT, PREFIX + producer} and len(cap) == 100, 'complete native runtime namespace'
    assert base64.b64decode(cap[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    assert record['producer_sha256'] == sha(raw(PREFIX + producer)) and record['instrument_sha256'] == sha(raw(INSTRUMENT))
    data = packed(stem + '-native-data.json.gz')
    assert record['data_sha256'] == sha(raw(PREFIX + stem + '-native-data.json.gz'))
    assert len(data) == 5 and all(r['returncode'] == 0 for r in data)
    assert not channel(data[0], 'stdout') and channel(data[0], 'stderr') == (INSTRUMENT + ' syntax OK\n').encode()
    for index in range(1, 5):
        row = data[index]
        assert not channel(row, 'stderr') and json.loads(channel(row, 'stdout')) == row['observation']
        obs = row['observation']
        assert obs['perl_version'] == 'v5.34.1' and obs['trace_loaded'] == 0 and obs['emission_loaded'] == (1 if index < 3 else 0)
        assert set(obs['loaded_project_modules']) <= set(cap)
        labels = [r['label'] for r in obs['rows']]
        assert len(set(labels)) == len(labels) == (87 if index < 3 else 79)
        calls = [c for r in obs['rows'] for c in r['native']['calls']]
        assert len(calls) == (379 if index < 3 else 355) and all(c['context'] == 'scalar' for c in calls)
    assert data[1] == data[2] and data[3] == data[4], 'exact fresh-process recurrence'
    native[stage] = (record, cap, data)
for index in (1, 3):
    before = native['before'][2][index]['observation']['rows']
    after = native['after'][2][index]['observation']['rows']
    assert [r['label'] for r in before] == [r['label'] for r in after]
    assert [r['native'] for r in before] == [r['native'] for r in after], 'every original ordinary native row'
    if index == 1:
        for row in after:
            options = row['options']
            expected = [{'key': c['key'], 'number': c['number'], 'actual_callback': 1,
                         'eligible': 1 if options.get('known') and c['key'] == options.get('key') else 0}
                        for c in row['authority']['calls']]
            assert row['authority']['calls'] == expected, 'actual scalar callback identity and own registration'
            assert row['authority']['parent_packet'] == 0, 'no enclosing packet donation'
            assert row['authority']['child_packets'] == (1 if options.get('known') and options.get('authority') else 0), 'only own matching child packet'
rows_by_label = {r['label']: r for r in native['before'][2][1]['observation']['rows']}
mutation = rows_by_label['effect/single/trim_action_ir_value/1/mutate']['native']
assert mutation['input_after'] == 'bare' and mutation['result'] == 'bare!'
assert mutation['calls'][0]['first_readonly'] == 0 and mutation['calls'][0]['first_is_caller_slot'] == 0
slot = mutation['held_slots']['items'][0]['fields']['slot']
assert slot['type'] == 'SCALAR' and slot['value'] == 'bare!', 'writable local trim alias'
assert rows_by_label['ordinary/implicit_closures/scalar']['native']['result'] == '} } bare'
assert rows_by_label['ordinary/prefixed_rule/scalar']['native']['result'] == '} accepted'
rejected = rows_by_label['ordinary/rule_reject_then_accept/scalar']['native']
assert rejected['result'] == 'accepted' and [r['name'] for r in rejected['rule_calls']] == ['reject', 'accept']
for index, rule in enumerate(rejected['rule_calls']):
    fields = rule['candidate_before']['fields']
    assert fields['switch_counter'] == 3 and fields['while_counter'] == 7
    entry = fields['if_stack']['items'][0]['fields']
    assert 'changed' not in entry and entry['nested']['fields']['shared'] == index + 1
assert rejected['branch_after']['fields']['switch_counter'] == 13
assert rejected['branch_after']['fields']['while_counter'] == 27
assert rejected['branch_after']['fields']['if_stack']['items'][0]['fields']['nested']['fields']['shared'] == 3, 'native shallow candidate copy'
zero = rows_by_label['ordinary/rule_zero/scalar']['native']
assert zero['result'] == '0' and zero['branch_after']['fields']['switch_counter'] == 13, 'nonempty zero rule commits'
tied = rows_by_label['ordinary/tied_selection/scalar']['native']
assert tied['map_reads'] == ['trim_action_ir_value', 'trim_action_ir_value', 'parse_method_function_expr', 'trim_action_ir_value']
assert tied['effects'] == [{'replacement': 'tied-trim'}] and tied['calls'][0]['key'] == 'trim_action_ir_value', 'eager tied-map selection'
typed = rows_by_label['ordinary/typed_if/scalar']['native']
assert typed['result'] == typed['input_after'], 'injected blank splitter retains native typed fallback reference'
assert rows_by_label['ordinary/attached_if/scalar']['native']['result'].endswith(' { bare')

pairs = {}
for stage in ('before', 'after'):
    record = load(stage + '.json')
    cap = capsule(stage + '-inputs.json.gz', record)
    expected = set(native['before'][1]) | {FIXTURE, PREFIX + 'run.py', PREFIX + 'before-native.json',
        PREFIX + 'before-native-data.json.gz', PREFIX + 'before-native-inputs.json.gz'}
    assert set(cap) == expected and len(cap) == 105
    assert record['producer_sha256'] == sha(raw(PREFIX + 'run.py'))
    assert base64.b64decode(cap[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    data = packed(stage + '-channels.json.gz')
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-channels.json.gz'))
    assert len(data) == 2 and data[0]['returncode'] == 0 and channel(data[0], 'stderr') == (FIXTURE + ' syntax OK\n').encode()
    failures = tap(data[1], 439)
    assert failures == record['failures'] and record['plan'] == record['assertions'] == 439
    assert len(failures) == (94 if stage == 'before' else 0)
    assert record['controls'] == 439 - len(failures) and bool(data[1]['returncode']) == bool(failures)
    if stage == 'after':
        assert not channel(data[1], 'stderr')
    pairs[stage] = (record, cap, data)
assert pairs['before'][1][FIXTURE] == pairs['after'][1][FIXTURE], 'identical paired fixture bytes/mode'

start = source.index(b'sub _bind_emission_dependency {\n')
end = source.index(b'\n1;', start)
helper = source[start:end]
a = source.index(('sub ' + OWNER + ' {\n').encode())
b = source.index(b'\nsub ', a + 1)
part = source[a:b]
variants = {'inverse': original_source,
            'bypass-' + OWNER: source[:a] + part.replace(b'return _bind_emission_dependency($cb);', b'return $cb;', 1) + source[b:]}
def helper_fault(name, value):
    variants[name] = source[:start] + value + source[end:]
helper_fault('opaque-wrapper-identity', helper.replace(b'_invoke_emission_dependency($callback, @_)', b'_invoke_emission_dependency(sub { return $callback->(@_) }, @_)', 1))
helper_fault('copied-argument-slots', helper.replace(b'return sub {\n', b'return sub {\n  my @args = @_;\n', 1).replace(b'($callback, @_)', b'($callback, @args)').replace(b'$callback->(@_)', b'$callback->(@args)'))
helper_fault('localized-error-effects', helper.replace(b'return sub {\n', b'return sub {\n  local $@;\n', 1))
helper_fault('twice-only-effects', helper.replace(b'return sub {\n', b'return sub {\n  $callback->(@_);\n', 1))
helper_fault('eager-emission-loading', helper.replace(b'return sub {\n', b'return sub {\n  require LinkedSpec::ActionIR::SourceEmissions;\n', 1))
variants['delayed-map-selection'] = source[:a] + part.replace(b'return _bind_emission_dependency($cb);', b'return sub { return _bind_emission_dependency($deps->{$name})->(@_) };') + source[b:]
variants['public-map-rebinding'] = source[:a] + part.replace(b'return _bind_emission_dependency($cb);', b'return $deps->{$name} = _bind_emission_dependency($cb);') + source[b:]
variants['disabled-required-validation'] = source[:a] + part.replace(b"unless ref($cb) eq 'CODE';", b'if 0;') + source[b:]
faults = load('faults.json')
fault_rows = packed('faults-data.json.gz')
assert faults['producer_sha256'] == sha(raw(PREFIX + 'faults.py'))
assert faults['positive_capsule_sha256'] == sha(raw(PREFIX + 'after-inputs.json.gz'))
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-data.json.gz'))
assert fault_rows == packed('faults-reached.json.gz'), 'complete decoded records, independently bound compressed identities'
assert [r['name'] for r in fault_rows] == list(variants) and len(variants) == 10
assert len({sha(value) for value in variants.values()}) == 9, 'inverse and sole-validator bypass are the same source'
for row in fault_rows:
    assert base64.b64decode(row['module_base64'], validate=True) == variants[row['name']]
    assert row['module_sha256'] == sha(variants[row['name']]) and row['unchanged']
    data = row['channels']
    assert len(data) == 2 and data[0]['returncode'] == 0
    failures = tap(data[1], 439)
    assert failures == row['failures'] and failures and data[1]['returncode'] != 0
    assert row['assertions'] == 439 and row['plan'] == ['439']
    if row['name'] == 'inverse':
        assert failures == pairs['before'][0]['failures'], 'exact inverse original94'
assert faults['variants'] == [{'name': r['name'], 'assertions': 439, 'failures': len(r['failures']), 'module_sha256': r['module_sha256']} for r in fault_rows]
copy_row = next(r for r in fault_rows if r['name'] == 'copied-argument-slots')
assert len(copy_row['failures']) == 18, 'actual global helper argument-copy fault'
assert [len(r['failures']) for r in fault_rows] == [94, 94, 86, 18, 156, 250, 2, 6, 160, 4]

assert raw(SEED) == old(SEED) and raw(SEED_CHANNELS) == old(SEED_CHANNELS)
seed, seed_channel = json.loads(raw(SEED)), json.loads(gzip.decompress(raw(SEED_CHANNELS)))
def suite_plans(record, expected):
    text = channel(record, 'stdout').decode()
    headers = list(re.finditer(r'^(\S+\.t) \.+\s*$', text, re.M))
    assert [h.group(1) for h in headers] == expected, 'complete accepted consumer command/header population'
    result = []
    for i, h in enumerate(headers):
        part = text[h.end():headers[i + 1].start() if i + 1 < len(headers) else len(text)]
        plans = re.findall(r'^1\.\.(\d+)$', part, re.M)
        rows = re.findall(r'^(not )?ok (\d+)(?: - (.*))?$', part, re.M)
        assert len(plans) == 1 and int(plans[0]) == len(rows)
        assert [int(n) for _, n, _ in rows] == list(range(1, len(rows) + 1))
        result.append((h.group(1), len(rows), [{'number': int(n), 'name': title} for bad, n, title in rows if bad]))
    return result
seed_plans = suite_plans(seed_channel, seed['command'][3:])
assert len(seed_plans) == 82 and sum(n for _, n, _ in seed_plans) == 22770
consumer = load('consumers.json')
cc = capsule('consumers-inputs.json.gz')
consumer_channel = packed('consumers-channels.json.gz')
assert consumer['producer_sha256'] == sha(raw(PREFIX + 'consumers.py'))
assert consumer['capsule_sha256'] == sha(raw(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
assert consumer['inputs'] == {p: x['sha256'] for p, x in cc.items()} and consumer['modes'] == {p: x['mode'] for p, x in cc.items()}
expected = set(seed['inputs']) | set(native['before'][1]) | {FIXTURE, PREFIX + 'before-native-data.json.gz', SEED, SEED_CHANNELS, PREFIX + 'consumers.py'}
assert set(cc) == expected and len(cc) == 298, 'complete supplied consumer population'
assert consumer['command'] == consumer_channel['command'] == seed['command'] + [FIXTURE]
assert consumer['unchanged'] and consumer['returncode'] == consumer_channel['returncode'] == 0
assert base64.b64decode(cc[MODULE]['bytes_base64']) == source
for path, digest in seed['inputs'].items():
    if path != MODULE:
        assert cc[path]['sha256'] == digest
plans = suite_plans(consumer_channel, consumer['command'][3:])
assert plans[:-1] == seed_plans and plans[-1][1:] == (439, [])
assert len(plans) == 83 and sum(n for _, n, _ in plans) == 23209
assert consumer_channel['stderr_base64'] == seed_channel['stderr_base64'] and b'Result: PASS' in channel(consumer_channel, 'stdout')

k = load('knowledge.json')
kc = packed('knowledge-inputs.json.gz')
assert k['base'] == BASE and k['producer_sha256'] == sha(raw(PREFIX + 'knowledge.py'))
assert k['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-inputs.json.gz'))
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source_archive:
    original = {x.name: {'bytes_base64': base64.b64encode(source_archive.extractfile(x).read()).decode(), 'mode': x.mode} for x in source_archive if x.isfile() and x.name.endswith('.md')}
assert original == kc['original'] and len(original) == 1485
current = kc['current']
assert k['inputs'] == {p: {'sha256': x['sha256'], 'mode': x['mode']} for p, x in current.items()}
changed, body_changes, facts, knowledge_bytes = [], [], 0, 0
for path, item in current.items():
    payload = base64.b64decode(item['bytes_base64'], validate=True)
    assert sha(payload) == item['sha256']
    if path in original:
        before = base64.b64decode(original[path]['bytes_base64'])
        if payload.startswith(b'---\n') and re.search(rb'^id: ', payload, re.M):
            facts += 1
        if path.startswith('docs/knowledge/'):
            knowledge_bytes += len(payload)
        if payload != before:
            changed.append(path)
            assert (PREFIX + 'publish.py').encode() in payload.split(b'\n---\n', 1)[0]
            if payload.split(b'\n---\n', 1)[1] != before.split(b'\n---\n', 1)[1]:
                body_changes.append(path)
    if path not in original or path in k['changed_cards']:
        assert raw(path) == payload and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
        inputs.add(path)
assert sorted(changed) == k['changed_cards'] and len(changed) == 10 and facts == 1349
assert body_changes == ['docs/knowledge/perl-factory-capture-framework.md']
assert knowledge_bytes == 8387900 <= 8388608
assert k['returncode'] == 0 and not channel(k, 'stdout') and channel(k, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
components = [component('book-review.py')]
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
assert all(sha(raw(p)) == digest for p, digest in book['source_inputs'].items())
inputs.update(book['source_inputs'])
assert raw('doctrine/readme_stability/routes.jsonl') == old('doctrine/readme_stability/routes.jsonl')
validation = load('validation.json')
assert all(sha(raw(p)) == digest for p, digest in validation['sources'].items())
inputs.update(validation['sources'])
inputs.update((MODULE, FIXTURE, INSTRUMENT, SEED, SEED_CHANNELS, 'doctrine/readme_stability/routes.jsonl'))
# Explicit completed proof inputs: never enumerate a directory containing this
# reader's result or an in-flight supplemental standard record.
checkpoint_names = [
    'preserve.py', 'preservation.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json',
    'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json',
    'observe.py', 'before-native.json', 'before-native-inputs.json.gz', 'before-native-data.json.gz',
    'run.py', 'before.json', 'before-inputs.json.gz', 'before-channels.json.gz',
    'after.json', 'after-inputs.json.gz', 'after-channels.json.gz',
    'observe-after.py', 'after-native.json', 'after-native-inputs.json.gz', 'after-native-data.json.gz',
    'faults.py', 'faults.json', 'faults-data.json.gz', 'faults-reached.json.gz',
    'consumers.py', 'consumers.json', 'consumers-inputs.json.gz', 'consumers-channels.json.gz',
    'knowledge.py', 'knowledge.json', 'knowledge-inputs.json.gz',
    'book.py', 'book.json', 'book-review.py', 'book-review.json',
    'compat.py', 'validation.py', 'validation.json', 'review.py',
]
inputs.update(PREFIX + name for name in checkpoint_names)
assert all((ROOT / p).is_file() and not (ROOT / p).is_symlink() for p in inputs)
if sys.argv[1:] == ['--inventory']:
    print(json.dumps(sorted(inputs)))
    raise SystemExit(0)
if preflight:
    print('Single statement preflight PASS: original461 bindings; native100/87/79;439/94 RED;10 fault cases/9 sources;83/298/23209; Knowledge1485/1349/ten; book89/four')
    raise SystemExit(0)
standard = load('compat.json')
assert standard['result'] == 'PASS' and len(standard['rows']) == 5
assert standard['producer_sha256'] == sha(raw(PREFIX + 'compat.py')) and all(r['returncode'] == 0 for r in standard['rows'])
assert b'Tests=1035' in channel(standard['rows'][-1], 'stdout') and b'Result: PASS' in channel(standard['rows'][-1], 'stdout')
components.append(component('validation.py'))
result = {
    'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review.py')),
    'inputs': {p: {'sha256': sha(raw(p)), 'mode': (ROOT / p).stat().st_mode & 0o7777} for p in sorted(inputs)},
    'components': components,
    'population': {'original_publications': 1, 'original_bindings': 461, 'original_publication_bytes': [110981],
        'native_inputs': 100, 'warm_rows': 87, 'cold_rows': 79, 'ordinary_rows': 166,
        'required_validators': 1, 'required_roles': 1, 'paired_assertions': 439, 'original_red': 94,
        'passing_controls': 345, 'source_fault_cases': 10, 'distinct_fault_sources': 9,
        'consumer_suites': 83, 'consumer_inputs': 298, 'consumer_assertions': 23209,
        'knowledge_markdown': 1485, 'knowledge_facts': 1349, 'live_card_overlays': 10,
        'knowledge_bytes': knowledge_bytes, 'book_inputs': 89, 'book_controls': 4},
    'limits': 'Complete original/current ordinary rows and exact recurrences remain frozen. Only the required trim '
              'validator changes. Scalar local aliases, tied selection, direct/AST/closure and shallow candidate '
              'state stay native. The injected blank splitter typed case declines and retains its original '
              'reference; it is not a facade typed-success claim. The global helper argument-copy fault also '
              'covers previously bound nested parser/head aliases, not an independently observable identity '
              'claim for the private local expression. All461 historical bindings resolve through accepted Git; '
              'current runtime inputs use the new supplied capsules. Inverse and sole-validator bypass share '
              'one source variant. Complete Knowledge/book custody is retained. Standard/public guard are '
              'supplemental without complete transitive toolchain/input capsules. Later ControlFlow/default '
              'and direct/rule/pipeline/helper/private/parent/canonical admissions remain open.',
}
value = (json.dumps(result, indent=2) + '\n').encode()
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value, 'exact independent full review'
print('Single statement independent review PASS:166 ordinary rows;439/94 RED/all GREEN;10 cases/9 sources;83/298/23209; original publication/Knowledge/book custody')
