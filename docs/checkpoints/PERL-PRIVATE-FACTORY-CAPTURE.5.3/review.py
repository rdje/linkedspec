"""Readonly bounded switch review; fixed preflight inventory excludes its result."""
import base64
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
BASE = '09000223f2dac822b2c0d75c69dce587f2b5b2c0'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
INSTRUMENT = 't/actionir_control_switch_native.pl'
FIXTURE = 't/actionir_control_switch_capture.t'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/consumers.json'
SEED_CHANNELS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/consumers-channels.json.gz'
OWNERS = ('_lower_switch_flow_statement', '_lower_case_flow_statement', '_lower_default_flow_statement',
          '_lower_endcase_flow_statement', '_lower_endswitch_flow_statement', '_lower_inline_switch_branch_expr')
sha = lambda value: hashlib.sha256(value).hexdigest()
raw = lambda path: (ROOT / path).read_bytes()
load = lambda name: json.loads(raw(PREFIX + name))
packed = lambda name: json.loads(gzip.decompress(raw(PREFIX + name)))
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'], ['--inventory'])
preflight = sys.argv[1:] in (['--preflight'], ['--inventory'])
inputs = set()


def channel(record, name):
    return decode(record[name + '_base64'])


def component(name):
    p = subprocess.run(['bash', 'tools/run_python_project_data.sh', PREFIX + name],
                       cwd=ROOT, capture_output=True)
    assert p.returncode == 0 and not p.stderr, ('readonly component rejection', name, p.stderr)
    return {'script': name, 'returncode': p.returncode,
            'stdout_base64': base64.b64encode(p.stdout).decode()}


def capsule(name, record=None):
    value = packed(name)
    for path, item in value.items():
        payload = decode(item['bytes_base64'])
        assert sha(payload) == item['sha256'], ('complete capsule identity', name, path)
        if path != MODULE:
            assert raw(path) == payload and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
            inputs.add(path)
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
            hits.append({'claim_index': index, 'paths': overlap, 'bindings': len(d['inputs'])})
    census.append({'path': path, 'sha256': sha(payload), 'intersections': hits})
    if hits:
        selected[path] = (payload, hits)
assert census == preservation['census']
assert set(selected) == {'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.2.json'} and len(preservation['selected']) == 1
entry = preservation['selected'][0]
payload, hits = selected[entry['path']]
assert raw(entry['before']) == payload, 'whole accepted publication custody'
assert entry['sha256'] == sha(payload) and entry['bytes'] == len(payload) == 109061
assert entry['intersections'] == hits and sum(h['bindings'] for h in hits) == 463
changed = json.loads(payload)
for hit in hits:
    changed['claims'][hit['claim_index']]['durability'].update(mode='historical', revision=BASE)
assert json.loads(raw(entry['path'])) == changed, 'only historical mode/revision changes'
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.2.json')
assert baseline in preservation['baselines'] and baseline['claim'] == entry['path']
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh',
                              'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/publish.py']
assert baseline['returncode'] == 0 and not channel(baseline, 'stderr')
assert channel(baseline, 'stdout') == b'ControlFlow if/while publication PASS: 463 live inputs; 109061 bytes\n'
inputs.add(entry['path'])

original_source, source = old(MODULE), raw(MODULE)
expected_source = original_source
for owner in OWNERS:
    a = expected_source.index(('sub ' + owner + ' {\n').encode())
    b = expected_source.index(b'\nsub ', a + 1)
    body = expected_source[a:b]
    assert body.count(b'return $cb;') == 1
    expected_source = expected_source[:a] + body.replace(b'return $cb;',
        b'return _bind_emission_dependency($cb);', 1) + expected_source[b:]
assert source == expected_source, 'only six original required-validator return lines change'
assert source.count(b'\n') == original_source.count(b'\n')
assert source.count(b'return _bind_emission_dependency($cb);') == 18
assert source.count(b'return $cb;') == original_source.count(b'return $cb;') - 6 == 4
parent_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'],
                                          cwd=ROOT, text=True).splitlines())
wrapper_paths = {'tools/project_data_env.sh', 'tools/project_data_run.sh',
                 'tools/run_python_project_data.sh', '.knowledge_map.conf'}
first_paths = parent_paths | wrapper_paths | {INSTRUMENT, PREFIX + 'observe.py'}
after_paths = first_paths | {PREFIX + 'after.json', PREFIX + 'observe-after.py',
    PREFIX + 'before-native.json', PREFIX + 'before-native-inputs.json.gz',
    PREFIX + 'before-native-data.json.gz'}
native = {}
for stem, producer, instrument, paths, counts in (
    ('before', 'observe.py', INSTRUMENT, first_paths, (333, 297)),
    ('after', 'observe-after.py', INSTRUMENT, after_paths, (333, 297))):
    record = load(stem + '-native.json')
    cap = capsule(stem + '-native-inputs.json.gz', record)
    assert set(cap) == paths, 'complete native runtime namespace'
    assert len(cap) == {'before': 100, 'after': 105}[stem]
    assert decode(cap[MODULE]['bytes_base64']) == (source if stem == 'after' else original_source)
    assert record['producer_sha256'] == sha(raw(PREFIX + producer))
    assert record['instrument_sha256'] == sha(raw(instrument))
    data = packed(stem + '-native-data.json.gz')
    assert record['data_sha256'] == sha(raw(PREFIX + stem + '-native-data.json.gz'))
    assert len(data) == 5 and all(r['returncode'] == 0 for r in data)
    assert not channel(data[0], 'stdout') and channel(data[0], 'stderr') == (instrument + ' syntax OK\n').encode()
    for index in range(1, 5):
        row = data[index]
        assert not channel(row, 'stderr') and json.loads(channel(row, 'stdout')) == row['observation']
        obs = row['observation']
        assert obs['perl_version'] == 'v5.34.1' and obs['trace_loaded'] == 0
        assert obs['emission_loaded'] == (1 if index < 3 else 0)
        assert set(obs['loaded_project_modules']) <= set(cap)
        labels = [r['label'] for r in obs['rows']]
        assert len(set(labels)) == len(labels) == counts[0 if index < 3 else 1]
        calls = [c for r in obs['rows'] for c in r['native']['calls']]
        required_calls = [c for c in calls if c['key'] == 'normalize_method_args_with_optional_scope']
        assert all(c['context'] == 'scalar' for c in required_calls)
        assert len(required_calls) == (270 if index < 3 else 234)
    assert data[1] == data[2] and data[3] == data[4], 'exact fresh-process recurrence'
    native[stem] = (record, cap, data)
for index in (1, 3):
    before = native['before'][2][index]['observation']['rows']
    after = native['after'][2][index]['observation']['rows']
    assert [r['label'] for r in before] == [r['label'] for r in after]
    assert [r['native'] for r in before] == [r['native'] for r in after], 'every original ordinary native row'
    if index == 1:
        for row in after:
            options = row['options']
            expected = [{'key': c['key'], 'generation': c['generation'], 'number': c['number'],
                'actual_callback': 1, 'eligible': 1 if options.get('known') and c['generation'] == 0
                    and c['key'] == options.get('key') else 0} for c in row['authority']['calls']]
            assert row['authority']['calls'] == expected, 'actual scalar callback identity and own registration'
            assert row['authority']['parent_packet'] == 0, 'no enclosing packet donation'
            assert row['authority']['child_packets'] == 0, 'reference returns cannot retain scalar packets'
rows = {r['label']: r['native'] for r in native['before'][2][1]['observation']['rows']}
marker = rows['ordinary/switch_marker/scalar']
assert marker['branch_after']['fields']['switch_counter'] == 4
assert len(marker['branch_after']['fields']['switch_stack']['items']) == 1
bypass = rows['ordinary/switch_inline/scalar']
assert len([c for c in bypass['calls'] if c['key'] == 'normalize_method_args_with_optional_scope']) == 2
assert not bypass['branch_after']['fields']['switch_stack']['items']
rejected = rows['ordinary/default_bad_action/scalar']
assert rejected['result'] is None and rejected['branch_after']['fields']['switch_stack']['items'][0]['fields']['default_seen'] == 1
assert rows['ordinary/endcase_open/scalar']['branch_after']['fields']['switch_stack']['items'][0]['fields']['open_case'] == 0
assert rows['ordinary/endswitch_nested/scalar']['result'] == '} }'
assert len(rows['ordinary/endswitch_nested/scalar']['branch_after']['fields']['switch_stack']['items']) == 1

pairs = {}
for stage in ('before', 'after'):
    record = load(stage + '.json')
    cap = capsule(stage + '-inputs.json.gz', record)
    expected = first_paths | {FIXTURE, PREFIX + 'run.py', PREFIX + 'before-native.json',
        PREFIX + 'before-native-data.json.gz', PREFIX + 'before-native-inputs.json.gz'}
    assert set(cap) == expected and len(cap) == 105
    assert record['producer_sha256'] == sha(raw(PREFIX + 'run.py'))
    assert decode(cap[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    data = packed(stage + '-channels.json.gz')
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-channels.json.gz'))
    assert len(data) == 2 and data[0]['returncode'] == 0
    assert channel(data[0], 'stderr') == (FIXTURE + ' syntax OK\n').encode()
    failures = tap(data[1], 1641)
    assert failures == record['failures'] and record['plan'] == record['assertions'] == 1641
    assert len(failures) == (273 if stage == 'before' else 0)
    assert record['controls'] == 1641 - len(failures) and bool(data[1]['returncode']) == bool(failures)
    if stage == 'after':
        assert not channel(data[1], 'stderr')
    pairs[stage] = (record, cap, data)
assert pairs['before'][1][FIXTURE] == pairs['after'][1][FIXTURE], 'identical paired fixture bytes/mode'

start = source.index(b'sub _bind_emission_dependency {\n')
end = source.index(b'\n1;', start)
helper = source[start:end]
variants = {'inverse': original_source}
for owner in OWNERS:
    a = source.index(('sub ' + owner + ' {\n').encode())
    b = source.index(b'\nsub ', a + 1)
    variants['bypass-' + owner] = source[:a] + source[a:b].replace(
        b'return _bind_emission_dependency($cb);', b'return $cb;', 1) + source[b:]
def helper_fault(name, value):
    variants[name] = source[:start] + value + source[end:]
helper_fault('opaque-wrapper-identity', helper.replace(b'_invoke_emission_dependency($callback, @_)', b'_invoke_emission_dependency(sub { return $callback->(@_) }, @_)', 1))
helper_fault('copied-argument-slots', helper.replace(b'return sub {\n', b'return sub {\n  my @args = @_;\n', 1).replace(b'($callback, @_)', b'($callback, @args)').replace(b'$callback->(@_)', b'$callback->(@args)'))
helper_fault('localized-error-effects', helper.replace(b'return sub {\n', b'return sub {\n  local $@;\n', 1))
helper_fault('twice-only-effects', helper.replace(b'return sub {\n', b'return sub {\n  $callback->(@_);\n', 1))
helper_fault('eager-emission-loading', helper.replace(b'return sub {\n', b'return sub {\n  require LinkedSpec::ActionIR::SourceEmissions;\n', 1))
for name, needle, replacement in (
    ('delayed-map-selection', b'return _bind_emission_dependency($cb);', b'return sub { return _bind_emission_dependency($deps->{$name})->(@_) };'),
    ('public-map-rebinding', b'return _bind_emission_dependency($cb);', b'return $deps->{$name} = _bind_emission_dependency($cb);'),
    ('disabled-required-validation', b"unless ref($cb) eq 'CODE';", b'if 0;'),
    ('copied-normalizer-array-return', b'return _bind_emission_dependency($cb);', b"return sub { my $value = _bind_emission_dependency($cb)->(@_); return ref($value) eq 'ARRAY' ? [@$value] : $value };")):
    value = source
    for owner in OWNERS:
        a = value.index(('sub ' + owner + ' {\n').encode())
        b = value.index(b'\nsub ', a + 1)
        value = value[:a] + value[a:b].replace(needle, replacement, 1) + value[b:]
    variants[name] = value
faults, fault_rows = load('faults-review.json'), packed('faults-reached.json.gz')
assert faults['producer_sha256'] == sha(raw(PREFIX + 'faults-review.py'))
assert faults['original_producer_sha256'] == sha(raw(PREFIX + 'faults.py'))
assert faults['positive_capsule_sha256'] == sha(raw(PREFIX + 'after-inputs.json.gz'))
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-reached.json.gz'))
assert faults['effective'] == 15 and faults['unobserved'] == ['copied-normalizer-array-return']
assert [r['name'] for r in fault_rows] == list(variants) and len(variants) == 16
assert len({sha(value) for value in variants.values()}) == 16
for row in fault_rows:
    assert decode(row['module_base64']) == variants[row['name']] and row['module_sha256'] == sha(variants[row['name']])
    assert row['unchanged'] and len(row['channels']) == 2 and row['channels'][0]['returncode'] == 0
    failures = tap(row['channels'][1], 1641)
    assert failures == row['failures'] and bool(failures) == bool(row['channels'][1]['returncode']) == (row['name'] != 'copied-normalizer-array-return')
    assert row['assertions'] == 1641 and row['plan'] == ['1641']
    if row['name'] == 'inverse':
        assert failures == pairs['before'][0]['failures'], 'exact inverse original273'
assert faults['variants'] == [{'name': r['name'], 'assertions': 1641, 'failures': len(r['failures']), 'module_sha256': r['module_sha256']} for r in fault_rows]
assert len(fault_rows[0]['failures']) == 273

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
assert len(seed_plans) == 84 and sum(n for _, n, _ in seed_plans) == 24959
consumer, cc, consumer_channel = load('consumers.json'), capsule('consumers-inputs.json.gz'), packed('consumers-channels.json.gz')
assert consumer['producer_sha256'] == sha(raw(PREFIX + 'consumers.py'))
assert consumer['capsule_sha256'] == sha(raw(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
assert consumer['inputs'] == {p: x['sha256'] for p, x in cc.items()}
assert consumer['modes'] == {p: x['mode'] for p, x in cc.items()}
expected = set(seed['inputs']) | complete_paths | {FIXTURE, PREFIX + 'before-native-data.json.gz', SEED, SEED_CHANNELS, PREFIX + 'consumers.py'}
assert set(cc) == expected, 'complete supplied consumer population'
assert consumer['command'] == consumer_channel['command'] == seed['command'] + [FIXTURE]
assert consumer['unchanged'] and consumer['returncode'] == consumer_channel['returncode'] == 0
assert decode(cc[MODULE]['bytes_base64']) == source
for path, digest in seed['inputs'].items():
    if path != MODULE:
        assert cc[path]['sha256'] == digest
plans = suite_plans(consumer_channel, consumer['command'][3:])
assert plans[:-1] == seed_plans and plans[-1][1:] == (1641, [])
assert len(plans) == 85 and sum(n for _, n, _ in plans) == 26600
assert consumer_channel['stderr_base64'] == seed_channel['stderr_base64'] and b'Result: PASS' in channel(consumer_channel, 'stdout')

k, kc = load('knowledge.json'), packed('knowledge-inputs.json.gz')
assert k['base'] == BASE and k['producer_sha256'] == sha(raw(PREFIX + 'knowledge.py'))
assert k['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-inputs.json.gz'))
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source_archive:
    original = {x.name: {'bytes_base64': base64.b64encode(source_archive.extractfile(x).read()).decode(), 'mode': x.mode}
                for x in source_archive if x.isfile() and x.name.endswith('.md')}
assert original == kc['original'] and len(original) == 1486
current = kc['current']
assert k['inputs'] == {p: {'sha256': x['sha256'], 'mode': x['mode']} for p, x in current.items()}
changed, body_changes, facts, knowledge_bytes = [], [], 0, 0
for path, item in current.items():
    payload = decode(item['bytes_base64'])
    assert sha(payload) == item['sha256']
    if path in original:
        before = decode(original[path]['bytes_base64'])
        facts += int(payload.startswith(b'---\n') and re.search(rb'^id: ', payload, re.M) is not None)
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
assert sorted(changed) == k['changed_cards'] and len(changed) == 12 and facts == 1349
assert body_changes == ['docs/knowledge/perl-factory-capture-framework.md']
assert knowledge_bytes == 8388218 <= 8388608
assert k['returncode'] == 0 and not channel(k, 'stdout')
assert channel(k, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
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
checkpoint_names = [
    'preserve.py', 'preservation.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.2.json',
    'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.2.json',
    'observe.py', 'before-native.json', 'before-native-inputs.json.gz', 'before-native-data.json.gz',
    'run.py', 'before.json', 'before-inputs.json.gz', 'before-channels.json.gz',
    'after.json', 'after-inputs.json.gz', 'after-channels.json.gz',
    'observe-after.py', 'after-native.json', 'after-native-inputs.json.gz', 'after-native-data.json.gz',
    'faults.py', 'faults-review.py', 'faults-review.json', 'faults-reached.json.gz',
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
    print('Switch preflight PASS: original463/full109061;630 ordinary rows;1641/273 RED/all GREEN;15 effective faults/one unobserved;85 consumer suites; Knowledge1486/1349/twelve;book89/four')
    raise SystemExit(0)
standard = load('compat.json')
assert standard['result'] == 'PASS' and len(standard['rows']) == 5
assert standard['producer_sha256'] == sha(raw(PREFIX + 'compat.py')) and all(r['returncode'] == 0 for r in standard['rows'])
assert b'Tests=1035' in channel(standard['rows'][-1], 'stdout') and b'Result: PASS' in channel(standard['rows'][-1], 'stdout')
components.append(component('validation.py'))
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review.py')),
    'inputs': {p: {'sha256': sha(raw(p)), 'mode': (ROOT / p).stat().st_mode & 0o7777} for p in sorted(inputs)},
    'components': components,
    'population': {'original_bindings': 463, 'original_publication_bytes': 109061,
        'native_inputs': 100, 'current_native_inputs': 105, 'warm_rows': 333, 'cold_rows': 297,
        'required_validators': 6, 'required_roles': 6, 'paired_assertions': 1641, 'original_red': 273,
        'passing_controls': 1368, 'source_faults': 15, 'unobserved_source_faults': 1, 'consumer_suites': 85, 'consumer_inputs': len(cc),
        'consumer_assertions': 26600, 'knowledge_markdown': 1486, 'knowledge_facts': 1349,
        'live_card_overlays': 12, 'knowledge_bytes': knowledge_bytes, 'book_inputs': 89, 'book_controls': 4},
    'limits': 'Only six required-validator returns change. Controlled injected dependencies delegate actual MethodExpr '
        'parsing but do not establish facade DSL execution. Required normalizers are scalar and return arrays; '
        'ordinary reference values cannot retain scalar packets. Global late-map/map-mutation/validation/'
        'faults use observed witnesses, not exhaustive per-owner mutations. Array-copy has no witness here. Current filesystem modes '
        'are guarded independently of historical tar permissions. Standard/public guard are supplemental without '
        'full transitive toolchain/input capsules. Later ControlFlow/default/direct/rule/pipeline and independent '
        'helper/private/parent/canonical admissions remain open.'}
value = (json.dumps(result, indent=2) + '\n').encode()
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value, 'exact independent full review'
print('Switch independent review PASS:630 ordinary rows;1641/273 RED/all GREEN;15 effective faults/one unobserved;85 consumer suites;original/Knowledge/book custody')
