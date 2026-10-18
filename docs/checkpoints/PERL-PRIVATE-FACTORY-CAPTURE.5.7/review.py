"""Readonly mixed-default review; --capture freezes its complete report once."""
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
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
CONTROL = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FACADE = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
VALUE = 'perl/LinkedSpec/ActionIR/ValueExpr.pm'
OWNERS = {CONTROL, FACADE, VALUE}
FIXTURE = 't/actionir_control_default_capture.t'
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

def capsule(name, record=None, historical=False, first_fixture=False):
    value = packed(name)
    if record is not None:
        assert record['capsule_sha256'] == sha(raw(PREFIX + name))
        assert record['inputs'] == {p: {k: x[k] for k in ('sha256', 'mode')} for p, x in value.items()}
    for path, item in value.items():
        payload = decode(item['bytes_base64'])
        assert sha(payload) == item['sha256']
        if historical and path in OWNERS:
            assert payload == old(path)
        elif first_fixture and path == FIXTURE:
            assert payload == raw(PREFIX + 'first-fixture.t')
        else:
            assert payload == raw(path), ('current supplied input', name, path)
            assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    return value

def tap(row):
    text = decode(row['stdout_base64']).decode()
    rows = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == [str(len(rows))]
    assert [int(n) for _, n, _ in rows] == list(range(1, len(rows) + 1))
    assert not re.search(r'^Bail out!', text, re.M)
    return rows, [dict(number=int(n), name=title) for bad, n, title in rows if bad]

preservation = load('preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha(raw(PREFIX + 'preserve.py'))
claim_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
census, selected = [], []
for path in sorted(claim_paths):
    payload = old(path)
    record = json.loads(payload)
    hits = []
    for index, claim in enumerate(record['claims']):
        d = claim['durability']
        if d.get('mode') != 'live':
            continue
        overlap = sorted(set(preservation['owned_bound_paths']) & {x['path'] for x in d['inputs']})
        if overlap:
            assert all(sha(old(x['path'])) == x['sha256'] for x in d['inputs'])
            hits.append(dict(claim_index=index, paths=overlap, bindings=len(d['inputs'])))
    census.append(dict(path=path, sha256=sha(payload), intersections=hits))
    if hits:
        selected.append(path)
        assert path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.6.json'
        assert raw(PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json') == payload, 'whole prior publication custody'
        assert len(payload) == 121708 and len(record['claims']) == 1
        expected = copy.deepcopy(record)
        expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
        assert json.loads(raw(path)) == expected
assert census == preservation['census'] and selected == [x['path'] for x in preservation['selected']]
assert len(selected) == 1 and preservation['selected'][0]['intersections'][0]['bindings'] == 525
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json')
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Direct/rule publication PASS: 525 live inputs; 121708 bytes\n'
assert preservation['baselines'] == [baseline]

native = load('before-native.json')
capsule('before-native-inputs.json.gz', native, historical=True)
before_native = packed('before-native-data.json.gz')
current_record = load('after-native.json')
capsule('after-native-inputs.json.gz', current_record)
current_native = packed('after-native-data.json.gz')
assert current_record['warm_raw_recurrence'] == (current_native[1] == current_native[2])
assert current_record['cold_raw_recurrence'] == (current_native[3] == current_native[4])
for record, data, stem, producer in ((native, before_native, 'before-native', 'observe.py'),
        (current_record, current_native, 'after-native', 'observe-after.py')):
    assert record['producer_sha256'] == sha(raw(PREFIX + producer))
    assert record['instrument_sha256'] == sha(raw('t/actionir_control_default_native.pl'))
    assert record['data_sha256'] == sha(raw(PREFIX + stem + '-data.json.gz'))
    assert len(data) == 5 and all(r['returncode'] == 0 for r in data)
    for i in range(1, 5):
        assert not decode(data[i]['stderr_base64'])
        assert json.loads(decode(data[i]['stdout_base64'])) == data[i]['observation'], 'native raw/parsed agreement'
        observed = data[i]['observation']
        assert len(observed['rows']) == 26 and len(set(zip(observed['keys'], observed['providers']))) == 8
        assert {'perl/' + p for p in observed['loaded_project_modules']} <= set(native['inputs'])

def ordinary(value):
    if isinstance(value, dict):
        return {k: ordinary(v) for k, v in value.items() if k != 'authority'}
    if isinstance(value, list):
        return [ordinary(v) for v in value]
    return value

def unordered(value):
    value = copy.deepcopy(value)
    for row in value['rows']:
        row['authority']['registrations'].sort()
    return value

assert before_native[1] == before_native[2] and before_native[3] == before_native[4]
for first, second in ((1, 2), (3, 4)):
    actual = current_native[first]['observation']
    assert ordinary(actual) == ordinary(before_native[first]['observation']), 'complete native ordinary ledger'
    assert ordinary(actual) == ordinary(current_native[second]['observation'])
    assert unordered(actual) == unordered(current_native[second]['observation'])
    assert actual['source_emissions_loaded'] == (1 if first == 1 else 0) and actual['trace_loaded'] == 0
    for row in actual['rows']:
        authority = row['authority']
        expected_attempts = []
        if first == 1 and row['label'] != 'outside':
            for value in row['values']:
                for callback in value.get('callbacks', []):
                    if callback['actual_native'] and (callback['key'] == 'extract_array_symbol_name'
                            or row['target'] == 'LinkedSpec::RuleIR::EmitContext'):
                        expected_attempts.append(callback['identity'])
        assert sorted(authority['registrations']) == sorted(expected_attempts), 'observed in-scope provider registration attempts'
        selected_state = int(first == 1 and row['label'] != 'outside')
        assert authority['native_selected'] == [selected_state] * 8, 'source/producer selection lifetime'
        for value, selected_value in zip(row['values'], authority['values']):
            expected = [dict(key=x['key'], selected=int(bool(selected_state and x['actual_native']))) for x in value.get('callbacks', [])]
            assert selected_value == expected, 'actual native callback selection'

paired_rows = {}
for stem, count, failures, historical, first_fixture, producer in (
        ('before', 401, 44, True, True, 'run.py'), ('after', 401, 0, False, True, 'run.py'),
        ('complete-before', 445, 53, True, False, 'run-complete.py'),
        ('complete-after', 445, 0, False, False, 'run-complete.py')):
    record = load(stem + '.json')
    capsule(stem + '-inputs.json.gz', record, historical, first_fixture)
    channels = packed(stem + '-channels.json.gz')
    assert record['producer_sha256'] == sha(raw(PREFIX + producer))
    assert record['channels_sha256'] == sha(raw(PREFIX + stem + '-channels.json.gz'))
    rows, failed = tap(channels[1])
    assert len(rows) == record['assertions'] == record['plan'] == count
    assert failed == record['failures'] and len(failed) == failures
    assert bool(channels[1]['returncode']) == bool(failed) and channels[0]['returncode'] == 0
    if not failed:
        assert not decode(channels[1]['stderr_base64'])
    paired_rows[stem] = rows
assert paired_rows['complete-before'][:401] == paired_rows['before']
assert paired_rows['complete-after'][:401] == paired_rows['after']
assert raw(FIXTURE).startswith(raw(PREFIX + 'first-fixture.t').removesuffix(b'done_testing;\n'))

# Every existing production byte/location remains exact except the two factory lines.
original_control = old(CONTROL).removesuffix(b'1;\n')
expected_prefix = original_control.replace(b'return LinkedSpec::OwnerDispatch::build_dep_map(',
    b'return _with_default_emission_selection($pkg, sub { return LinkedSpec::OwnerDispatch::build_dep_map(', 1)
expected_prefix = expected_prefix.replace(b'\n )\n}\n', b'\n ) });\n}\n', 1)
assert raw(CONTROL).startswith(expected_prefix) and expected_prefix.count(b'\n') == original_control.count(b'\n')
for path in (FACADE, VALUE):
    assert raw(path).startswith(old(path).removesuffix(b'1;\n'))
assert raw('perl/LinkedSpec/ActionIR/SourceEmissions.pm') == old('perl/LinkedSpec/ActionIR/SourceEmissions.pm')

faults = load('faults.json')
variants = packed('faults-data.json.gz')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(raw(PREFIX + 'faults-final.py'))
assert faults['data_sha256'] == sha(raw(PREFIX + 'faults-data.json.gz'))
assert [len(r['failures']) for r in variants] == [53,31,14,1,17,35,5,14,2,153,67,21,45,4,44,6,1,55]
for row in variants:
    assert set(row['sources']) == OWNERS and row['unchanged']
    assert all(sha(decode(x['bytes_base64'])) == x['sha256'] for x in row['sources'].values())
    assert all(r['returncode'] == 0 for r in row['channels'][:-1]) and row['channels'][-1]['returncode'] != 0
    rows, failed = tap(row['channels'][-1])
    assert len(rows) == row['assertions'] == 445 and failed == row['failures']
assert all(decode(variants[0]['sources'][p]['bytes_base64']) == old(p) for p in OWNERS)
assert variants[0]['failures'] == load('complete-before.json')['failures']
correction = load('faults-correction.json')
final_run = load('faults-final-run.json')
assert correction['result'] == 'FAIL' and final_run['result'] == 'PASS'
for name, report in (('faults-correction', correction), ('faults-final-run', final_run)):
    assert report['producer_sha256'] == sha(raw(PREFIX + name + '.py'))
assert correction['rows'][0]['returncode'] != 0 and b'all-facade-code-authorized' in decode(correction['rows'][0]['stderr_base64'])
assert correction['rows'][1]['returncode'] != 0 and b'assert len(variants) == 17' in decode(correction['rows'][1]['stderr_base64'])
assert final_run['rows'][0]['returncode'] != 0 and final_run['rows'][1]['returncode'] == 0
assert raw(PREFIX + 'faults-final.py') == raw(PREFIX + 'faults.py').replace(b'assert len(variants) == 17', b'assert len(variants) == 18', 1)
for name, report in (('faults-builder-failure-inputs.json.gz', correction), ('faults-final-run-inputs.json.gz', final_run)):
    assert report['capsule_sha256'] == sha(raw(PREFIX + name))
    capsule(name)

for stage in ('before', 'after'):
    report = load(stage + '-diagnostics.json')
    data = packed(stage + '-diagnostics-inputs.json.gz')
    channels = packed(stage + '-diagnostics-channels.json.gz')
    assert report['producer_sha256'] == sha(raw(PREFIX + 'diagnostics.py'))
    assert report['inputs_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-inputs.json.gz'))
    assert report['channels_sha256'] == sha(raw(PREFIX + stage + '-diagnostics-channels.json.gz'))
    assert report['returncode'] == channels['returncode'] == 0 and len(data) == 353
    assert not decode(channels['stderr_base64']) and b'Files=1, Tests=16' in decode(channels['stdout_base64'])
    for path, item in data.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256']
        assert value == (old(path) if stage == 'before' and path in OWNERS else raw(path))

knowledge = load('knowledge.json')
knowledge_data = packed('knowledge-inputs.json.gz')
assert knowledge['returncode'] == 0 and knowledge['markdown'] == 1486
assert knowledge['producer_sha256'] == sha(raw(PREFIX + 'knowledge.py'))
assert not decode(knowledge['stdout_base64']) and decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert raw('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/knowledge.json') == old('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/knowledge.json')
assert knowledge['capsule_sha256'] == sha(raw(PREFIX + 'knowledge-inputs.json.gz'))
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    originals = {x.name: dict(bytes_base64=base64.b64encode(stream.extractfile(x).read()).decode(), mode=x.mode) for x in stream if x.isfile() and x.name.endswith('.md')}
assert knowledge_data['original'] == originals
paths = sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge', 'docs/decisions') for p in (ROOT / d).rglob('*.md') if p.is_file())
assert paths == sorted(originals)
for path, item in knowledge_data['current'].items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha((ROOT / path).read_bytes())
    if path not in originals or path in knowledge['changed_cards']:
        raw(path)
assert len(knowledge['changed_cards']) == 13
assert sorted(p for p in paths if knowledge_data['current'][p]['bytes_base64'] != originals[p]['bytes_base64']) == knowledge['changed_cards']
edited_bodies = {'docs/knowledge/perl-factory-capture-framework.md', 'docs/knowledge/perl-emitcontext-callback-capture.md', 'docs/knowledge/project-root-evidence-filesystem-modes.md'}
for path in knowledge['changed_cards']:
    if path not in edited_bodies:
        assert decode(knowledge_data['current'][path]['bytes_base64']).split(b'\n---\n', 1)[1] == decode(originals[path]['bytes_base64']).split(b'\n---\n', 1)[1]
knowledge_bytes = sum((ROOT / p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert knowledge_bytes == 8388133 <= 8388608
preparation = load('knowledge-preparation.json')
assert preparation['producer_sha256'] == sha(raw(PREFIX + 'prepare-knowledge.py'))
assert preparation['knowledge_bytes'] == knowledge_bytes and sorted(preparation['cards']) == knowledge['changed_cards']
for path, item in preparation['cards'].items():
    assert item == dict(original_sha256=sha(old(path)), current_sha256=sha(raw(path)))
assert sum(bool(re.search(rb'^id:\s+\S+', decode(knowledge_data['current'][p]['bytes_base64']).split(b'\n---\n', 1)[0], re.M)) for p in paths) == 1349

for name in ('native-review.py', 'consumer-review.py', 'book-review.py', 'public-validation.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('readonly component', name, result.stderr)
    raw(PREFIX + name)
for name in ('native-review.json', 'consumer-review.json'):
    report = load(name)
    for path, identity in report['inputs'].items():
        assert sha(raw(path)) == identity
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
for path, identity in (book['source_inputs'] | book['oracle_inputs']).items():
    assert sha(raw(path)) == identity
public = load('public-validation.json')
for path, identity in public['sources'].items():
    assert sha(raw(path)) == identity
compat = load('compat.json')
assert compat['result'] == 'PASS' and len(compat['rows']) == 5 and all(r['returncode'] == 0 for r in compat['rows'])
assert compat['producer_sha256'] == sha(raw(PREFIX + 'compat.py'))
assert b'Files=1, Tests=1035' in decode(compat['rows'][-1]['stdout_base64']) and b'Result: PASS' in decode(compat['rows'][-1]['stdout_base64'])

# Fixed evidence population is inserted before the first execution; later publication
# and mutation-control outputs cannot silently change this readonly report.
EVIDENCE_FILES = ['after-channels.json.gz', 'after-diagnostics-channels.json.gz', 'after-diagnostics-inputs.json.gz', 'after-diagnostics.json', 'after-inputs.json.gz', 'after-native-data.json.gz', 'after-native-inputs.json.gz', 'after-native.json', 'after.json', 'baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json', 'before-channels.json.gz', 'before-diagnostics-channels.json.gz', 'before-diagnostics-inputs.json.gz', 'before-diagnostics.json', 'before-inputs.json.gz', 'before-native-data.json.gz', 'before-native-inputs.json.gz', 'before-native.json', 'before.json', 'book-review.json', 'book-review.py', 'book.json', 'book.py', 'compat.json', 'compat.py', 'complete-after-channels.json.gz', 'complete-after-inputs.json.gz', 'complete-after.json', 'complete-before-channels.json.gz', 'complete-before-inputs.json.gz', 'complete-before.json', 'consumer-review.json', 'consumer-review.py', 'consumers-channels.json.gz', 'consumers-inputs.json.gz', 'consumers.json', 'consumers.py', 'diagnostics.py', 'faults-builder-failure-inputs.json.gz', 'faults-builder-failure.py', 'faults-correction.json', 'faults-correction.py', 'faults-data.json.gz', 'faults-final-run-inputs.json.gz', 'faults-final-run.json', 'faults-final-run.py', 'faults-final.py', 'faults-reached.json.gz', 'faults.json', 'faults.py', 'first-fixture.t', 'knowledge-inputs.json.gz', 'knowledge-preparation.json', 'knowledge.json', 'knowledge.py', 'native-review-syntax-failure.py', 'native-review.json', 'native-review.py', 'observe-after.py', 'observe.py', 'prepare-knowledge.py', 'preservation.json', 'preserve.py', 'public-validation.json', 'public-validation.py', 'run-complete.py', 'run.py', 'validation.json', 'validation.py']
for name in EVIDENCE_FILES:
    raw(PREFIX + name)
raw(PREFIX + 'review.py')
report = dict(result='PASS', base=BASE, producer_sha256=sha(raw(PREFIX + 'review.py')),
    population=dict(warm_rows=26, cold_rows=26, first_assertions=401, first_red=44,
        paired_assertions=445, original_red=53, passing_controls=392, source_faults=18,
        consumer_suites=90, consumer_inputs=356, consumer_assertions=29950,
        diagnostic_inputs=353, diagnostic_assertions=16, knowledge_bytes=knowledge_bytes,
        book_sources=89, book_controls=4),
    inputs={p: sha((ROOT / p).read_bytes()) for p in sorted(inputs)},
    scope='Exact mixed-provider selection and native factory behavior only. First observations,401/44 proof and failed producers stay frozen. Extended445/53 proof, three-owner source faults, actual52 ordinary observations and unordered authority recurrence, complete consumers with an exact one-row foreign-definition extension, diagnostics, full Knowledge/book and supplemental guards/standard commands pass. Original525/121708 publication stays historical atce9eaf32e. Module-owned native references remain retained; no outside-scope registration-attempt census, ordered registration, immutable system toolchain, pipeline/private/parent/canonical admission is inferred.')
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Mixed-default review PASS:', len(inputs), 'inputs;445 assertions;53 original REDs;18 source faults;90 supplied suites')
