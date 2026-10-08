"""Independently reconstruct finite publication and retain actual authority/history channels."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REVISION = '47444428a8ceb65cb0ced06625db4eb8a44b8209'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
CURRENT = 'DEVELOPMENT_NOTES.md'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'

def original(path):
    return subprocess.check_output(['git', 'show', REVISION + ':' + path], cwd=ROOT)

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def compact(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()

def channel(raw):
    return {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': sha(raw)}

def decode(value):
    raw = base64.b64decode(value['base64'], validate=True)
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'complete channel byte identity'
    return raw

plan = json.loads((ROOT / (PREFIX + 'capacity-plan.json')).read_bytes())
actual = json.loads((ROOT / (PREFIX + 'capacity-actual.json')).read_bytes())
source_registry = original(REGISTRY).splitlines(keepends=True)
source_rows = [json.loads(line) for line in source_registry]
source_manifest = original(MANIFEST).splitlines(keepends=True)
old_rows = [json.loads(line) for line in source_manifest]
source_root = original(CURRENT)
prior = {row['target_path']: original(row['target_path']) for row in old_rows[1:]}
note = (ROOT / (PREFIX + 'proposed-note.md')).read_bytes() + b'\n'
expected_source_blob = subprocess.check_output(['git', 'rev-parse', REVISION + ':' + CURRENT], cwd=ROOT).decode().strip()

# Run the unchanged real functions; retain this complete recurrence, not an inferred console replay.
control_inputs = [PREFIX + 'capacity-controls.pl', PREFIX + 'capacity-plan.json',
                  'scripts/check_readme_routing_pressure.pl', ADR, 'docs/decisions/INDEX.md']
before = {path: sha((ROOT / path).read_bytes()) for path in control_inputs}
args = ['perl', PREFIX + 'capacity-controls.pl']
process = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
after = {path: sha((ROOT / path).read_bytes()) for path in control_inputs}
control_command = {'args': args, 'exit_code': process.returncode,
                   'stdout': channel(process.stdout), 'stderr': channel(process.stderr),
                   'input_hashes_before': before, 'input_hashes_after': after,
                   'review_producer_sha256': sha(Path(__file__).read_bytes())}
(ROOT / (PREFIX + 'capacity-controls-command.json')).write_text(json.dumps(control_command, indent=2) + '\n')
assert process.returncode == 0 and before == after and process.stderr == b'', 'actual complete control recurrence'
controls = json.loads((ROOT / (PREFIX + 'capacity-controls.json')).read_bytes())

observed = {
    'registry': (ROOT / REGISTRY).read_bytes().splitlines(keepends=True),
    'manifest': (ROOT / MANIFEST).read_bytes().splitlines(keepends=True),
    'root': (ROOT / CURRENT).read_bytes(),
    'archive': (ROOT / plan['archive_record']['target_path']).read_bytes(),
    'prior': {path: (ROOT / path).read_bytes() for path in prior},
    'adr': (ROOT / ADR).read_text(), 'index': (ROOT / 'docs/decisions/INDEX.md').read_text(),
    'actual': actual, 'controls': controls, 'control_command': control_command,
}

def verify(value):
    assert value['prior'] == prior, 'all original immutable archive bytes'
    assert value['manifest'][2:] == source_manifest[1:], 'original manifest bytes and order'
    metadata = copy.deepcopy(old_rows[0]); metadata['segment_count'] += 1
    assert value['manifest'][0] == compact(metadata), 'manifest header changes count only'
    row = json.loads(value['manifest'][1])
    archive = value['archive']
    assert archive and source_root.endswith(archive), 'exact original clean source suffix'
    prefix = source_root[:-len(archive)]
    assert re.search(rb'^## ', archive), 'complete archived records'
    assert archive.startswith(b'## '), 'actual clean record boundary'
    expected_row = {
        'byte_count': len(archive), 'current_path': CURRENT, 'immutable': True,
        'line_count': archive.count(b'\n'),
        'retrieval_command': 'perl tools/read_document_history.pl --surface engineering_notes --segment ' + f"{int(old_rows[1]['segment_id'])-1:04d}",
        'segment_id': f"{int(old_rows[1]['segment_id'])-1:04d}", 'sha256': sha(archive),
        'source_blob': expected_source_blob, 'source_commit': REVISION,
        'source_end_line': source_root.count(b'\n'), 'source_path': CURRENT,
        'source_start_line': prefix.count(b'\n')+1, 'surface': 'engineering_notes',
        'target_path': 'docs/history/development-notes/segment-' + f"{int(old_rows[1]['segment_id'])-1:04d}" + '-' + sha(archive)[:12] + '.md',
        'type': 'segment',
    }
    assert row == expected_row == plan['archive_record'], 'actual archive binding and independently reached source interval'
    start = re.search(rb'^## ', prefix, re.M).start()
    expected_root = prefix[:start] + note + prefix[start:]
    assert expected_root.endswith(b'\n\n') and value['root'] == expected_root[:-1], 'exact original prefix/new note and final separator only'
    assert value['root'] + b'\n' + archive == source_root[:start] + note + source_root[start:], 'complete source reconstruction'
    assert len(value['root']) <= 32768 and value['root'].count(b'\n') <= 256, 'unchanged half-size retention'
    expected_registry = copy.deepcopy(source_rows)
    route = next(item for item in expected_registry if item.get('id') == 'engineering_notes')
    route['limits']['max_files'] += 1
    route['member_limits'][MANIFEST] = {'max_bytes': len(b''.join(value['manifest'])), 'max_lines': len(value['manifest'])}
    assert [json.loads(line) for line in value['registry']] == expected_registry, 'only three finite scalars and all unrelated fields'
    for old_line, new_line in zip(source_registry, value['registry']):
        if json.loads(old_line).get('id') != 'engineering_notes':
            assert old_line == new_line, 'unrelated registry row byte identity'
    assert len(value['registry']) == len(source_registry), 'registry row reach'
    for label, obj in (('Previous routed limits', plan['old_limits']), ('New routed limits', plan['new_limits']),
                       ('Previous routed contract', plan['old_contract']), ('New routed contract', plan['new_contract'])):
        marker = '- ' + label + ': ' + chr(96) + compact(obj).decode().rstrip('\n') + chr(96)
        assert marker in value['adr'].splitlines(), 'exact decision canonical marker'
    assert re.search(r'^- Status: accepted\b', value['adr'], re.M), 'current decision actually accepted'
    assert '(0128-replacement-note-history-capacity.md)' in value['index'], 'current decision actually indexed'
    a = value['actual']
    assert a['complete'] and a['revision'] == REVISION, 'complete actual publication boundary'
    assert a['producer_sha256'] == sha((ROOT / (PREFIX + 'capacity-apply.py')).read_bytes()), 'actual publication producer'
    assert a['plan_sha256'] == sha((ROOT / (PREFIX + 'capacity-plan.json')).read_bytes()), 'actual retained plan'
    assert len(a['commands']) == 2, 'complete ordered pressure/publication command population'
    paths = [REGISTRY, 'tools/roll_document_history.pl', 'tools/read_document_history.pl',
             PREFIX + 'capacity-plan.py', PREFIX + 'capacity-plan.json', PREFIX + 'proposed-note.md', *prior]
    guards = {path: sha(original(path) if path == REGISTRY else (ROOT / path).read_bytes()) for path in paths}
    original_start = re.search(rb'^## ', source_root, re.M).start()
    draft = source_root[:original_start] + note + source_root[original_start:]
    mutable_before = {CURRENT: channel(draft), MANIFEST: channel(b''.join(source_manifest))}
    mutable_after = {CURRENT: channel(value['root']), MANIFEST: channel(b''.join(value['manifest']))}
    for index, option in enumerate(('--check', '--apply')):
        command = a['commands'][index]
        assert command['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', option], 'actual command identity and order'
        assert command['input_hashes_before'] == command['input_hashes_after'] == guards, 'all guarded actual input byte identities'
        assert command['mutable_before'] == mutable_before, 'exact reached mutable input channels'
        expected_after = mutable_before if index == 0 else mutable_after
        assert command['mutable_after'] == expected_after, 'exact reached mutable output channels'
        stdout, stderr = decode(command['stdout']), decode(command['stderr'])
        if index == 0:
            assert command['exit_code'] == 255 and stdout == b'', 'actual pressure RED status'
            expected_error = f"document-history rollover required for engineering_notes: {draft.count(bytes([10]))}/512 lines, {len(draft)}/65536 bytes\n".encode()
            assert stderr == expected_error, 'actual pressure distinguishing error'
        else:
            assert command['exit_code'] == 0 and stderr == b'', 'actual governed publication GREEN status'
            expected_stdout = f"document-history rollover: engineering_notes archived {archive.count(bytes([10]))} line(s) as {row['segment_id']}; current is {value['root'].count(bytes([10]))}/512 lines and {len(value['root'])}/65536 bytes\n".encode()
            assert stdout == expected_stdout, 'actual governed publication complete channel'
    c = value['controls']
    assert c['complete'] and c['instrument_sha256'] == sha((ROOT / (PREFIX + 'capacity-controls.pl')).read_bytes()), 'actual control producer'
    assert c['production_sha256'] == sha((ROOT / 'scripts/check_readme_routing_pressure.pl').read_bytes()), 'actual unchanged production functions'
    assert len(c['thresholds']) == 18 and len(c['controls']) == 7 and all(row['observed'] == 'RED' for row in c['controls']), 'complete actual threshold/rejection reach'
    for item in c['thresholds']:
        assert item['rejected'] == (item['value'] > item['limit']), 'independent threshold comparison'
    assert [item['name'] for item in c['status_observations']] == ['proposed_status', 'missing_status'], 'separate accepted-state diagnostic reach'
    assert all(item['limit_authorized'] is True and item['contract_authorized'] is True for item in c['status_observations']), 'actual observed guard gap; no false rejection claim'
    cmd = value['control_command']
    assert cmd['exit_code'] == 0 and cmd['args'] == ['perl', PREFIX+'capacity-controls.pl'], 'actual complete control command'
    assert cmd['input_hashes_before'] == cmd['input_hashes_after'] == before, 'actual control command input guards'
    assert cmd['review_producer_sha256'] == sha(Path(__file__).read_bytes()), 'actual control capture producer'
    assert decode(cmd['stderr']) == b'' and decode(cmd['stdout']).endswith(b'accepted-state diagnostics retained separately.\n'), 'actual complete control channels'

verify(observed)
corruptions = []
for name in ('archive_byte', 'prior_archive_byte', 'prior_row_order', 'root_byte', 'unrelated_limit',
             'new_source_commit', 'missing_command', 'pressure_exit', 'forged_channel', 'lost_input_guard',
             'unaccepted_decision', 'lost_status_diagnostic', 'wrong_control_producer', 'wrong_control_capture'):
    bad = copy.deepcopy(observed)
    if name == 'archive_byte': bad['archive'] = b'X' + bad['archive'][1:]
    elif name == 'prior_archive_byte':
        path = next(iter(bad['prior'])); bad['prior'][path] = b'X' + bad['prior'][path][1:]
    elif name == 'prior_row_order': bad['manifest'][2:4] = reversed(bad['manifest'][2:4])
    elif name == 'root_byte': bad['root'] += b'X'
    elif name == 'unrelated_limit':
        rows = [json.loads(line) for line in bad['registry']]
        next(item for item in rows if item.get('id') == 'engineering_notes')['limits']['max_total_bytes'] += 1
        bad['registry'] = [compact(item) for item in rows]
    elif name == 'new_source_commit':
        row = json.loads(bad['manifest'][1]); row['source_commit'] = '0'*40; bad['manifest'][1] = compact(row)
    elif name == 'missing_command': bad['actual']['commands'].pop()
    elif name == 'pressure_exit': bad['actual']['commands'][0]['exit_code'] = 0
    elif name == 'forged_channel': bad['actual']['commands'][1]['stdout']['base64'] = base64.b64encode(b'PASS\n').decode()
    elif name == 'lost_input_guard': bad['actual']['commands'][0]['input_hashes_before'].pop(next(iter(bad['actual']['commands'][0]['input_hashes_before'])))
    elif name == 'unaccepted_decision': bad['adr'] = re.sub(r'^- Status:.*$', '- Status: proposed; not accepted', bad['adr'], flags=re.M)
    elif name == 'lost_status_diagnostic': bad['controls']['status_observations'].pop()
    elif name == 'wrong_control_producer': bad['controls']['instrument_sha256'] = '0'*64
    else: bad['control_command']['review_producer_sha256'] = '0'*64
    try:
        verify(bad)
    except AssertionError as error:
        corruptions.append({'name': name, 'observed_red': str(error)})
    else:
        raise AssertionError('corruption admitted: ' + name)

# Independently execute and retain the complete manifest-ordered history query.
history_paths = [MANIFEST, 'tools/read_document_history.pl', *prior, plan['archive_record']['target_path']]
history_before = {path: sha((ROOT / path).read_bytes()) for path in history_paths}
history_args = ['perl', 'tools/read_document_history.pl', '--surface', 'engineering_notes', '--all']
history = subprocess.run(history_args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
history_after = {path: sha((ROOT / path).read_bytes()) for path in history_paths}
expected_history = observed['archive'] + b''.join(prior.values())
assert history.returncode == 0 and history.stderr == b'' and history_before == history_after, 'complete actual history query and guards'
assert history.stdout == expected_history, 'complete manifest-ordered archive bytes'
history_record = {'complete': True, 'args': history_args, 'exit_code': history.returncode,
                  'stdout': channel(history.stdout), 'stderr': channel(history.stderr),
                  'input_hashes_before': history_before, 'input_hashes_after': history_after,
                  'producer_sha256': sha(Path(__file__).read_bytes())}
history_raw = (json.dumps(history_record, sort_keys=True, separators=(',', ':')) + '\n').encode()
history_path = PREFIX + 'capacity-history-channel.json.gz'
(ROOT / history_path).write_bytes(gzip.compress(history_raw, mtime=0))
assert json.loads(gzip.decompress((ROOT / history_path).read_bytes())) == history_record
actual_paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/history/development-notes').glob('*.md')}
assert actual_paths == set(prior) | {plan['archive_record']['target_path']}, 'complete current collection membership'
values = [observed['root'], b''.join(observed['manifest']), observed['archive'], *prior.values()]
metrics = {'files': len(values), 'lines': sum(v.count(b'\n') for v in values), 'bytes': sum(map(len, values))}
assert metrics == plan['collection'], 'independently reconstructed full collection'
result = {'complete': True, 'revision': REVISION, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'prior_archives': len(prior), 'collection': metrics, 'archive_record': plan['archive_record'],
          'retained_root': plan['retained_root'], 'new_manifest': plan['new_manifest'],
          'evidence_controls': corruptions, 'production_thresholds': 18, 'production_red_controls': 7,
          'accepted_state_diagnostics': controls['status_observations'],
          'history_channel': {'path': history_path, 'sha256': sha((ROOT / history_path).read_bytes()),
                              'raw_bytes': len(history_raw), 'stdout_bytes': len(history.stdout), 'stdout_sha256': sha(history.stdout)},
          'scope': 'Exact finite current admission and actual full input/command channels. Accepted-state function gap is retained and separately scheduled .3.1.3; current ADR is explicitly accepted. Exact staged canonical receipt remains required.'}
(ROOT / (PREFIX + 'capacity-verification.json')).write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'complete': True, 'collection': metrics, 'prior_archives': len(prior),
                  'evidence_red': len(corruptions), 'actual_thresholds': 18, 'actual_authority_red': 7,
                  'accepted_state_gap_retained': True, 'full_history_bytes': len(history.stdout)}))
