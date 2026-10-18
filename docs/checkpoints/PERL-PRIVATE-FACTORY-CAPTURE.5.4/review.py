"""Readonly bounded output review; fixed preflight inventory excludes its result."""
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
BASE = '4a8e92aefba8a5ce8e83f6ff529685fe6f79c9cd'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
INSTRUMENT = 't/actionir_control_output_native_complete.pl'
FIXTURE = 't/actionir_control_output_capture.t'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/consumers.json'
SEED_CHANNELS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/consumers-channels.json.gz'
OWNERS = ('_lower_say_statement', '_lower_print_statement', '_lower_print_each_statement', '_lower_exit_now_statement')
FIRST = 't/actionir_control_output_native.pl'
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
assert set(selected) == {'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.3.json'} and len(preservation['selected']) == 1
entry = preservation['selected'][0]
payload, hits = selected[entry['path']]
assert raw(entry['before']) == payload, 'whole accepted publication custody'
assert entry['sha256'] == sha(payload) and entry['bytes'] == len(payload) == 111654
assert entry['intersections'] == hits and sum(h['bindings'] for h in hits) == 480
changed = json.loads(payload)
for hit in hits:
    changed['claims'][hit['claim_index']]['durability'].update(mode='historical', revision=BASE)
assert json.loads(raw(entry['path'])) == changed, 'only historical mode/revision changes'
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.3.json')
assert baseline in preservation['baselines'] and baseline['claim'] == entry['path']
assert baseline['command'] == ['bash', 'tools/run_python_project_data.sh',
                              'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/publish.py']
assert baseline['returncode'] == 0 and not channel(baseline, 'stderr')
assert channel(baseline, 'stdout') == b'ControlFlow switch publication PASS: 480 live inputs; 111654 bytes\n'
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
assert source == expected_source, 'only four original required-validator return lines change'
assert source.count(b'\n') == original_source.count(b'\n')
assert source.count(b'return _bind_emission_dependency($cb);') == 22
assert source.count(b'return $cb;') == original_source.count(b'return $cb;') - 4 == 0
parent_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'],
                                          cwd=ROOT, text=True).splitlines())
wrapper_paths = {'tools/project_data_env.sh', 'tools/project_data_run.sh',
                 'tools/run_python_project_data.sh', '.knowledge_map.conf'}
first_paths = parent_paths | wrapper_paths | {FIRST, PREFIX + 'observe.py'}
failed_record = load('before-native.json')
failed_cap = capsule('before-native-inputs.json.gz', failed_record)
assert set(failed_cap) == first_paths and len(failed_cap) == 100
assert decode(failed_cap[MODULE]['bytes_base64']) == original_source
assert failed_record['producer_sha256'] == sha(raw(PREFIX + 'observe.py'))
failed_data = packed('before-native-data.json.gz')
assert failed_record['data_sha256'] == sha(raw(PREFIX + 'before-native-data.json.gz'))
assert len(failed_data) == 5 and failed_data[0]['returncode'] == 0
assert channel(failed_data[0], 'stderr') == (FIRST + ' syntax OK\n').encode()
for attempt in failed_data[1:]:
    assert attempt['returncode'] == 255 and not channel(attempt, 'stdout')
    assert channel(attempt, 'stderr') == ("duplicate native case exit_now_zero at " + FIRST + " line 65.\n").encode()
assert raw(INSTRUMENT) == raw(FIRST).replace(b' exit_now_zero =>', b' exit_now_status_zero =>', 1)
complete_paths = first_paths | {INSTRUMENT, PREFIX + 'observe-complete.py',
    PREFIX + 'before-native.json', PREFIX + 'before-native-inputs.json.gz', PREFIX + 'before-native-data.json.gz'}
after_paths = complete_paths | {PREFIX + 'after.json', PREFIX + 'observe-after.py',
    PREFIX + 'before-complete-native.json', PREFIX + 'before-complete-native-inputs.json.gz',
    PREFIX + 'before-complete-native-data.json.gz'}
native = {}
for stem, producer, instrument, paths, counts in (
    ('before-complete', 'observe-complete.py', INSTRUMENT, complete_paths, (234, 198)),
    ('after', 'observe-after.py', INSTRUMENT, after_paths, (234, 198))):
    record = load(stem + '-native.json')
    cap = capsule(stem + '-native-inputs.json.gz', record)
    assert set(cap) == paths, 'complete native runtime namespace'
    assert len(cap) == {'before-complete': 105, 'after': 110}[stem]
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
        assert all(c['context'] == 'scalar' for c in calls)
        assert len(calls) == (701 if index < 3 else 539)
    assert data[1] == data[2] and data[3] == data[4], 'exact fresh-process recurrence'
    native[stem] = (record, cap, data)
for index in (1, 3):
    before = native['before-complete'][2][index]['observation']['rows']
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
            matching = bool(options.get('known') and options.get('authority') and any(c['key'] == options.get('key') and c['generation'] == 0 and c['number'] == options.get('number', 1) and c['value'] == 'outer' for c in row['native']['callback_returns']))
            assert row['authority']['child_packets'] == int(matching), 'only actual matching scalar child packet'
rows = {r['label']: r['native'] for r in native['before-complete'][2][1]['observation']['rows']}
trimmed = rows['ordinary/print_each_symbol/scalar']
assert next(c for c in trimmed['calls'] if c['key'] == 'trim_action_ir_value' and c['number'] == 1)['first_is_parser_element_cell'] == 1
extract = next(c for c in trimmed['calls'] if c['key'] == 'extract_array_symbol_name')
assert extract['args'][1]['id'] == trimmed['before']['map']['id']
assert "'OutputRule'" in trimmed['result']
legacy = rows['ordinary/print_each_legacy/scalar']
assert ", '', 'print_each'," in legacy['result']

pairs = {}
for stage in ('before', 'after'):
    record = load(stage + '.json')
    cap = capsule(stage + '-inputs.json.gz', record)
    expected = complete_paths | {FIXTURE, PREFIX + 'run.py', PREFIX + 'before-complete-native.json',
        PREFIX + 'before-complete-native-data.json.gz', PREFIX + 'before-complete-native-inputs.json.gz'}
    assert set(cap) == expected and len(cap) == 110
    assert record['producer_sha256'] == sha(raw(PREFIX + 'run.py'))
    assert decode(cap[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    data = packed(stage + '-channels.json.gz')
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-channels.json.gz'))
    assert len(data) == 2 and data[0]['returncode'] == 0
    assert channel(data[0], 'stderr') == (FIXTURE + ' syntax OK\n').encode()
    failures = tap(data[1], 1146)
    assert failures == record['failures'] and record['plan'] == record['assertions'] == 1146
    assert len(failures) == (264 if stage == 'before' else 0)
    assert record['controls'] == 1146 - len(failures) and bool(data[1]['returncode']) == bool(failures)
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
    ('disabled-required-validation', b"unless ref($cb) eq 'CODE';", b'if 0;')):
    value = source
    for owner in OWNERS:
        a = value.index(('sub ' + owner + ' {\n').encode())
        b = value.index(b'\nsub ', a + 1)
        value = value[:a] + value[a:b].replace(needle, replacement, 1) + value[b:]
    variants[name] = value
faults, fault_rows = load('faults.json'), packed('faults-data.json.gz')
assert faults['producer_sha256'] == sha(raw(PREFIX + 'faults.py'))
assert faults['positive_capsule_sha256'] == sha(raw(PREFIX + 'after-inputs.json.gz'))
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-data.json.gz'))
assert fault_rows == packed('faults-reached.json.gz')
assert [r['name'] for r in fault_rows] == list(variants) and len(variants) == 13
assert len({sha(value) for value in variants.values()}) == 13
for row in fault_rows:
    assert decode(row['module_base64']) == variants[row['name']] and row['module_sha256'] == sha(variants[row['name']])
    assert row['unchanged'] and len(row['channels']) == 2 and row['channels'][0]['returncode'] == 0
    failures = tap(row['channels'][1], 1146)
    assert failures == row['failures'] and failures and row['channels'][1]['returncode'] != 0
    assert row['assertions'] == 1146 and row['plan'] == ['1146']
    if row['name'] == 'inverse':
        assert failures == pairs['before'][0]['failures'], 'exact inverse original264'
assert faults['variants'] == [{'name': r['name'], 'assertions': 1146, 'failures': len(r['failures']), 'module_sha256': r['module_sha256']} for r in fault_rows]
assert len(fault_rows[0]['failures']) == 264

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
assert len(seed_plans) == 85 and sum(n for _, n, _ in seed_plans) == 26600
consumer, cc, consumer_channel = load('consumers.json'), capsule('consumers-inputs.json.gz'), packed('consumers-channels.json.gz')
assert consumer['producer_sha256'] == sha(raw(PREFIX + 'consumers.py'))
assert consumer['capsule_sha256'] == sha(raw(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
assert consumer['inputs'] == {p: x['sha256'] for p, x in cc.items()}
assert consumer['modes'] == {p: x['mode'] for p, x in cc.items()}
expected = set(seed['inputs']) | complete_paths | {FIXTURE, PREFIX + 'before-complete-native-data.json.gz', SEED, SEED_CHANNELS, PREFIX + 'consumers.py', 'bin/linkedspec', 't/diagnostic_output_perl_contract.t', 'capability_conformance/diagnostic_output_contract.json'}
assert set(cc) == expected, 'complete supplied consumer population'
assert consumer['command'] == consumer_channel['command'] == seed['command'] + ['t/diagnostic_output_perl_contract.t', FIXTURE]
assert consumer['unchanged'] and consumer['returncode'] == consumer_channel['returncode'] == 0
assert decode(cc[MODULE]['bytes_base64']) == source
for path, digest in seed['inputs'].items():
    if path != MODULE:
        assert cc[path]['sha256'] == digest
plans = suite_plans(consumer_channel, consumer['command'][3:])
assert plans[:-2] == seed_plans and plans[-2][1:] == (16, []) and plans[-1][1:] == (1146, [])
assert len(plans) == 87 and sum(n for _, n, _ in plans) == 27762
assert consumer_channel['stderr_base64'] == seed_channel['stderr_base64'] and b'Result: PASS' in channel(consumer_channel, 'stdout')

diagnostic_capsules = {}
for stage in ('before', 'after'):
    diagnostic = load(stage + '-diagnostics.json')
    dc = capsule(stage + '-diagnostics-inputs.json.gz')
    expected = set(seed['inputs']) | complete_paths | {SEED, 'bin/linkedspec',
        't/diagnostic_output_perl_contract.t', 'capability_conformance/diagnostic_output_contract.json', PREFIX + 'diagnostics.py'}
    assert set(dc) == expected and len(dc) == 329
    assert diagnostic['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in dc.items()}
    assert diagnostic['inputs_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-inputs.json.gz'))
    assert decode(dc[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    assert diagnostic['producer_sha256'] == sha(raw(PREFIX + 'diagnostics.py'))
    actual_channel = packed(stage + '-diagnostics-channels.json.gz')
    assert diagnostic['channels_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-channels.json.gz'))
    assert diagnostic['command'] == actual_channel['command'] == ['prove', '-v', '-Iperl', 't/diagnostic_output_perl_contract.t']
    assert diagnostic['returncode'] == actual_channel['returncode'] == 0 and not channel(actual_channel, 'stderr')
    assert suite_plans(actual_channel, ['t/diagnostic_output_perl_contract.t']) == [('t/diagnostic_output_perl_contract.t', 16, [])]
    diagnostic_capsules[stage] = dc
assert {p: item for p, item in diagnostic_capsules['before'].items() if p != MODULE} == {
    p: item for p, item in diagnostic_capsules['after'].items() if p != MODULE}

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
assert knowledge_bytes == 8388501 <= 8388608
assert k['returncode'] == 0 and not channel(k, 'stdout')
assert channel(k, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
components = [component('book-review.py'), component('group-review.py')]
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
assert all(sha(raw(p)) == digest for p, digest in book['source_inputs'].items())
inputs.update(book['source_inputs'])
assert raw('doctrine/readme_stability/routes.jsonl') == old('doctrine/readme_stability/routes.jsonl')
validation = load('validation.json')
assert all(sha(raw(p)) == digest for p, digest in validation['sources'].items())
inputs.update(validation['sources'])
inputs.update((MODULE, FIXTURE, FIRST, INSTRUMENT, SEED, SEED_CHANNELS, 'doctrine/readme_stability/routes.jsonl'))
checkpoint_names = [
    'preserve.py', 'preservation.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.3.json',
    'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.3.json',
    'observe.py', 'before-native.json', 'before-native-inputs.json.gz', 'before-native-data.json.gz',
    'observe-complete.py', 'before-complete-native.json', 'before-complete-native-inputs.json.gz', 'before-complete-native-data.json.gz',
    'run.py', 'before.json', 'before-inputs.json.gz', 'before-channels.json.gz',
    'after.json', 'after-inputs.json.gz', 'after-channels.json.gz',
    'observe-after.py', 'after-native.json', 'after-native-inputs.json.gz', 'after-native-data.json.gz',
    'faults.py', 'faults.json', 'faults-data.json.gz', 'faults-reached.json.gz',
    'consumers.py', 'consumers.json', 'consumers-inputs.json.gz', 'consumers-channels.json.gz',
    'diagnostics.py', 'before-diagnostics.json', 'before-diagnostics-inputs.json.gz', 'before-diagnostics-channels.json.gz',
    'after-diagnostics.json', 'after-diagnostics-inputs.json.gz', 'after-diagnostics-channels.json.gz',
    'group-review.py', 'group-observation.json', 'group-observation-source.json.gz',
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
    print('Output preflight PASS: original480/full111654;432 ordinary rows;1146/264 RED/all GREEN;13 effective faults;87 consumer suites; Knowledge1486/1349/twelve;book89/four')
    raise SystemExit(0)
standard = load('compat.json')
assert standard['result'] == 'PASS' and len(standard['rows']) == 5
assert standard['producer_sha256'] == sha(raw(PREFIX + 'compat.py')) and all(r['returncode'] == 0 for r in standard['rows'])
assert b'Tests=1035' in channel(standard['rows'][-1], 'stdout') and b'Result: PASS' in channel(standard['rows'][-1], 'stdout')
components.append(component('validation.py'))
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review.py')),
    'inputs': {p: {'sha256': sha(raw(p)), 'mode': (ROOT / p).stat().st_mode & 0o7777} for p in sorted(inputs)},
    'components': components,
    'population': {'original_bindings': 480, 'original_publication_bytes': 111654,
        'native_inputs': 105, 'current_native_inputs': 110, 'warm_rows': 234, 'cold_rows': 198,
        'required_validators': 4, 'required_roles': 6, 'diagnostic_inputs': 329, 'diagnostic_top_level_assertions': 16, 'paired_assertions': 1146, 'original_red': 264,
        'passing_controls': 882, 'source_faults': 13, 'consumer_suites': 87, 'consumer_inputs': len(cc),
        'consumer_assertions': 27762, 'knowledge_markdown': 1486, 'knowledge_facts': 1349,
        'live_card_overlays': 12, 'knowledge_bytes': knowledge_bytes, 'book_inputs': 89, 'book_controls': 4},
    'limits': 'Only four validator return lines change. First failed inventory guard and exact one-label '
        'correction remain retained. Controlled native dependencies are not facade execution; the separate '
        'public diagnostic suite supplies native/generated/CLI coverage. Source faults use observed witnesses, '
        'not exhaustive per-owner mutation coverage. Current warning sample is historical supplementary '
        'diagnostics with lifecycle/cause limits owned by startup.7. Standard/public guards lack full '
        'transitive capsules; broader helper/private/parent/canonical admissions remain open.'}
value = (json.dumps(result, indent=2) + '\n').encode()
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value, 'exact independent full review'
print('Output independent review PASS:432 ordinary rows;1146/264 RED/all GREEN;13 effective faults;87 consumer suites;original/Knowledge/book custody')
