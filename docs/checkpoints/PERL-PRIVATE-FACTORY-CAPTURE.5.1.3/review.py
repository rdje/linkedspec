"""Readonly independent finite-history review; --capture records this reader once.

The failed copied-root experiments remain observations, not admission proof.
Accepted Git supplies historical custody; the live candidate is checked separately.
"""
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
REG = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
ADR = 'docs/decisions/0135-finite-engineering-notes-member.md'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json'
CARD = 'docs/knowledge/finite-engineering-notes-member-0131.md'
CHAPTER = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda b: hashlib.sha256(b).hexdigest()
decode = lambda s: base64.b64decode(s, validate=True)
raw = lambda p: (ROOT / p).read_bytes()
load = lambda p: json.loads(raw(PREFIX + p))
compact = lambda v: json.dumps(v, sort_keys=True, separators=(',', ':')).encode()
assert sys.argv[1:] in ([], ['--capture'])

# A single read-only Git process avoids hundreds of spawned object readers.
objects = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                           stdin=subprocess.PIPE, stdout=subprocess.PIPE)
cache = {}
def at(revision, path):
    key = revision + ':' + path
    if key not in cache:
        objects.stdin.write(key.encode() + b'\n')
        objects.stdin.flush()
        header = objects.stdout.readline().split()
        assert len(header) == 3 and header[1] == b'blob', ('Git artifact', key)
        cache[key] = objects.stdout.read(int(header[2]))
        assert objects.stdout.read(1) == b'\n'
    return cache[key]
old = lambda p: at(BASE, p)
def paths(directory):
    return subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', directory],
                                   cwd=ROOT, text=True).splitlines()
def capsule(name, identity):
    value = raw(PREFIX + name)
    assert sha(value) == identity, ('retained capsule identity', name)
    result = json.loads(gzip.decompress(value))
    for p, item in result.items():
        assert p == Path(p).as_posix() and not Path(p).is_absolute() and '..' not in Path(p).parts
        assert sha(decode(item['bytes_base64'])) == item['sha256'], ('capsule member identity', p)
        assert item['mode'] in (0o644, 0o755), ('capsule mode', p)
    return result
def verify_producer(record, filename):
    assert record['producer_sha256'] == sha(raw(PREFIX + filename)), ('actual producer', filename)
def metrics(names):
    values = [raw(p) for p in names]
    return dict(files=len(values), lines=sum(v.count(b'\n') for v in values), bytes=sum(map(len, values)))
def contract(row):
    fields = ('authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner', 'route_targets', 'state', 'verifier')
    return {**{k: row.get(k) for k in fields}, 'transition_owners': row.get('transition', {}).get('owners')}

measurement = load('measurement.json')
verify_producer(measurement, 'measure.py')
assert measurement['base'] == BASE and measurement['result'] == 'PASS'
preserved = sorted(p for directory in ('docs/history/development-notes', 'docs/history/changes', 'docs/decisions')
                   for p in paths(directory) if p not in (MANIFEST, INDEX))
assert len(preserved) == 228 and sorted(measurement['preserved']) == preserved, 'complete prior history/decision census'
for p in preserved:
    assert sha(raw(p)) == measurement['preserved'][p] == sha(old(p)), ('unchanged accepted history/decision', p)
for p, item in measurement['original_inputs'].items():
    assert decode(item['bytes_base64']) == old(p) and item['sha256'] == sha(old(p)), ('original mutable bytes', p)
assert set(measurement['original_inputs']) == {'CHANGES.md', 'DEVELOPMENT_NOTES.md', REG, INDEX, MANIFEST}

# Reconstruct complete records without calling or importing the production roller.
changes = decode(measurement['records']['changes_base64'])
note = decode(measurement['records']['engineering_base64'])
for record in (changes, note):
    assert record.count(b'\n') == 4 and record.startswith(b'## 2026-10-17') and record.endswith(b'\n\n')
    assert b'PERL-PRIVATE-FACTORY-CAPTURE.5.1.3' in record
def prepend(value, record):
    start = re.search(rb'^## ', value, re.M).start()
    return value[:start] + record + value[start:]
unrolled_notes = prepend(old('DEVELOPMENT_NOTES.md'), note)
assert len(unrolled_notes) == 59506 and unrolled_notes.count(b'\n') == 386
assert len(unrolled_notes) * 100 >= 65536 * 90 and unrolled_notes.count(b'\n') * 100 < 512 * 90
parts = re.split(rb'(?=^(?:## |- 20[0-9]{2}-[0-9]{2}-[0-9]{2}\b))', old('DEVELOPMENT_NOTES.md'), flags=re.M)
preamble, records = parts[0], parts[1:]
keep = len(records)
while keep:
    candidate = preamble + note + b''.join(records[:keep])
    if len(candidate) <= 32768 and candidate.count(b'\n') <= 256:
        break
    keep -= 1
assert keep > 0 and keep < len(records)
archive = b''.join(records[keep:])
retained = re.sub(rb'\n{2,}\Z', b'\n', preamble + note + b''.join(records[:keep]))
assert raw('DEVELOPMENT_NOTES.md') == retained, 'exact independently reconstructed current root'
assert raw('CHANGES.md') == prepend(old('CHANGES.md'), changes), 'exact complete change record'
assert len(archive) == 27013 and archive.count(b'\n') == 272 and old('DEVELOPMENT_NOTES.md').endswith(archive)
previous = [json.loads(l) for l in old(MANIFEST).splitlines()]
current = [json.loads(l) for l in raw(MANIFEST).splitlines()]
meta = copy.deepcopy(previous[0]); meta['segment_count'] += 1
assert current[0] == meta and current[2:] == previous[1:], 'all prior manifest rows retained'
assert raw(MANIFEST).splitlines(True)[2:] == old(MANIFEST).splitlines(True)[1:], 'byte-exact prior manifest rows'
segment = current[1]
number = f"{int(previous[1]['segment_id']) - 1:04d}"
target = 'docs/history/development-notes/segment-' + number + '-' + sha(archive)[:12] + '.md'
start = old('DEVELOPMENT_NOTES.md')[:-len(archive)].count(b'\n') + 1
blob = subprocess.check_output(['git', 'rev-parse', BASE + ':DEVELOPMENT_NOTES.md'], cwd=ROOT, text=True).strip()
expected_segment = dict(byte_count=len(archive), current_path='DEVELOPMENT_NOTES.md', immutable=True,
    line_count=archive.count(b'\n'), retrieval_command='perl tools/read_document_history.pl --surface engineering_notes --segment ' + number,
    segment_id=number, sha256=sha(archive), source_blob=blob, source_commit=BASE,
    source_end_line=start + archive.count(b'\n') - 1, source_path='DEVELOPMENT_NOTES.md', source_start_line=start,
    surface='engineering_notes', target_path=target, type='segment')
assert segment == expected_segment and raw(target) == archive, 'exact source suffix/blob/range/digest/member'

stages = {}
for name, count in (('original', 1793), ('unrolled', 1793), ('rolled', 1794)):
    item = measurement['captures'][name]
    assert item['path'] == PREFIX + name + '-inputs.json.gz' and item['files'] == count
    stages[name] = capsule(name + '-inputs.json.gz', item['sha256'])
    assert len(stages[name]) == count
for p in stages['original']:
    original = stages['original'][p]
    if p not in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', MANIFEST):
        assert stages['unrolled'][p] == stages['rolled'][p] == original, ('unaffected measured member', p)
for name, notes, manifest in (('original', old('DEVELOPMENT_NOTES.md'), old(MANIFEST)),
                              ('unrolled', unrolled_notes, old(MANIFEST)), ('rolled', retained, raw(MANIFEST))):
    assert decode(stages[name]['DEVELOPMENT_NOTES.md']['bytes_base64']) == notes
    assert decode(stages[name][MANIFEST]['bytes_base64']) == manifest
    assert decode(stages[name][REG]['bytes_base64']) == old(REG)
    assert decode(stages[name]['CHANGES.md']['bytes_base64']) == (old('CHANGES.md') if name == 'original' else raw('CHANGES.md'))
assert set(stages['rolled']) - set(stages['original']) == {target}
assert decode(stages['rolled'][target]['bytes_base64']) == archive, 'supplied archive is the exact source suffix'
commands = measurement['commands']
assert [c['command'] for c in commands] == [
    ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--check'],
    ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--apply'],
    ['perl', 'scripts/check_readme_routing_pressure.pl', '--report']]
assert commands[0]['returncode'] == 255 and not decode(commands[0]['stdout_base64'])
assert decode(commands[0]['stderr_base64']) == b'document-history rollover required for engineering_notes: 386/512 lines, 59506/65536 bytes\n'
assert commands[1]['returncode'] == 0 and not decode(commands[1]['stderr_base64'])
assert decode(commands[1]['stdout_base64']) == b'document-history rollover: engineering_notes archived 272 line(s) as 4960; current is 113/512 lines and 32492/65536 bytes\n'
denials = decode(commands[2]['stderr_base64'])
assert commands[2]['returncode'] == 1 and not decode(commands[2]['stdout_base64'])
assert re.findall(rb'^\[readme-routing\] FAIL: (.*)$', denials, re.M) == [
    b'surface engineering_notes exceeds control: files 48/47',
    b'surface engineering_notes member exceeds control: lines 47/46',
    b'surface engineering_notes member exceeds control: bytes 28469/27857']

for name, producer, support_name, support_count, supplied_count in (
    ('complete-inputs.json', 'complete_inputs.py', 'delegate-inputs.json.gz', 193, 1978),
    ('complete-inputs-final.json', 'complete_inputs_final.py', 'delegate-final-inputs.json.gz', 194, 1979)):
    failure = load(name); verify_producer(failure, producer)
    support = capsule(support_name, failure['support_capsule_sha256'])
    assert len(support) == failure['support_inputs'] == support_count
    assert len(set(support) | set(stages['rolled'])) == failure['provided_inputs'] == supplied_count
    assert failure['result'] == 'pending' and failure['unchanged'] and failure['extras'] == []
    assert failure['original_measurement_sha256'] == sha(raw(PREFIX + 'measurement.json'))
    assert failure['rolled_capsule_sha256'] == sha(raw(PREFIX + 'rolled-inputs.json.gz'))
    assert failure['replay']['returncode'] == 1 and not decode(failure['replay']['stdout_base64'])
    for p, item in support.items():
        assert decode(item['bytes_base64']) == old(p), ('accepted helper/config input', p)
assert b"this project's Git metadata only" in decode(load('complete-inputs-final.json')['replay']['stderr_base64'])
completion = load('complete-inputs-root.json'); verify_producer(completion, 'complete_inputs_root.py')
assert completion['base'] == BASE and completion['result'] == 'PASS' and completion['unchanged']
assert completion['original_measurement_sha256'] == sha(raw(PREFIX + 'measurement.json'))
complete = capsule('root-replay-inputs.json.gz', completion['capsule_sha256'])
assert len(complete) == completion['input_count'] == 1978 and completion['git_directory'] == '.git'
assert completion['replay'] == {k: commands[2][k] for k in ('command', 'returncode', 'stdout_base64', 'stderr_base64')}, 'whole original-project denial recurs'
for name, item in completion['first_supplied_failures'].items():
    assert sha(raw(PREFIX + name)) == item['sha256'] and sha(raw(PREFIX + item['producer'])) == item['producer_sha256']
support_paths = sorted(p for directory in ('tools', 'scripts', 'capability_conformance', 'doctrine', 'knowledge-map/scripts', '.gitattributes', '.knowledge_map.conf') for p in paths(directory))
assert sorted(completion['accepted_support']) == support_paths, 'complete accepted delegate namespace'
for p in support_paths:
    assert completion['accepted_support'][p] == complete[p]['sha256'] == sha(old(p))
    assert decode(complete[p]['bytes_base64']) == raw(p) == old(p) if p != REG else decode(complete[p]['bytes_base64']) == old(p)
assert {'.gitattributes', '.knowledge_map.conf'} <= set(complete)
assert {'perl', 'specs', 't', 'tests', 'docs/knowledge', 'docs/decisions', 'tools'} <= set(completion['directories'])
for key, item in completion['git_inputs'].items():
    revision, p = key.split(':', 1)
    assert decode(item['bytes_base64']) == at(revision, p) and item['sha256'] == sha(at(revision, p))
assert len(completion['git_inputs']) == 4

plan = load('plan.json'); verify_producer(plan, 'admit.py')
assert plan['result'] == 'PASS' and plan['base'] == BASE
assert plan['measurement_sha256'] == sha(raw(PREFIX + 'measurement.json'))
assert plan['completion_sha256'] == sha(raw(PREFIX + 'complete-inputs-root.json'))
for p, item in plan['originals'].items():
    assert decode(item['bytes_base64']) == old(p) and item['sha256'] == sha(old(p)), 'plan original identity is independently Git-bound'
assert set(plan['originals']) == {REG, INDEX}
before = [json.loads(l) for l in old(REG).splitlines()]
after = copy.deepcopy(before)
b = {r['id']: r for r in before if 'id' in r}; a = {r['id']: r for r in after if 'id' in r}
engineering_paths = ['DEVELOPMENT_NOTES.md', MANIFEST] + sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/history/development-notes').glob('*.md'))
decision_paths = sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/decisions').glob('*.md'))
census = dict(engineering_notes=metrics(engineering_paths), decisions=metrics(decision_paths),
              manifest=dict(lines=raw(MANIFEST).count(b'\n'), bytes=len(raw(MANIFEST))))
a['engineering_notes']['limits']['max_files'] = census['engineering_notes']['files']
a['engineering_notes']['member_limits'][MANIFEST] = dict(max_lines=census['manifest']['lines'], max_bytes=census['manifest']['bytes'])
a['decisions']['limits']['max_files'] = len(paths('docs/decisions')) + 1
a['decisions']['limits']['max_total_lines'] = sum(old(p).count(b'\n') for p in paths('docs/decisions')) + raw(ADR).count(b'\n') + 1
assert census == plan['measured'] and census['engineering_notes'] == dict(files=48, lines=29505, bytes=3320839)
assert census['decisions']['files'] == a['decisions']['limits']['max_files'] == 136
assert census['decisions']['lines'] == a['decisions']['limits']['max_total_lines'] == 13285
assert raw(ADR).count(b'\n') == plan['decision_lines'] == 34 and plan['index_line_growth'] == 1
for name in ('engineering_notes', 'decisions'):
    assert plan['old_limits'][name] == b[name]['limits'] and plan['new_limits'][name] == a[name]['limits'], 'exact finite limits; no future reserve'
assert plan['old_contract'] == contract(b['engineering_notes']) and plan['new_contract'] == contract(a['engineering_notes'])
expected_registry = b''.join(line if row == json.loads(line) else compact(row) + b'\n' for line, row in zip(old(REG).splitlines(True), after))
assert raw(REG) == expected_registry, 'only exact member/manifest/sole-decision deltas'
index_row = decode(plan['index_row_base64'])
assert index_row.count(b'\n') == 1 and index_row.startswith(b'| [0135](0135-finite-engineering-notes-member.md) |')
previous_row = re.findall(rb'^\| \[0134\].*\n', old(INDEX), re.M)
assert len(previous_row) == 1
expected_index = old(INDEX).replace(previous_row[0], previous_row[0] + index_row, 1)
assert raw(INDEX) == expected_index and raw(INDEX).index(index_row) < raw(INDEX).index(b'\n## How to add a record'), 'new authority is in the index table'
for p, value in ((REG, expected_registry), (INDEX, expected_index), (ADR, raw(ADR))):
    item = plan['outputs'][p]
    assert decode(item['bytes_base64']) == value and item['sha256'] == sha(value), 'resulting object is independently reconstructed'
assert set(plan['outputs']) == {REG, INDEX, ADR}

control = load('controls.json'); verify_producer(control, 'capture_controls.py')
assert control['command'] == ['perl', PREFIX + 'controls.pl']
process = subprocess.run(control['command'], cwd=ROOT, capture_output=True)
assert process.returncode == control['returncode'] == 0 and process.stdout == decode(control['stdout_base64']) and process.stderr == decode(control['stderr_base64']) == b'', 'exact unchanged production controls recur'
controls = json.loads(process.stdout)
assert controls['production_sha256'] == sha(raw('scripts/check_readme_routing_pressure.pl')) == sha(old('scripts/check_readme_routing_pressure.pl'))
assert controls['instrument_sha256'] == sha(raw(PREFIX + 'controls.pl')) and controls['measured'] == census
assert len(controls['thresholds']) == 30 and len(controls['authority']) == 23
assert all(x['rejected'] == (x['value'] > x['limit']) for x in controls['thresholds'])
assert all(x['observed'] == 'RED' for x in controls['authority'])

preservation = load('preservation.json'); verify_producer(preservation, 'preserve.py')
original_claim = raw(PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json')
assert original_claim == old(CLAIM), 'whole accepted publication independently Git-bound'
original = json.loads(original_claim); historical = copy.deepcopy(original)
bindings = original['claims'][0]['durability']['inputs']
assert len(bindings) == 449 and len(original_claim) == 105765
for item in bindings:
    assert sha(old(item['path'])) == item['sha256'], ('all accepted callback bindings', item['path'])
historical['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert raw(CLAIM) == (json.dumps(historical, indent=2) + '\n').encode(), 'only original publication durability mode/revision changes'
assert preservation['result'] == 'PASS' and preservation['base'] == BASE and len(preservation['selected']) == 1
selected = preservation['selected'][0]
assert selected['path'] == CLAIM and selected['before'] == PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json'
assert selected['sha256'] == sha(original_claim) and selected['bytes'] == 105765
baseline = load('baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json')
assert preservation['baselines'] == [baseline] and baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']).endswith(b'ControlFlow single-statement publication PASS: 449 live inputs; 105765 bytes\n')
assert sorted(x['path'] for x in preservation['census']) == paths('docs/claims')
for item in preservation['census']:
    assert item['sha256'] == sha(old(item['path']))

knowledge = load('knowledge.json'); verify_producer(knowledge, 'knowledge.py')
packed = raw(PREFIX + 'knowledge-inputs.json.gz')
assert sha(packed) == knowledge['capsule_sha256']
scan = json.loads(gzip.decompress(packed))
original_paths = sorted(p for directory in ('docs/knowledge', 'docs/decisions') for p in paths(directory) if p.endswith('.md'))
assert sorted(scan['original']) == original_paths and len(original_paths) == 1485
for p, item in scan['original'].items():
    assert decode(item['bytes_base64']) == old(p), ('full accepted Knowledge custody', p)
assert knowledge['markdown'] == 1486 and knowledge['returncode'] == 0
assert not decode(knowledge['stdout_base64']) and decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
for p, item in scan['current'].items():
    assert raw(p) == decode(item['bytes_base64']) and sha(raw(p)) == item['sha256']
    assert (ROOT / p).stat().st_mode & 0o7777 == item['mode']
assert knowledge['inputs'] == {p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in scan['current'].items()}
cards = [p for p in knowledge['changed_cards'] if p.startswith('docs/knowledge/')]
assert len(cards) == 11 and CARD in cards
for p in cards:
    front, body = raw(p).split(b'\n---\n', 1); old_front, old_body = old(p).split(b'\n---\n', 1)
    assert (body.endswith(old_body) if p == CARD else body == old_body), 'complete dated Knowledge bodies retained'
    assert (PREFIX + 'publish.py').encode() in front
assert sum(len(raw(p)) for p in paths('docs/knowledge')) == 8387290 <= b['knowledge_cards']['limits']['max_total_bytes']
assert len(paths('docs/knowledge')) == b['knowledge_cards']['limits']['max_files'] == 1350
assert raw(CHAPTER) != old(CHAPTER) and b'checks ControlFlow attached parsing' in old(CHAPTER)
assert b'checks ControlFlow attached parsing' not in raw(CHAPTER) and b'ADR0135' in raw(CHAPTER)
book_process = subprocess.run(['python3', PREFIX + 'book-review.py'], cwd=ROOT, capture_output=True)
assert book_process.returncode == 0 and not book_process.stderr, ('complete readonly book proof', book_process.stderr)
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4

# Runtime and all original proof producers remain exact. Changed documentation
# bindings are separately checked above; unrelated inputs cannot silently drift.
changed = set(cards) | {REG, INDEX, MANIFEST, 'DEVELOPMENT_NOTES.md', 'CHANGES.md', 'KNOWLEDGE_MAP.md', CHAPTER}
for item in bindings:
    if item['path'] not in changed:
        assert raw(item['path']) == old(item['path']), ('unchanged original runtime/proof input', item['path'])
for p in ('perl/LinkedSpec/ActionIR/ControlFlow.pm', '.gitmodules', 'tools/roll_document_history.pl', 'tools/test_document_history_rollover.py'):
    assert raw(p) == old(p), ('runtime/tool/dependency boundary unchanged', p)
objects.stdin.close(); assert objects.wait() == 0

names = '''preserve.py preservation.json before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json baseline-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json
measure.py measurement.json original-inputs.json.gz unrolled-inputs.json.gz rolled-inputs.json.gz
complete_inputs.py complete-inputs.json delegate-inputs.json.gz complete_inputs_final.py complete-inputs-final.json delegate-final-inputs.json.gz
complete_inputs_root.py complete-inputs-root.json root-replay-inputs.json.gz admit.py plan.json controls.pl capture_controls.py controls.json
knowledge.py knowledge.json knowledge-inputs.json.gz book.py book.json book-review.py book-review.json review.py'''.split()
inputs = {PREFIX + n for n in names} | set(book['source_inputs']) | set(cards) | {
    CARD, REG, INDEX, ADR, MANIFEST, target, CLAIM, 'KNOWLEDGE_MAP.md', 'DEVELOPMENT_NOTES.md', 'CHANGES.md',
    'tools/roll_document_history.pl', 'tools/test_document_history_rollover.py', 'scripts/check_readme_routing_pressure.pl',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', '.gitattributes', '.knowledge_map.conf', '.gitmodules',
    'knowledge-map/scripts/check_knowledge_map.sh', 'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/knowledge_map.conf'}
inputs |= {x['path'] for x in bindings if x['path'] not in changed}
report = dict(result='PASS', base=BASE, producer_sha256=sha(Path(__file__).read_bytes()),
    population=dict(prior_files=228, callback_bindings=449, complete_inputs=1978, thresholds=30, authority_reds=23,
                    knowledge_markdown=1486, knowledge_facts=1349, knowledge_bytes=8387290, book_inputs=89, book_controls=4),
    measured=census, segment=expected_segment, inputs={p:sha(raw(p)) for p in sorted(inputs)},
    scope='Exact independent Git-backed suffix/root/manifest/finite-registry reconstruction; actual complete original-project old-cap channels and unchanged production controls. Both failed copied-root experiments remain frozen. Full original callback and dated Knowledge custody, current headers and complete book are checked. System Git/Perl/Python/mdBook are environmental dependencies; no copied-root portability or broader callback admission. Canonical staged CI/receipt and hooks separately govern landing. Fixed input census excludes its own report, later artifact evidence, claim and canonical logs.')
destination = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    with destination.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(destination.read_bytes()) == report, 'exact readonly finite admission report'
print('Independent finite review PASS:228 prior files/449 callback bindings/1978 complete inputs;30 thresholds/23 authority REDs;book89/four')
