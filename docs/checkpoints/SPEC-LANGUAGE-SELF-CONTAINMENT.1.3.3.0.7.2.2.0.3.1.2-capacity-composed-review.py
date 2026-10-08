"""Verify the finite composed candidate without rewriting its rejected predecessor."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
REVISION = '47444428a8ceb65cb0ced06625db4eb8a44b8209'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
CURRENT = 'DEVELOPMENT_NOTES.md'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
INDEX = 'docs/decisions/INDEX.md'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def raw(path): return (ROOT / path).read_bytes()
def load(name): return json.loads(raw(PREFIX + name + '.json'))
def original(path): return subprocess.check_output(['git', 'show', REVISION + ':' + path], cwd=ROOT)
def compact(value): return json.dumps(value, sort_keys=True, separators=(',', ':'))
def channel(value): return {'base64': base64.b64encode(value).decode(), 'bytes': len(value), 'sha256': sha(value)}
def decode(value):
    result = base64.b64decode(value['base64'], validate=True)
    assert len(result) == value['bytes'] and sha(result) == value['sha256'], 'complete retained channel'
    return result

plan = load('capacity-plan')
composition = load('capacity-composition')
initial_claim = load('capacity-initial-claim')
initial_verification = load('capacity-verification')
initial_instrument = load('capacity-instrument-verification')
snapshot = load('capacity-snapshot-verification')
staged_graph = load('capacity-initial-staged-inputs')
base_registry = original(REGISTRY).splitlines(keepends=True)
base_rows = [json.loads(line) for line in base_registry]
base_manifest = original(MANIFEST).splitlines(keepends=True)
base_root = original(CURRENT)
prior = {json.loads(line)['target_path']: original(json.loads(line)['target_path']) for line in base_manifest[1:]}
base_decision_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', REVISION, '--', 'docs/decisions'], cwd=ROOT).decode().splitlines()
base_decisions = {path: original(path) for path in base_decision_paths if path.endswith('.md') and path != INDEX}
assert len(base_decisions) == 127

control_paths = [PREFIX+'capacity-decision-controls.pl', PREFIX+'capacity-composition.json',
                 'scripts/check_readme_routing_pressure.pl', ADR, INDEX]
before = {path: sha(raw(path)) for path in control_paths}
args = ['perl', PREFIX+'capacity-decision-controls.pl']
process = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
after = {path: sha(raw(path)) for path in control_paths}
command = {'args': args, 'exit_code': process.returncode, 'stdout': channel(process.stdout),
           'stderr': channel(process.stderr), 'input_hashes_before': before, 'input_hashes_after': after,
           'review_producer_sha256': sha(Path(__file__).read_bytes())}
(ROOT/(PREFIX+'capacity-decision-controls-command.json')).write_text(json.dumps(command, indent=2)+'\n')
assert process.returncode == 0 and process.stderr == b'' and before == after, 'actual complete decision controls'

observed = {'registry': raw(REGISTRY).splitlines(keepends=True), 'manifest': raw(MANIFEST).splitlines(keepends=True),
            'root': raw(CURRENT), 'archive': raw(plan['archive_record']['target_path']),
            'prior': {path: raw(path) for path in prior},
            'decisions': {p.relative_to(ROOT).as_posix(): p.read_bytes() for p in (ROOT/'docs/decisions').glob('*.md')},
            'composition': composition, 'snapshot': snapshot, 'red': load('capacity-routing-red'),
            'initial_claim': initial_claim, 'controls': load('capacity-decision-controls'), 'command': command}

def verify(value):
    expected = copy.deepcopy(base_rows)
    engineering = next(row for row in expected if row.get('id') == 'engineering_notes')
    assert engineering['limits'] == plan['old_limits'] and engineering['member_limits'] == plan['old_member_limits']
    engineering['limits']['max_files'] += 1
    engineering['member_limits'][MANIFEST] = {'max_lines': len(value['manifest']), 'max_bytes': len(b''.join(value['manifest']))}
    decisions = next(row for row in expected if row.get('id') == 'decisions')
    old_limits = copy.deepcopy(decisions['limits'])
    decisions['limits']['max_files'] += 1
    decisions['limits']['max_total_lines'] = sum(blob.count(b'\n') for blob in value['decisions'].values())
    assert decisions['limits'] == composition['new_decision_limits'], 'exact measured two decision scalars'
    assert [json.loads(line) for line in value['registry']] == expected, 'exact five scalars only'
    assert len(value['registry']) == len(base_registry), 'complete registry rows'
    for old, new in zip(base_registry, value['registry']):
        if json.loads(old).get('id') not in ('engineering_notes', 'decisions'):
            assert old == new, 'all unrelated registry row bytes'
    assert value['prior'] == prior, 'all forty-two original immutable archives'
    assert value['manifest'][2:] == base_manifest[1:], 'all original manifest row bytes/order'
    header = json.loads(base_manifest[0]); header['segment_count'] += 1
    assert value['manifest'][0] == (compact(header)+'\n').encode(), 'header changes count only'
    archive = value['archive']
    assert base_root.endswith(archive) and archive.startswith(b'## '), 'complete original clean suffix'
    source_prefix = base_root[:-len(archive)]
    start = re.search(rb'^## ', source_prefix, re.M).start()
    note = raw(PREFIX+'proposed-note.md') + b'\n'
    expected_root = source_prefix[:start] + note + source_prefix[start:]
    assert expected_root.endswith(b'\n\n') and value['root'] == expected_root[:-1], 'exact retained root and separator'
    assert value['root'] + b'\n' + archive == base_root[:start] + note + base_root[start:], 'complete root/archive reconstruction'
    row = json.loads(value['manifest'][1])
    assert row == plan['archive_record'] and row['sha256'] == sha(archive), 'exact archive source/interval binding'
    assert row['source_commit'] == REVISION and row['source_start_line'] == source_prefix.count(b'\n')+1
    assert row['source_end_line'] == base_root.count(b'\n') and row['byte_count'] == len(archive)
    assert row['source_blob'] == subprocess.check_output(['git','rev-parse',REVISION+':'+CURRENT],cwd=ROOT).decode().strip()
    values = [value['root'], b''.join(value['manifest']), archive, *prior.values()]
    assert {'files':len(values),'lines':sum(v.count(b'\n') for v in values),'bytes':sum(map(len,values))} == plan['collection']
    assert set(value['decisions']) == set(base_decisions) | {INDEX, ADR}, 'complete decision membership'
    assert all(value['decisions'][path] == blob for path,blob in base_decisions.items()), 'all prior accepted decision bytes'
    assert {path:sha(blob) for path,blob in value['decisions'].items() if path != ADR} == composition['unchanged_other_decision_inputs'], 'initial index/prior decision bytes'
    metrics = {'files':len(value['decisions']),'lines':sum(blob.count(b'\n') for blob in value['decisions'].values()),'bytes':sum(map(len,value['decisions'].values()))}
    assert metrics == composition['final_collection'] == {'files':129,'lines':13043,'bytes':959099}, 'exact final decision population'
    adr = value['decisions'][ADR].decode()
    assert sha(value['decisions'][ADR]) == composition['final_decision_sha256'], 'exact composed decision bytes'
    assert re.search(r'^- Status: accepted\b', adr, re.M), 'explicit current accepted state'
    assert '(0128-replacement-note-history-capacity.md)' in value['decisions'][INDEX].decode(), 'current exact index'
    for label,obj in [('Previous routed limits',plan['old_limits']),('New routed limits',plan['new_limits']),
                      ('Previous routed contract',plan['old_contract']),('New routed contract',plan['new_contract']),
                      ('Previous routed limits',old_limits),('New routed limits',decisions['limits'])]:
        assert '- '+label+': `'+compact(obj)+'`' in adr.splitlines(), 'all exact canonical authority markers'
    assert value['composition']['producer_sha256'] == sha(raw(PREFIX+'capacity-compose.py')), 'actual composition producer'
    assert value['composition'] == composition and composition['revision'] == REVISION, 'retained composition'
    assert value['initial_claim'] == initial_claim and len(initial_claim['claims'][0]['durability']['inputs']) == 78, 'exact unadmitted initial claim'
    mutable = {REGISTRY, ADR, 'docs/knowledge/replacement-repair-engineering-history-capacity.md', 'docs/knowledge/routing-decision-accepted-state-gap.md'}
    for entry in initial_claim['claims'][0]['durability']['inputs']:
        if entry['path'] not in mutable:
            assert sha(raw(entry['path'])) == entry['sha256'], 'all unchanged historical artifact bytes'
    red = value['red']
    assert red['complete'] and red['exit_code'] == 1 and red['input_boundary_before'] == red['input_boundary_after'], 'actual complete routing RED'
    assert red['initial_staged_inputs']['sha256'] == sha(raw(PREFIX+'capacity-initial-staged-inputs.json'))
    patch = gzip.decompress(raw(staged_graph['staged_patch']['path']))
    assert sha(patch) == staged_graph['staged_patch']['raw_sha256'] == red['input_boundary_before']['patch_sha256']
    assert sha(raw(staged_graph['staged_patch']['path'])) == staged_graph['staged_patch']['compressed_sha256']
    stderr = decode(red['stderr']); decode(red['stdout']); decode(red['original_first_combined_log'])
    assert b'files 129/128' in stderr and b'aggregate lines 13035/13000' in stderr, 'two actual rejected limits'
    snap = value['snapshot']
    assert snap['complete'] and snap['producer_sha256'] == sha(raw(PREFIX+'capacity-snapshot-review.py')), 'actual snapshot recovery producer'
    assert snap['recovery']['regular_inputs'] == len(staged_graph['entries']) == 5119
    assert snap['recovery']['declared_inputs_recovered'] == 78 and len(snap['recovery']['omitted_guard_inputs_recovered']) == 7, 'complete initial guard closure recovered'
    assert len(snap['controls']) == 4 and all(item['observed_red'] for item in snap['controls']), 'four actual graph RED controls'
    assert initial_verification['complete'] and len(initial_verification['evidence_controls']) == 14
    assert initial_instrument['complete'] and len(initial_instrument['controls']) == 5
    assert initial_verification['producer_sha256'] == sha(raw(PREFIX+'capacity-review.py'))
    assert initial_instrument['producer_sha256'] == sha(raw(PREFIX+'capacity-instrument-review.py'))
    history = json.loads(gzip.decompress(raw(PREFIX+'capacity-history-channel.json.gz')))
    assert decode(history['stdout']) == archive + b''.join(prior.values()) and decode(history['stderr']) == b''
    assert history['exit_code'] == 0 and history['input_hashes_before'] == history['input_hashes_after']
    controls = value['controls']
    assert controls['complete'] and controls['instrument_sha256'] == sha(raw(PREFIX+'capacity-decision-controls.pl'))
    assert controls['production_sha256'] == sha(raw('scripts/check_readme_routing_pressure.pl'))
    assert len(controls['thresholds']) == 12 and len(controls['controls']) == 6
    assert all(item['observed'] == 'RED' for item in controls['controls'])
    assert all(item['rejected'] == (item['value'] > item['limit']) for item in controls['thresholds']), 'independent actual decision thresholds'
    cmd = value['command']
    assert cmd['args'] == args and cmd['exit_code'] == 0 and cmd['input_hashes_before'] == cmd['input_hashes_after'] == before
    assert cmd['review_producer_sha256'] == sha(Path(__file__).read_bytes()), 'actual new control capture producer'
    assert decode(cmd['stderr']) == b'' and decode(cmd['stdout']) == b'Actual decision controls: twelve threshold observations and six authority RED controls PASS.\n'

verify(observed)
controls = []
for name in ('extra_scalar', 'decision_file_allowance', 'prior_decision_byte', 'unaccepted_decision',
             'missing_exact_decision_marker', 'root_byte', 'archive_byte', 'prior_row_order',
             'missing_guard_recovery', 'wrong_snapshot_producer', 'forged_routing_red',
             'lost_actual_control_guard', 'wrong_control_producer'):
    bad = copy.deepcopy(observed)
    if name in ('extra_scalar','decision_file_allowance'):
        rows = [json.loads(line) for line in bad['registry']]
        route = next(row for row in rows if row.get('id') == 'decisions')
        route['limits']['max_total_bytes' if name == 'extra_scalar' else 'max_files'] += 1
        bad['registry'] = [(compact(row)+'\n').encode() for row in rows]
    elif name == 'prior_decision_byte': bad['decisions'][next(iter(base_decisions))] += b'X'
    elif name == 'unaccepted_decision': bad['decisions'][ADR] = re.sub(rb'^- Status:.*$', b'- Status: proposed',bad['decisions'][ADR],flags=re.M)
    elif name == 'missing_exact_decision_marker': bad['decisions'][ADR] = bad['decisions'][ADR].replace(b'13043',b'13044',1)
    elif name == 'root_byte': bad['root'] += b'X'
    elif name == 'archive_byte': bad['archive'] += b'X'
    elif name == 'prior_row_order': bad['manifest'][2:4] = reversed(bad['manifest'][2:4])
    elif name == 'missing_guard_recovery': bad['snapshot']['recovery']['omitted_guard_inputs_recovered'].pop()
    elif name == 'wrong_snapshot_producer': bad['snapshot']['producer_sha256'] = '0'*64
    elif name == 'forged_routing_red': bad['red']['stderr']['base64'] = base64.b64encode(b'PASS\n').decode()
    elif name == 'lost_actual_control_guard': bad['command']['input_hashes_before'].pop(next(iter(bad['command']['input_hashes_before'])))
    else: bad['controls']['instrument_sha256'] = '0'*64
    try: verify(bad)
    except AssertionError as error: controls.append({'name':name,'observed_red':str(error)})
    else: raise AssertionError('composed corruption admitted: '+name)

result = {'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),
          'engineering_collection':plan['collection'],'decision_collection':composition['final_collection'],
          'changed_scalars':5,'composition_controls':controls,'decision_thresholds':12,'decision_authority_red':6,
          'snapshot_regular_inputs':5119,'recovered_omitted_guards':7,
          'scope':'Independent current five-scalar composition; all prior archives and accepted decisions exact. Initial unadmitted candidate, actual two-limit RED, complete staged graph/delta, historical producers/channels and two instrument errors remain unchanged. Actual new decision controls and thirteen distinguishing composed evidence RED; complete resulting-tree/canonical admission remain separately required. No runtime or composed-bypass claim.'}
(ROOT/(PREFIX+'capacity-composed-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'changed_scalars':5,'composition_red':len(controls),'decision_thresholds':12,'decision_authority_red':6,'decision_collection':composition['final_collection']}))
