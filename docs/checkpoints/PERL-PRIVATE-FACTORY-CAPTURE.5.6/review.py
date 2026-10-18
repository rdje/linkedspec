"""Readonly direct/rule evidence review; --capture freezes the report once."""
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
BASE = '2b35b77ea0e08d178ccb054a8f8310dbe0abb9c1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
EMISSIONS = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
FIXTURE = 't/actionir_control_calls_capture.t'
INSTRUMENT = 't/actionir_control_calls_native_complete.pl'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/consumers.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
inputs = set()
assert sys.argv[1:] in ([], ['--capture'])


def raw(path):
    inputs.add(path)
    return (ROOT / path).read_bytes()


def load(name):
    return json.loads(raw(PREFIX + name))


def packed(name):
    return json.loads(gzip.decompress(raw(PREFIX + name)))


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def capsule(name, record=None, historical=False, legacy_fixture=False):
    value = packed(name)
    if record is not None:
        assert record['capsule_sha256'] == sha(raw(PREFIX + name))
        assert record['inputs'] == {p: {k: x[k] for k in ('sha256', 'mode')} for p, x in value.items()}
    for path, item in value.items():
        payload = decode(item['bytes_base64'])
        assert sha(payload) == item['sha256'], ('capsule payload', name, path)
        if historical and path == MODULE:
            assert payload == old(path)
        elif legacy_fixture and path == FIXTURE:
            assert payload == raw(PREFIX + 'first-fixture.t'), 'original first fixture custody'
        else:
            assert raw(path) == payload, ('current supplied input', name, path)
            assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    return value


def tap(row):
    text = decode(row['stdout_base64']).decode()
    rows = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == [str(len(rows))]
    assert [int(n) for _, n, _ in rows] == list(range(1, len(rows) + 1))
    assert not re.search(r'^Bail out!', text, re.M)
    return len(rows), [{'number': int(n), 'name': title} for bad, n, title in rows if bad]


preservation = load('preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha(raw(PREFIX + 'preserve.py'))
claim_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                     cwd=ROOT, text=True).splitlines()
census, selected = [], []
for path in sorted(claim_paths):
    payload = old(path)
    record = json.loads(payload)
    hits = []
    for i, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        overlap = sorted(set(preservation['owned_bound_paths']) & {x['path'] for x in durability['inputs']})
        if overlap:
            assert all(sha(old(x['path'])) == x['sha256'] for x in durability['inputs'])
            hits.append({'claim_index': i, 'paths': overlap, 'bindings': len(durability['inputs'])})
    census.append({'path': path, 'sha256': sha(payload), 'intersections': hits})
    if hits:
        selected.append(path)
        assert path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.5.json'
        assert raw(PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.5.json') == payload, 'whole prior publication custody'
        assert len(payload) == 116166 and len(record['claims']) == 1
        expected = copy.deepcopy(record)
        for hit in hits:
            expected['claims'][hit['claim_index']]['durability'].update(mode='historical', revision=BASE)
        assert json.loads(raw(path)) == expected, 'only affected historical mode/revision'
assert census == preservation['census'] and selected == [x['path'] for x in preservation['selected']]
assert len(selected) == 1 and preservation['selected'][0]['intersections'][0]['bindings'] == 506
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.5.json')
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Optional-kind publication PASS: 506 live inputs; 116166 bytes\n'
assert preservation['baselines'] == [baseline]

first_native = load('before-native.json')
capsule('before-native-inputs.json.gz', first_native, historical=True)
first_data = packed('before-native-data.json.gz')
original_native = load('before-complete-native.json')
original_inputs = capsule('before-complete-native-inputs.json.gz', original_native, historical=True)
original = packed('before-complete-native-data.json.gz')
current_native = load('after-native.json')
capsule('after-native-inputs.json.gz', current_native)
current = packed('after-native-data.json.gz')
for record, observations, stem, producer, instrument, count in (
    (first_native, first_data, 'before-native', 'observe.py', 't/actionir_control_calls_native.pl', 210),
    (original_native, original, 'before-complete-native', 'observe-complete.py', INSTRUMENT, 213),
    (current_native, current, 'after-native', 'observe-after-corrected.py', INSTRUMENT, 213)):
    assert record['producer_sha256'] == sha(raw(PREFIX + producer))
    assert record['instrument_sha256'] == sha(raw(instrument))
    assert record['data_sha256'] == sha(raw(PREFIX + stem + '-data.json.gz'))
    assert len(observations) == 5 and all(x['returncode'] == 0 for x in observations)
    assert observations[1] == observations[2] and observations[3] == observations[4], 'native recurrence'
    assert not decode(observations[0]['stdout_base64'])
    assert decode(observations[0]['stderr_base64']) == (instrument + ' syntax OK\n').encode()
    for i in (1, 3):
        assert not decode(observations[i]['stderr_base64'])
        observed = observations[i]['observation']
        assert json.loads(decode(observations[i]['stdout_base64'])) == observed, 'native raw/parsed channel agreement'
        assert len(observed['rows']) == count == len({x['label'] for x in observed['rows']})
        assert observed['emission_loaded'] == (1 if i == 1 else 0) and observed['trace_loaded'] == 0
        assert set(observed['loaded_project_modules']) <= set(original_inputs)
for i in (1, 3):
    old_rows = first_data[i]['observation']['rows']
    old_labels = {r['label'] for r in old_rows}
    assert [r for r in original[i]['observation']['rows'] if r['label'] in old_labels] == old_rows
    assert [r['label'] for r in original[i]['observation']['rows']] == [r['label'] for r in current[i]['observation']['rows']]
    assert [r['native'] for r in original[i]['observation']['rows']] == [r['native'] for r in current[i]['observation']['rows']], 'complete native ordinary ledger'
for row in current[1]['observation']['rows']:
    options = row['options']
    calls, invocations = [], []
    if options['owner'] == 'direct' and not options.get('shadow'):
        invocations = [dict(builtin=x['name'], context=x['context'], focus=None) for x in row['native']['builtin_entries']]
    for call in row['native']['calls']:
        code = call['name'] != 'target' or options['owner'] == 'direct' or options.get('variant', 'code') == 'code'
        actual = bool(code and call['context'] == 'scalar')
        eligible = bool(actual and call['name'] == 'target' and call['generation'] == 0 and options.get('grant') == 'actual')
        calls.append(dict(name=call['name'], generation=call['generation'], number=call['number'], context=call['context'], actual_callback=int(actual), eligible=int(eligible)))
        if code:
            invocations.append(dict(focus=dict(name=call['name'], generation=call['generation']), context=call['context'], builtin=None))
    assert row['authority']['calls'] == calls, 'actual callback frames and scalar eligibility'
    assert row['authority']['invocations'] == invocations, 'actual selected callback invocation contexts'
    assert row['authority']['parent_packet'] == 0, 'no parent donation'
    matching = options.get('grant') == 'actual' and options.get('publish') and not options.get('repeat') and not row['native']['fatal'] and options.get('result', 'outer') in ('outer', 'list') and any(x['eligible'] and x['name'] == 'target' for x in calls)
    assert row['authority']['child_packets'] == int(bool(matching)), 'matching own packet'

first = load('before.json')
before = load('complete-before.json')
after = load('complete-after.json')
capsule('before-inputs.json.gz', first, historical=True, legacy_fixture=True)
capsule('complete-before-inputs.json.gz', before, historical=True)
capsule('complete-after-inputs.json.gz', after)
assert raw(FIXTURE) == raw(PREFIX + 'first-fixture.t').replace(b'before-native-data.json.gz', b'before-complete-native-data.json.gz').replace(b'actionir_control_calls_native.pl', b'actionir_control_calls_native_complete.pl')
for stem, record, count, failures, producer in (
    ('before', first, 1272, 423, 'run.py'), ('complete-before', before, 1290, 435, 'run-complete.py'),
    ('complete-after', after, 1290, 0, 'run-complete.py')):
    channels = packed(stem + '-channels.json.gz')
    assert record['producer_sha256'] == sha(raw(PREFIX + producer))
    assert record['channels_sha256'] == sha(raw(PREFIX + stem + '-channels.json.gz'))
    assert channels[0]['returncode'] == 0 and not decode(channels[0]['stdout_base64'])
    assert decode(channels[0]['stderr_base64']) == (FIXTURE + ' syntax OK\n').encode()
    n, failed = tap(channels[1])
    assert n == count == record['assertions'] == record['plan'] and failed == record['failures']
    assert len(failed) == failures and record['controls'] == count - failures
    assert bool(channels[1]['returncode']) == bool(failed)
    if not failed:
        assert not decode(channels[1]['stderr_base64'])
assert {x['name'] for x in first['failures']} <= {x['name'] for x in before['failures']}
assert len({x['name'] for x in before['failures']} - {x['name'] for x in first['failures']}) == 12
expected = old(MODULE).replace(b'return $lower->($expr, $ctx, $deps)', b'return _bind_emission_dependency($lower)->($expr, $ctx, $deps)', 1)
expected = expected.replace(b'my $lowered = $rule->{apply}->($trimmed, $candidate_ctx);', b'my $apply_callback = $rule->{apply}; my $lowered = _bind_optional_emission_dependency($apply_callback, sub { $apply_callback->(@_) })->($trimmed, $candidate_ctx);', 1)
assert raw(MODULE) == expected and expected.count(b'\n') == old(MODULE).count(b'\n'), 'exact two-line delta and diagnostic locations'
assert raw(EMISSIONS) == old(EMISSIONS), 'publication-cardinality implementation stays unchanged'
correction = load('observe-after-correction.json')
failure_capsule = capsule('observe-after-failure-inputs.json.gz')
assert correction['capsule_sha256'] == sha(raw(PREFIX + 'observe-after-failure-inputs.json.gz'))
assert correction['result'] == 'PASS' and correction['producer_sha256'] == sha(raw(PREFIX + 'observe-after-correction.py'))
failed_source = raw(PREFIX + 'observe-after.py')
assert decode(correction['original_source_base64']) == failed_source and sha(failed_source) == correction['original_source_sha256']
corrected = failed_source.replace(b"PREFIX+'after.json'", b"PREFIX+'complete-after.json'", 1).replace(b"PREFIX + 'observe-after.py'", b"PREFIX + 'observe-after-corrected.py'", 1)
assert raw(PREFIX + 'observe-after-corrected.py') == corrected and sha(corrected) == correction['corrected_source_sha256']
assert correction['failed']['returncode'] != 0 and b'regular parent-owned input' in decode(correction['failed']['stderr_base64'])
assert not (ROOT / correction['missing_input']).exists()
assert correction['corrected']['returncode'] == 0 and not decode(correction['corrected']['stderr_base64'])
faults = load('faults.json')
variants = packed('faults-data.json.gz')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(raw(PREFIX + 'faults.py'))
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-data.json.gz'))
assert len(variants) == len({x['module_sha256'] for x in variants}) == 14
assert [len(x['failures']) for x in variants] == [435, 180, 255, 106, 156, 60, 12, 420, 807, 2, 72, 6, 222, 112]
for row in variants:
    assert sha(decode(row['module_base64'])) == row['module_sha256'] and row['unchanged']
    assert row['channels'][0]['returncode'] == 0 and row['channels'][1]['returncode'] != 0
    n, failed = tap(row['channels'][1])
    assert n == row['assertions'] == 1290 and failed == row['failures'] and failed
assert decode(variants[0]['module_base64']) == old(MODULE) and variants[0]['failures'] == before['failures'], 'exact inverse original RED set'
early = next(x for x in variants if x['name'] == 'selection-before-candidate-clone')
assert len(early['failures']) == 6 and all('selection/rule/fetch-effect/' in x['name'] for x in early['failures'])
raw(PREFIX + 'faults-reached.json.gz')
consumers = load('consumers.json')
consumer_inputs = packed('consumers-inputs.json.gz')
consumer_channels = packed('consumers-channels.json.gz')
seed = json.loads(raw(SEED))
assert raw(SEED) == old(SEED)
assert consumers['command'] == seed['command'] + [FIXTURE], 'complete supplied suite selection'
assert consumers['returncode'] == consumer_channels['returncode'] == 0 and consumers['unchanged']
assert consumers['capsule_sha256'] == sha(raw(PREFIX + 'consumers-inputs.json.gz'))
assert consumers['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
for path, item in consumer_inputs.items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha(raw(path))
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in seed['inputs'] and path != MODULE:
        assert item['sha256'] == seed['inputs'][path]
old_channels = json.loads(gzip.decompress(raw('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/consumers-channels.json.gz')))
assert decode(consumer_channels['stderr_base64']) == decode(old_channels['stderr_base64'])
def suites(row):
    value = decode(row['stdout_base64'])
    return re.findall(rb'^([^\s]+\.t)\s+\.{2,}\s*$', value, re.M), re.findall(rb'^1\.\.(\d+)\s*$', value, re.M)
headers, plans = suites(consumer_channels)
old_headers, old_plans = suites(old_channels)
assert headers == old_headers + [FIXTURE.encode()] and plans == old_plans + [b'1290']
assert re.search(rb'Files=89, Tests=29504\b', decode(consumer_channels['stdout_base64']))
assert b'Result: PASS' in decode(consumer_channels['stdout_base64']) and len(consumer_inputs) == 349
for stage in ('before', 'after'):
    record = load(stage + '-diagnostics.json')
    data = packed(stage + '-diagnostics-inputs.json.gz')
    channels = packed(stage + '-diagnostics-channels.json.gz')
    assert record['producer_sha256'] == sha(raw(PREFIX + 'diagnostics.py'))
    assert record['returncode'] == channels['returncode'] == 0 and len(data) == 343
    assert record['inputs_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-inputs.json.gz'))
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-channels.json.gz'))
    assert not decode(channels['stderr_base64']) and b'Files=1, Tests=16' in decode(channels['stdout_base64'])
    for path, item in data.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256']
        assert value == (old(path) if stage == 'before' and path == MODULE else raw(path))
foundation = load('foundation-census.json')
assert foundation['result'] == 'PASS' and foundation['producer_sha256'] == sha(raw(PREFIX + 'foundation-census.py'))
assert foundation['original_card_sha256'] == sha(old(foundation['card']))
assert foundation['census'] == [dict(path=p, sha256=sha((ROOT / p).read_bytes()), live_intersections=[]) for p in sorted(claim_paths)]
knowledge = load('knowledge.json')
knowledge_data = packed('knowledge-inputs.json.gz')
assert knowledge['returncode'] == 0 and knowledge['markdown'] == 1486
assert knowledge['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-inputs.json.gz'))
assert not decode(knowledge['stdout_base64']) and decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    old_markdown = {x.name: dict(bytes_base64=base64.b64encode(stream.extractfile(x).read()).decode(), mode=x.mode) for x in stream if x.isfile() and x.name.endswith('.md')}
assert knowledge_data['original'] == old_markdown
paths = sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge', 'docs/decisions') for p in (ROOT / d).rglob('*.md') if p.is_file())
assert paths == sorted(old_markdown)
for path, item in knowledge_data['current'].items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha((ROOT / path).read_bytes())
    if path not in old_markdown or path in knowledge['changed_cards']:
        raw(path)
assert len(knowledge['changed_cards']) == 13
assert sorted(p for p in paths if knowledge_data['current'][p]['bytes_base64'] != old_markdown[p]['bytes_base64']) == knowledge['changed_cards']
for path in knowledge['changed_cards']:
    if path not in ('docs/knowledge/perl-factory-capture-framework.md', foundation['card']):
        assert decode(knowledge_data['current'][path]['bytes_base64']).split(b'\n---\n', 1)[1] == decode(old_markdown[path]['bytes_base64']).split(b'\n---\n', 1)[1]
assert sum(bool(re.search(rb'^id:\s+\S+', decode(knowledge_data['current'][p]['bytes_base64']).split(b'\n---\n', 1)[0], re.M)) for p in paths) == 1349
knowledge_bytes = sum((ROOT / p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert knowledge_bytes == 8388505 <= 8388608
for name in ('publication-cardinality.py', 'book-review.py', 'validation.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('readonly component', name, result.stderr)
    raw(PREFIX + name)
cardinality = load('publication-cardinality.json')
assert cardinality['rows'][0]['assertions'] == 62 and len(cardinality['rows'][1]['failures']) == 1
cardinality_inputs = packed('publication-cardinality-inputs.json.gz')
for path in cardinality_inputs:
    if path != MODULE:
        raw(path)
book = load('book-review.json')
for path, identity in (book['source_inputs'] | book['oracle_inputs']).items():
    assert sha(raw(path)) == identity
validation = load('validation.json')
for path, identity in validation['sources'].items():
    assert sha(raw(path)) == identity
compat = load('compat.json')
assert compat['result'] == 'PASS' and len(compat['rows']) == 5 and all(x['returncode'] == 0 for x in compat['rows'])
assert compat['producer_sha256'] == sha(raw(PREFIX + 'compat.py'))
assert b'Files=1, Tests=1035' in decode(compat['rows'][-1]['stdout_base64']) and b'Result: PASS' in decode(compat['rows'][-1]['stdout_base64'])
for name in ('book.json', 'book.py', 'knowledge.py', 'consumers.py', 'review.py'):
    raw(PREFIX + name)
report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review.py')),
          'population': dict(original_warm_rows=210, original_cold_rows=210, warm_rows=213, cold_rows=213,
              first_assertions=1272, first_red=423, paired_assertions=1290, original_red=435,
              passing_controls=855, source_faults=14, cardinality_assertions=62, cardinality_red=1,
              consumer_suites=89, consumer_inputs=349, consumer_assertions=29504,
              diagnostic_inputs=343, diagnostic_assertions=16, knowledge_bytes=knowledge_bytes,
              book_sources=89, book_controls=4),
          'inputs': {p: sha((ROOT / p).read_bytes()) for p in sorted(inputs)},
          'scope': 'Two invocation lines only. Original420 rows and the first1272/423 proof remain frozen; complete426 ordinary rows/recurrences and identical1290/435 source-bound proof pass. Tied-fetch side effects distinguish clone order; source cardinality62/one RED distinguishes ambiguity from isolation. Complete source faults, supplied consumers, public diagnostics, Knowledge/book and supplemental standard/public guards are retained. Original failed reader and actual reidentified failure/correction are preserved. No default, fixture, pipeline or broader private/parent/canonical admission. System tools are read-only dependencies without an immutable portable toolchain claim.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Direct/rule review PASS:', len(inputs), 'inputs;1290 assertions;435 original REDs;14 source faults;89 supplied suites')
