"""Readonly optional-kind review; --capture freezes the deterministic report once."""
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
BASE = 'dadce45ac8f0a4bc6d65a3497ac99fc735e9187c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
INSTRUMENT = 't/actionir_control_kind_native_complete.pl'
FIXTURE = 't/actionir_control_kind_capture.t'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/consumers.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
inputs = set()


def raw(path):
    inputs.add(path)
    return (ROOT / path).read_bytes()


def load(name):
    return json.loads(raw(PREFIX + name))


def packed(name):
    return json.loads(gzip.decompress(raw(PREFIX + name)))


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def capsule(name, record, historical=False):
    data = packed(name)
    assert record['capsule_sha256'] == sha(raw(PREFIX + name))
    assert record['inputs'] == {p: {k: x[k] for k in ('sha256', 'mode')} for p, x in data.items()}
    for path, item in data.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256'], ('capsule payload', name, path)
        if historical and path == MODULE:
            assert value == old(path)
        else:
            assert raw(path) == value, ('supplied current input', name, path)
            assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    return data


def tap(row):
    output = decode(row['stdout_base64']).decode()
    assertions = re.findall(r'^(not )?ok (\d+) - (.*)$', output, re.M)
    assert re.findall(r'^1\.\.(\d+)$', output, re.M) == [str(len(assertions))]
    assert [int(n) for _, n, _ in assertions] == list(range(1, len(assertions) + 1))
    assert not re.search(r'^Bail out!', output, re.M)
    return len(assertions), [{'number': int(n), 'name': title} for bad, n, title in assertions if bad]


assert sys.argv[1:] in ([], ['--capture'])
preservation = load('preservation.json')
assert preservation['base'] == BASE and preservation['result'] == 'PASS'
assert preservation['producer_sha256'] == sha(raw(PREFIX + 'preserve.py'))
census = []
selected = []
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                cwd=ROOT, text=True).splitlines()
for path in sorted(paths):
    value = old(path)
    record = json.loads(value)
    hits = []
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        overlap = sorted(set(preservation['owned_bound_paths']) & {x['path'] for x in durability['inputs']})
        if overlap:
            assert all(sha(old(x['path'])) == x['sha256'] for x in durability['inputs'])
            hits.append({'claim_index': index, 'paths': overlap, 'bindings': len(durability['inputs'])})
    census.append({'path': path, 'sha256': sha(value), 'intersections': hits})
    if hits:
        selected.append(path)
        assert path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.4.json'
        assert raw(PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.4.json') == value, 'whole prior publication custody'
        assert len(value) == 117562 and len(record['claims']) == 2
        expected = copy.deepcopy(record)
        for hit in hits:
            expected['claims'][hit['claim_index']]['durability'].update(mode='historical', revision=BASE)
        assert json.loads(raw(path)) == expected, 'only affected durability mode/revision changes'
assert census == preservation['census'] and selected == [x['path'] for x in preservation['selected']]
assert len(selected) == 1 and preservation['selected'][0]['intersections'][0]['bindings'] == 495
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.4.json')
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'ControlFlow output publication PASS: 495 compiler inputs; 117562 bytes; kernel gap: startup.7\n'
assert preservation['baselines'] == [baseline]

# Preserve the first failed fixture observation and the exact narrow correction.
first = load('before-native.json')
first_inputs = capsule('before-native-inputs.json.gz', first, historical=True)
first_data = packed('before-native-data.json.gz')
assert first['data_sha256'] == sha(raw(PREFIX + 'before-native-data.json.gz'))
assert any('FIRSTKEY' in str(x['native']['fatal']) for x in first_data[1]['observation']['rows'])
before_native = load('before-complete-native.json')
original_inputs = capsule('before-complete-native-inputs.json.gz', before_native, historical=True)
original = packed('before-complete-native-data.json.gz')
assert before_native['data_sha256'] == sha(raw(PREFIX + 'before-complete-native-data.json.gz'))
first_source = raw('t/actionir_control_kind_native.pl')
expected_instrument = first_source.replace(b' $result->{fields} = {map',
    b" if ($type eq 'HASH' && tied %$value) { $result->{tied} = ref(tied %$value); return $result }\n $result->{fields} = {map", 1)
assert raw(INSTRUMENT) == expected_instrument
assert not any('FIRSTKEY' in str(x['native']['fatal']) for x in original[1]['observation']['rows'])

before = load('before.json')
after = load('after.json')
capsule('before-inputs.json.gz', before, historical=True)
capsule('after-inputs.json.gz', after)
for name, record, expected_errors in (('before', before, 77), ('after', after, 0)):
    rows = packed(name + '-channels.json.gz')
    assert record['channels_sha256'] == sha(raw(PREFIX + name + '-channels.json.gz'))
    assert rows[0]['returncode'] == 0 and not decode(rows[0]['stdout_base64'])
    assert decode(rows[0]['stderr_base64']) == (FIXTURE + ' syntax OK\n').encode()
    count, failed = tap(rows[1])
    assert count == record['assertions'] == record['plan'] == 452
    assert failed == record['failures'] and len(failed) == expected_errors
    assert record['controls'] == count - len(failed)
    assert bool(rows[1]['returncode']) == bool(failed)
    if not failed:
        assert not decode(rows[1]['stderr_base64'])

source = raw(MODULE)
expected = old(MODULE).replace(b' if (defined($array_symbol) && length($array_symbol)',
    b' my $kind_callback = _bind_optional_emission_dependency($bare_symbol_kind, sub { $bare_symbol_kind->(@_) }); if (defined($array_symbol) && length($array_symbol)', 1)
expected = expected.replace(b'(($bare_symbol_kind->($1) //', b'(($kind_callback->($1) //', 1)
helper = b"# Keep native dispatch and its diagnostic line for non-CODE second selections.\n# Only an actual unblessed CODE reference can carry private registration.\nsub _bind_optional_emission_dependency {\n my ($selected, $native_call) = @_;\n return _bind_emission_dependency(ref($selected) eq 'CODE' ? $selected : $native_call);\n}\n\n"
expected = expected.replace(b'\n1;\n', b'\n' + helper + b'1;\n')
assert source == expected, 'independent exact two-line delta and appended optional helper'

current_native = load('after-native.json')
capsule('after-native-inputs.json.gz', current_native)
current = packed('after-native-data.json.gz')
assert current_native['data_sha256'] == sha(raw(PREFIX + 'after-native-data.json.gz'))
for observations in (original, current):
    assert len(observations) == 5 and all(x['returncode'] == 0 for x in observations)
    assert observations[1] == observations[2] and observations[3] == observations[4], 'fresh-process recurrence'
    for index in (1, 3):
        assert not decode(observations[index]['stderr_base64'])
        observed = observations[index]['observation']
        assert len(observed['rows']) == 88 and len({x['label'] for x in observed['rows']}) == 88
        assert observed['emission_loaded'] == (1 if index == 1 else 0) and observed['trace_loaded'] == 0
        assert set(observed['loaded_project_modules']) <= set(original_inputs)
for index in (1, 3):
    assert [x['label'] for x in original[index]['observation']['rows']] == [x['label'] for x in current[index]['observation']['rows']]
    assert [x['native'] for x in original[index]['observation']['rows']] == [x['native'] for x in current[index]['observation']['rows']], 'complete native ordinary ledger'
for row in current[1]['observation']['rows']:
    options = row['options']
    actual_code = options.get('variant', 'code') == 'code'
    calls = row['native']['calls']
    assert all(x['context'] == 'scalar' for x in calls)
    assert row['authority']['calls'] == [dict(actual_callback=int(actual_code), eligible=int(actual_code and options.get('known', False))) for _ in calls], 'actual identity and own eligibility'
    assert row['authority']['parent_packet'] == 0, 'no parent donation'
    assert row['authority']['child_packets'] == int(row['label'].startswith('child/') and bool(options.get('known'))), 'matching own packet'

faults = load('faults.json')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(raw(PREFIX + 'faults.py'))
variants = packed('faults-data.json.gz')
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-data.json.gz'))
assert len(variants) == 12 and len({x['module_sha256'] for x in variants}) == 12
assert [x['name'] for x in variants] == [x['name'] for x in faults['variants']]
for row in variants:
    assert sha(decode(row['module_base64'])) == row['module_sha256']
    assert row['unchanged'] and row['channels'][0]['returncode'] == 0 and row['channels'][1]['returncode'] != 0
    count, failed = tap(row['channels'][1])
    assert count == row['assertions'] == 452 and failed == row['failures'] and failed
assert decode(variants[0]['module_base64']) == old(MODULE) and variants[0]['failures'] == before['failures'], 'exact inverse original RED set'
assert variants[0]['module_sha256'] != sha(source)
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
assert consumers['inputs'] == {p: x['sha256'] for p, x in consumer_inputs.items()}
for path, item in consumer_inputs.items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha(raw(path))
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in seed['inputs'] and path != MODULE:
        assert item['sha256'] == seed['inputs'][path]
consumer_output = decode(consumer_channels['stdout_base64'])
assert b'All tests successful.' in consumer_output and b'Result: PASS' in consumer_output
assert re.search(rb'Files=88, Tests=28214\b', consumer_output)
old_channels = json.loads(gzip.decompress(raw('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/consumers-channels.json.gz')))
assert decode(consumer_channels['stderr_base64']) == decode(old_channels['stderr_base64'])
def suite_headers(value):
    text = decode(value['stdout_base64'])
    return re.findall(rb'^([^\s]+\.t)\s+\.{2,}\s*$', text, re.M), re.findall(rb'^1\.\.(\d+)\s*$', text, re.M)
headers, plans = suite_headers(consumer_channels)
old_headers, old_plans = suite_headers(old_channels)
assert headers == old_headers + [FIXTURE.encode()] and plans == old_plans + [b'452']

for stage in ('before', 'after'):
    record = load(stage + '-diagnostics.json')
    data = packed(stage + '-diagnostics-inputs.json.gz')
    channels = packed(stage + '-diagnostics-channels.json.gz')
    assert record['returncode'] == channels['returncode'] == 0
    assert record['inputs_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-inputs.json.gz'))
    assert record['channels_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-channels.json.gz'))
    assert not decode(channels['stderr_base64']) and b'Files=1, Tests=16' in decode(channels['stdout_base64'])
    for path, item in data.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256']
        assert value == (old(path) if stage == 'before' and path == MODULE else raw(path))

knowledge = load('knowledge-final.json')
knowledge_data = packed('knowledge-final-inputs.json.gz')
assert knowledge['returncode'] == 0 and knowledge['markdown'] == 1486
assert knowledge['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-final-inputs.json.gz'))
assert not decode(knowledge['stdout_base64'])
assert decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    original_markdown = {x.name: {'bytes_base64': base64.b64encode(stream.extractfile(x).read()).decode(), 'mode': x.mode} for x in stream if x.isfile() and x.name.endswith('.md')}
assert knowledge_data['original'] == original_markdown
first_knowledge = load('knowledge.json')
first_knowledge_data = packed('knowledge-inputs.json.gz')
assert first_knowledge['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-inputs.json.gz'))
assert sum(len(decode(x['bytes_base64'])) for p, x in first_knowledge_data['current'].items() if p.startswith('docs/knowledge/')) == 8388838
assert [p for p, x in first_knowledge_data['current'].items() if (ROOT / p).read_bytes() != decode(x['bytes_base64'])] == ['docs/knowledge/perl-factory-capture-framework.md'], 'first writer final-integrity rejection remains distinguishable'
all_markdown = sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge', 'docs/decisions') for p in (ROOT / d).rglob('*.md') if p.is_file())
assert all_markdown == sorted(original_markdown)
for path, item in knowledge_data['current'].items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha((ROOT / path).read_bytes())
    if path not in original_markdown or path in knowledge['changed_cards']:
        raw(path)
assert len(knowledge['changed_cards']) == 12
assert sorted(p for p in all_markdown if knowledge_data['current'][p]['bytes_base64'] != original_markdown[p]['bytes_base64']) == knowledge['changed_cards']
for path in knowledge['changed_cards']:
    if path != 'docs/knowledge/perl-factory-capture-framework.md':
        assert decode(knowledge_data['current'][path]['bytes_base64']).split(b'\n---\n', 1)[1] == decode(original_markdown[path]['bytes_base64']).split(b'\n---\n', 1)[1], 'eleven route-only card bodies'
assert sum(bool(re.search(rb'^id:\s+\S+', decode(knowledge_data['current'][p]['bytes_base64']).split(b'\n---\n', 1)[0], re.M)) for p in all_markdown) == 1349
knowledge_bytes = sum((ROOT / p).stat().st_size for p in all_markdown if p.startswith('docs/knowledge/'))
assert knowledge_bytes == 8388480 and knowledge_bytes <= 8388608
for name in ('book-review.py', 'validation.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('readonly component', name, result.stderr)
    raw(PREFIX + name)
for name in ('book.json', 'book.py', 'book-review.json', 'knowledge-final.py', 'validation.json'):
    raw(PREFIX + name)
book = load('book-review.json')
for path, expected_hash in book['source_inputs'].items():
    assert sha(raw(path)) == expected_hash
validation = load('validation.json')
for path, identity in validation['sources'].items():
    assert sha(raw(path)) == identity
for name in ('preserve.py', 'observe.py', 'observe-complete.py', 'run.py', 'observe-after.py', 'diagnostics.py', 'consumers.py', 'knowledge.py', 'knowledge.json', 'knowledge-inputs.json.gz', 'review.py'):
    raw(PREFIX + name)

report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(raw(PREFIX + 'review.py')),
    'population': {'warm_rows': 88, 'cold_rows': 88, 'paired_assertions': 452, 'original_red': 77,
        'passing_controls': 375, 'source_faults': 12, 'consumer_suites': 88,
        'consumer_inputs': len(consumer_inputs), 'consumer_assertions': 28214,
        'knowledge_bytes': knowledge_bytes, 'book_sources': 89, 'book_controls': 4},
    'inputs': {p: sha((ROOT / p).read_bytes()) for p in sorted(inputs)},
    'scope': 'Exact optional-kind source delta, all original/current native ordinary rows and recurrences, identical paired RED/GREEN, complete source-fault channels, complete predecessor consumers plus this fixture, separate public diagnostic before/after and current complete Knowledge/book/public guard. The publication independently requires supplemental standard syntax/public Phase0 completion. Whole original two-claim publication and actual baseline remain retained. Initial tied-map snapshot failure and first over-capacity Knowledge candidate stay historical. No complete private, parent, default, direct/rule or canonical admission. System tools are reused read-only; no immutable portable toolchain claim.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Optional-kind review PASS:', len(inputs), 'inputs;452 assertions;77 original REDs;12 source faults;88 supplied suites')
