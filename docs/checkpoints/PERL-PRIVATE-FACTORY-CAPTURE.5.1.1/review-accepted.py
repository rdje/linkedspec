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
BASE = 'a4a9e5c503460a8bd7db06e57b827dd053724d00'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
INSTRUMENT = 't/actionir_control_attached_native_fixed.pl'
FIRST = 't/actionir_control_attached_native.pl'
FIXTURE = 't/actionir_control_attached_capture.t'
OWNER = '_parse_method_expr_with_optional_attached_block'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/consumers.json'
SEED_CHANNELS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/consumers-channels.json.gz'
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


def capsule(name, record=None, archived=False):
    value = packed(name)
    for path, item in value.items():
        payload = base64.b64decode(item['bytes_base64'], validate=True)
        assert sha(payload) == item['sha256'], ('complete capsule identity', name, path)
        if path == MODULE:
            continue
        current = PREFIX + 'instrument-first.txt' if archived and path == FIRST else path
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
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json': (456, 108786,
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/publish.py',
        b'ControlFlow expansion publication PASS: 456 live inputs; 108786 bytes\n'),
    'docs/claims/REPO-HYGIENE.17.json': (22, 9417,
        'docs/checkpoints/REPO-HYGIENE.17-claim.py',
        b'Retention claim readonly identity PASS: 22 inputs; 9417 bytes\n'),
}
assert set(selected) == set(expected_prior) and len(preservation['selected']) == 2
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

first_failure = load('first-review-failure.json')
assert first_failure['producer_sha256'] == sha(raw(PREFIX + 'diagnose-review.py'))
assert first_failure['original_reader_sha256'] == sha(raw(PREFIX + 'review.py'))
assert first_failure['first_outer_session'] == 53072 and first_failure['first_outer_returncode'] == 1
assert first_failure['only_historical_mode_revision'] is True
assert set(first_failure['changed_unowned_inputs']) == {'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json'}
assert first_failure['replay']['command'] == ['python3', PREFIX + 'review.py', '--preflight']
assert first_failure['replay']['returncode'] == 1 and b'AssertionError: unchanged unowned predecessor input' in channel(first_failure['replay'], 'stderr')
for path, identities in first_failure['changed_unowned_inputs'].items():
    assert identities['original_sha256'] == sha(old(path)) and identities['current_sha256'] == sha(raw(path))

incomplete = load('first-evidence-failure.json')
assert incomplete['producer_sha256'] == sha(raw(PREFIX + 'diagnose-evidence.py'))
assert incomplete['first_evidence_producer_sha256'] == sha(raw(PREFIX + 'evidence.py'))
assert incomplete['first_review_producer_sha256'] == sha(raw(PREFIX + 'review-final.py'))
assert incomplete['first_full_review_sha256'] == sha(raw(PREFIX + 'review-final.json'))
assert incomplete['first_outer_session'] == 97648 and incomplete['first_outer_returncode'] == 1
first_full = load('review-final.json')
assert first_full['result'] == 'PASS' and first_full['producer_sha256'] == sha(raw(PREFIX + 'review-final.py'))
first_inputs = dict(first_full['inputs'])
first_inputs[PREFIX + 'evidence.py'] = {'sha256': sha(raw(PREFIX + 'evidence.py')), 'mode': (ROOT / (PREFIX + 'evidence.py')).stat().st_mode & 0o7777}
assert incomplete['inputs'] == first_inputs and len(first_inputs) == 449
historical_reads = set()
for path, (payload, _) in selected.items():
    for claim in json.loads(payload)['claims']:
        historical_reads.update(x['path'] for x in claim['durability']['inputs'] if x['path'] not in owned and x['path'] not in selected)
assert incomplete['undeclared_historical_live_reads'] == sorted(historical_reads - set(first_inputs))
assert len(incomplete['undeclared_historical_live_reads']) == 78
assert incomplete['replay']['returncode'] == 1 and incomplete['replay']['unchanged']
missing_alias = b'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-match-alias.json'
assert b'FileNotFoundError' in channel(incomplete['replay'], 'stderr') and missing_alias in channel(incomplete['replay'], 'stderr')
reported = load('first-evidence-reported.json')
assert reported['outer_session'] == 97648 and reported['outer_returncode'] == 1
assert reported['original_producer_sha256'] == sha(raw(PREFIX + 'evidence.py'))
assert reported['reported_child']['command'] == ['python3', PREFIX + 'review-final.py', '--preflight'] and reported['reported_child']['returncode'] == 1
assert not channel(reported['reported_child'], 'stdout')
reported_stderr = channel(reported['reported_child'], 'stderr')
assert sha(reported_stderr) == reported['stderr_sha256'] and len(reported_stderr) == reported['stderr_bytes']
assert b'FileNotFoundError' in reported_stderr and missing_alias in reported_stderr

original_source, source = old(MODULE), raw(MODULE)
a = original_source.index(('sub ' + OWNER + ' {\n').encode())
b = original_source.index(b'\nsub ', a + 1)
body = original_source[a:b]
assert body.count(b'return $cb;') == 1
expected_source = original_source[:a] + body.replace(b'return $cb;', b'return _bind_emission_dependency($cb);', 1) + original_source[b:]
assert source == expected_source, 'only the original parser validator return changes'
assert source.count(b'return _bind_emission_dependency($cb);') == 5
assert source.count(b'return $cb;') == original_source.count(b'return $cb;') - 1 == 17
assert re.findall(rb"\$require_dep->\('([a-z_]+)'\)", body) == [b'trim_action_ir_value', b'parse_method_function_expr']
assert b'$trim_action_ir_value->(substr($trimmed, 0, $idx))' in body
parent_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines())
wrapper_paths = {'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', '.knowledge_map.conf'}

# The rejected first instrument is retained byte-exact, outside test discovery.
first_record = load('before-native.json')
first_cap = capsule('before-native-inputs.json.gz', first_record, archived=True)
assert set(first_cap) == parent_paths | wrapper_paths | {FIRST, PREFIX + 'observe.py'}
assert base64.b64decode(first_cap[MODULE]['bytes_base64']) == original_source
assert first_record['producer_sha256'] == sha(raw(PREFIX + 'observe.py'))
first_data = packed('before-native-data.json.gz')
assert first_record['data_sha256'] == sha(raw(PREFIX + 'before-native-data.json.gz'))
assert len(first_data) == 5 and all(r['returncode'] == 255 and not channel(r, 'stdout') for r in first_data)
assert all(b'line 67' in channel(r, 'stderr') and b'compilation errors' in channel(r, 'stderr') for r in first_data)
archive = load('instrument-first-archive.json')
assert archive['producer_sha256'] == sha(raw(PREFIX + 'archive-first.py'))
assert archive['original_path'] == FIRST and archive['archive_path'] == PREFIX + 'instrument-first.txt'
assert archive['source_sha256'] == sha(raw(archive['archive_path'])) == first_cap[FIRST]['sha256']
assert archive['source_bytes'] == len(raw(archive['archive_path'])) and archive['mode'] == first_cap[FIRST]['mode']
assert archive['original_capsule_sha256'] == sha(raw(PREFIX + 'before-native-inputs.json.gz'))
assert not (ROOT / FIRST).exists(), 'invalid retired instrument stays outside executable discovery'
first_text = raw(archive['archive_path']).decode()
fixed_text = first_text.replace(r'input => q{foo("a\"{b") { body }},', r'input => q!foo("a\"{b") { body }!,', 1)
fixed_text = fixed_text.replace('authority => [], effects => [], counts => {}, args => $case->{parts} || []};',
    'authority => [], effects => [], counts => {}, held => [], returns => [], return_refs => [], args => $case->{parts} || []};', 1)
assert raw(INSTRUMENT).decode() == fixed_text, 'distinct fixed instrument has only declared pre-observation edits'

native = {}
for stage, stem, producer in [('before', 'before-fixed', 'observe-fixed.py'), ('after', 'after', 'observe-after.py')]:
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
        assert len(set(labels)) == len(labels) == (188 if index < 3 else 156)
        calls = [c for r in obs['rows'] for c in r['native']['calls']]
        assert len(calls) == (632 if index < 3 else 478) and all(c['context'] == 'scalar' for c in calls)
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
            assert row['authority']['child_packets'] == (1 if row['label'] == 'retained-child/1' else 0), 'only own matching child packet'
rows_by_label = {r['label']: r for r in native['before'][2][1]['observation']['rows']}
head = rows_by_label['effect/parse/trim_action_ir_value/2/mutate']['native']
slots = {x['fields']['key'] + '/' + str(x['fields']['number']): x['fields']['slot'] for x in head['held_slots']['items']}
assert slots['trim_action_ir_value/2']['type'] == 'LVALUE'
assert slots['parse_method_function_expr/1']['value'] == 'foo() !{ first; second }'
assert head['effects'] == [{'key': 'trim_action_ir_value', 'after': 'foo() !'}]
assert head['calls'][-1]['first_readonly'] == 0, 'native writable substring alias'
typed = rows_by_label['ordinary/typed_if/scalar']['native']
assert typed['calls'][0]['args'] == ['if(true) { cat("λ😀") }']
assert typed['result']['fields']['attached_block'] == '{ cat("λ😀") }', 'typed source_method preservation'
for name, kind in [('array', 'ARRAY'), ('blessed', 'ControlAttachedNative::Call'), ('code', 'CODE')]:
    assert rows_by_label['ordinary/return_' + name + '/scalar']['native']['result']['fields']['call']['type'] == kind
assert rows_by_label['ordinary/return_one/scalar']['native']['result']['fields']['call'] == 1

pairs = {}
for stage in ('before', 'after'):
    record = load(stage + '.json')
    cap = capsule(stage + '-inputs.json.gz', record)
    expected = set(native['before'][1]) | {FIXTURE, PREFIX + 'run.py', PREFIX + 'before-fixed-native.json',
        PREFIX + 'before-fixed-native-data.json.gz', PREFIX + 'before-fixed-native-inputs.json.gz'}
    assert set(cap) == expected and len(cap) == 105
    assert record['producer_sha256'] == sha(raw(PREFIX + 'run.py'))
    assert base64.b64decode(cap[MODULE]['bytes_base64']) == (original_source if stage == 'before' else source)
    data = packed(stage + '-channels.json.gz')
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-channels.json.gz'))
    assert len(data) == 2 and data[0]['returncode'] == 0 and channel(data[0], 'stderr') == (FIXTURE + ' syntax OK\n').encode()
    failures = tap(data[1], 920)
    assert failures == record['failures'] and record['plan'] == record['assertions'] == 920
    assert len(failures) == (194 if stage == 'before' else 0)
    assert record['controls'] == 920 - len(failures) and bool(data[1]['returncode']) == bool(failures)
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
    failures = tap(data[1], 920)
    assert failures == row['failures'] and failures and data[1]['returncode'] != 0
    assert row['assertions'] == 920 and row['plan'] == ['920']
    if row['name'] == 'inverse':
        assert failures == pairs['before'][0]['failures'], 'exact inverse original194'
assert faults['variants'] == [{'name': r['name'], 'assertions': 920, 'failures': len(r['failures']), 'module_sha256': r['module_sha256']} for r in fault_rows]
copy_row = next(r for r in fault_rows if r['name'] == 'copied-argument-slots')
for mode in ('warm', 'cold'):
    assert mode + '/effect/parse/trim_action_ir_value/2/mutate preserves complete native arguments/context/maps/values/effects/errors' in {r['name'] for r in copy_row['failures']}, 'actual substring-alias copy fault'

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
assert len(seed_plans) == 81 and sum(n for _, n, _ in seed_plans) == 21850
consumer = load('consumers.json')
cc = capsule('consumers-inputs.json.gz')
consumer_channel = packed('consumers-channels.json.gz')
assert consumer['producer_sha256'] == sha(raw(PREFIX + 'consumers.py'))
assert consumer['capsule_sha256'] == sha(raw(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
assert consumer['inputs'] == {p: x['sha256'] for p, x in cc.items()} and consumer['modes'] == {p: x['mode'] for p, x in cc.items()}
expected = set(seed['inputs']) | set(native['before'][1]) | {FIXTURE, PREFIX + 'before-fixed-native-data.json.gz', SEED, SEED_CHANNELS, PREFIX + 'consumers.py'}
assert set(cc) == expected and len(cc) == 291, 'complete supplied consumer population'
assert consumer['command'] == consumer_channel['command'] == seed['command'] + [FIXTURE]
assert consumer['unchanged'] and consumer['returncode'] == consumer_channel['returncode'] == 0
assert base64.b64decode(cc[MODULE]['bytes_base64']) == source
for path, digest in seed['inputs'].items():
    if path != MODULE:
        assert cc[path]['sha256'] == digest
plans = suite_plans(consumer_channel, consumer['command'][3:])
assert plans[:-1] == seed_plans and plans[-1][1:] == (920, [])
assert len(plans) == 82 and sum(n for _, n, _ in plans) == 22770
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
assert knowledge_bytes == 8387239 <= 8388608
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
    'preserve.py', 'preservation.json',
    'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json', 'before-REPO-HYGIENE.17.json',
    'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json', 'baseline-REPO-HYGIENE.17.json',
    'observe.py', 'before-native.json', 'before-native-inputs.json.gz', 'before-native-data.json.gz',
    'archive-first.py', 'instrument-first.txt', 'instrument-first-archive.json',
    'observe-fixed.py', 'before-fixed-native.json', 'before-fixed-native-inputs.json.gz', 'before-fixed-native-data.json.gz',
    'run.py', 'before.json', 'before-inputs.json.gz', 'before-channels.json.gz',
    'after.json', 'after-inputs.json.gz', 'after-channels.json.gz',
    'observe-after.py', 'after-native.json', 'after-native-inputs.json.gz', 'after-native-data.json.gz',
    'faults.py', 'faults.json', 'faults-data.json.gz', 'faults-reached.json.gz',
    'consumers.py', 'consumers.json', 'consumers-inputs.json.gz', 'consumers-channels.json.gz',
    'knowledge.py', 'knowledge.json', 'knowledge-inputs.json.gz',
    'book.py', 'book.json', 'book-review.py', 'book-review.json',
    'compat.py', 'validation.py', 'validation.json', 'review.py', 'review-final.py',
    'diagnose-review.py', 'first-review-failure.json', 'review-final.json',
    'review-accepted.py', 'evidence.py', 'diagnose-evidence.py',
    'first-evidence-failure.json', 'first-evidence-reported.json',
]
inputs.update(PREFIX + name for name in checkpoint_names)
assert all((ROOT / p).is_file() and not (ROOT / p).is_symlink() for p in inputs)
if sys.argv[1:] == ['--inventory']:
    print(json.dumps(sorted(inputs)))
    raise SystemExit(0)
if preflight:
    print('Attached parser preflight PASS: two original publications/478 bindings; native100/188/156;920/194 RED;10 fault cases/9 sources;82/291/22770; Knowledge1485/1349/ten; book89/four')
    raise SystemExit(0)
standard = load('compat.json')
assert standard['result'] == 'PASS' and len(standard['rows']) == 5
assert standard['producer_sha256'] == sha(raw(PREFIX + 'compat.py')) and all(r['returncode'] == 0 for r in standard['rows'])
assert b'Tests=1035' in channel(standard['rows'][-1], 'stdout') and b'Result: PASS' in channel(standard['rows'][-1], 'stdout')
components.append(component('validation.py'))
result = {
    'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review-accepted.py')),
    'inputs': {p: {'sha256': sha(raw(p)), 'mode': (ROOT / p).stat().st_mode & 0o7777} for p in sorted(inputs)},
    'components': components,
    'population': {'original_publications': 2, 'original_bindings': 478, 'original_publication_bytes': [108786, 9417],
        'native_inputs': 100, 'warm_rows': 188, 'cold_rows': 156, 'ordinary_rows': 344,
        'required_validators': 1, 'required_roles': 2, 'paired_assertions': 920, 'original_red': 194,
        'passing_controls': 726, 'source_fault_cases': 10, 'distinct_fault_sources': 9,
        'consumer_suites': 82, 'consumer_inputs': 291, 'consumer_assertions': 22770,
        'knowledge_markdown': 1485, 'knowledge_facts': 1349, 'live_card_overlays': 10,
        'knowledge_bytes': knowledge_bytes, 'book_inputs': 89, 'book_controls': 4},
    'limits': 'Original/current complete ordinary rows and fresh-process recurrences are exact. Nested marker trims '
              'were already isolated; parser calls and head trim now receive their actual scalar frames. The native '
              'head LVALUE/shared mutation, call/argument references, typed source_method reconstruction and truthy '
              'injected results remain unchanged. The first invalid quoted instrument and every actual compiler '
              'channel remain recoverable; the distinct fixed instrument is the first executable native ledger. '
              'The first reader incorrectly required the deliberately historical callback claim to keep its live bytes; '
              'its unchanged rejection and distinct mode/revision-only repair remain retained. '
              'The next root-only PASS still read78 historical live paths outside its449-file supplied inventory; '
              'the first artifact baseline and exact reported child channels plus a fresh readonly replay retain that RED. '
              'This accepted reader resolves all478 predecessor bindings only through accepted Git; current runtime inputs use the new capsules. '
              'Ten fault cases have nine distinct source byte variants because inverse and sole-validator bypass '
              'are identical. Complete dated Knowledge and two original publications retain accepted Git custody. '
              'Standard/public guard are supplemental without complete transitive toolchain/input capsules. '
              'Later ControlFlow/default/pipeline and independent helper/private/parent/canonical admissions stay open.',
}
value = (json.dumps(result, indent=2) + '\n').encode()
target = ROOT / (PREFIX + 'review-accepted.json')
if sys.argv[1:] == ['--capture']:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value, 'exact independent full review'
print('Attached parser independent review PASS:344 ordinary rows;920/194 RED/all GREEN;10 cases/9 sources;82/291/22770; both original publications/Knowledge/book custody')
