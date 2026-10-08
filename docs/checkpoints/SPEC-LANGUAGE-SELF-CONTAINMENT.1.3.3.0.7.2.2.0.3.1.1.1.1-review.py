"""Independently recover supplied inputs and check authored occurrence oracles."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-'
BASE = '997f1cb8f32ff4eaa1ba278e124cbaaac1942780'
OWNER = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
CANDIDATE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1-pipeline-candidate.pm'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def read(suffix):
    return (ROOT / (PREFIX + suffix)).read_bytes()

def data(suffix):
    return json.loads(read(suffix))

def unpack(channel):
    assert channel['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(channel['data'], validate=True))
    assert len(raw) == channel['bytes'] and sha(raw) == channel['sha256'], 'channel bytes'
    return raw

def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

def recover_git():
    entries = {}
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', BASE], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            entries[path.decode()] = {'path': path.decode(), 'mode': mode.decode(), 'oid': oid.decode(), 'bytes': int(size)}
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries.values():
            process.stdin.write((entry['oid'] + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            entry['sha256'] = sha(raw)
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    return entries

def origin_oracle(case):
    position = 0
    expected = []
    rebuilt = ''
    for part in case['authored_parts']:
        text = part.get('helper', part.get('text'))
        if 'helper' in part:
            expected.append((part['contract_id'], text, position, position + len(text)))
        position += len(text)
        rebuilt += text
    assert rebuilt == case['action'], 'independent authored pieces'
    return expected

def check_manifest(manifest, original, epoch, raw):
    assert manifest['revision'] == BASE and manifest['epoch'] == epoch, 'original Git boundary'
    overlays = [PREFIX + 'raw-probe.pl'] if raw else [PREFIX + 'cases.json', PREFIX + 'probe.pl']
    if epoch == 'candidate':
        overlays += [OWNER]
    assert manifest['overlays'] == overlays, 'exact declared overlays'
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and set(entries) == set(original) | set(overlays), 'complete supplied population'
    assert manifest['regular_git_inputs'] == len(original), 'regular input count'
    for path, entry in entries.items():
        if path not in overlays:
            assert entry == original[path], 'unchanged original input'
        else:
            source = CANDIDATE if path == OWNER else path
            contents = (ROOT / source).read_bytes()
            assert entry == {'path': path, 'mode': '100644', 'bytes': len(contents), 'sha256': sha(contents),
                             'overlay': True, 'recover_from': source}, 'actual overlay identity'
    return len(entries)

def check_report(report, manifests, original, raw=False):
    assert report['complete'] and report['revision'] == BASE, 'complete actual report'
    for path, digest in report['producer_inputs'].items():
        assert sha((ROOT / path).read_bytes()) == digest, 'actual capture producer'
    assert [epoch['epoch'] for epoch in report['epochs']] == ['original', 'candidate'], 'exact epoch pair'
    cases = [{'id': name} for name in ('capture', 'entry', 'mark')] if raw else data('cases.json')
    packets = {}
    for epoch in report['epochs']:
        name = epoch['epoch']
        count = check_manifest(manifests[name], original, name, raw)
        expected = [(seed, case['id']) for seed in (0, 1, 42) for case in cases]
        assert epoch['complete'] and [(row['seed'], row['case']) for row in epoch['runs']] == expected, 'ordered complete commands'
        for row in epoch['runs']:
            assert row['inputs_before'] == row['inputs_after'] == count, 'actual complete input guards'
            probe = PREFIX + ('raw-probe.pl' if raw else 'probe.pl')
            assert row['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', probe, row['case']], 'actual command'
            assert row['exit'] == 0 and not unpack(row['stderr']), 'actual successful process'
            packet = json.loads(unpack(row['stdout']))
            assert packet['seed'] == str(row['seed']), 'actual hash seed'
            assert packet['substitution'] == packet['plain_substitution' if raw else 'unobserved_substitution'], 'transparent observer'
            if raw:
                assert packet['case'] == row['case']
                assert packet['action'] == 'return(\\(my $value = ' + packet['helper'] + '))', 'raw authored source'
                assert any(d['decision'] == 'legacy_raw_payload' for d in packet['decisions']), 'actual raw producer path'
                calls = packet['calls']
            else:
                case = next(case for case in cases if case['id'] == row['case'])
                assert packet['source'] == case['source'] and packet['action'] == case['action'], 'actual authored source'
                assert packet['source_sha256'] == sha(case['source'].encode())
                assert packet['dump'] == packet['emitted'] and packet['fresh'] is not None, 'actual native/emitted channels'
                assert packet['fresh']['emitted_sha256'] == sha(packet['emitted'].encode()), 'actual fresh source'
                calls = packet['lowering_calls']
                expected_origins = origin_oracle(case)
                actual_origins = []
                # The actual canonical queries retain authority even when the rejected map declines it.
                if name == 'candidate':
                    for query in packet['mapped_spans']:
                        origin = query['original']
                        if origin is None:
                            continue
                        span = origin['source_span']
                        item = (query['event']['contract_id'], origin['raw'], span['start'], span['end'])
                        if item in expected_origins:
                            actual_origins.append(item)
                    assert sorted(actual_origins) == sorted(expected_origins), 'actual exact helper origins'
                for frame in packet['method_frames']:
                    assert isinstance(frame['call_id'], int) and isinstance(frame['args_id'], int), 'actual parser objects'
                    assert frame['call']['args'] is not None
                    for index, value in enumerate(frame['frames']):
                        if value is None:
                            continue
                        span = value['source_span']
                        assert value['source'] == frame['source']
                        assert frame['source'][span['start']:span['end']] == value['raw'] == frame['call']['args'][index], 'actual argument frame'
            assert calls and all(call['context'] == 'scalar' for call in calls), 'actual scalar callbacks'
            assert all(call['input'] == call['event']['raw'] and call['origin']['raw'] == call['input'] for call in calls), 'original callback arguments'
            assert all(call['error'] == '' for call in calls), 'actual callback error effect'
            packets[(name, row['seed'], row['case'])] = packet
    for seed in (0, 1, 42):
        for case in cases:
            before = packets[('original', seed, case['id'])]
            after = packets[('candidate', seed, case['id'])]
            if raw:
                assert before['ast'] == after['ast'], 'same raw AST'
                assert len(before['calls']) == 2 and len(after['calls']) == 1, 'actual lost raw residual callback'
                assert before['calls'][0]['input'] == after['calls'][0]['input'] == before['action']
                assert before['calls'][0]['output'] == after['calls'][0]['output'] == 'return \\(my $value = ' + before['helper'] + ')', 'actual retained raw output'
                assert before['helper'] not in before['substitution'] and before['helper'] in after['substitution'], 'actual raw continuation loss'
            else:
                assert before['ast'] == after['ast'], 'same typed AST'
                if case['id'] == 'entry_group':
                    assert before['native']['value'] == after['native']['value'] == [None], 'nullable group baseline'
                    assert before['fresh']['value'] == after['fresh']['value'] == [None]
                    assert not before['native']['context_error'] and not after['native']['context_error']
                    assert not any(call['contract_id'] == 'entry_group' for call in before['lowering_calls']), 'typed group already consumed'
                    assert all(text not in before['lowering_calls'][0]['output'] for _, text, _, _ in origin_oracle(case)), 'actual typed entry output'
                elif case['id'] in ('literal_capture', 'literal_condition'):
                    assert before['native']['context_error'] and after['native']['context_error'], 'known literal replacement RED'
                else:
                    expected_values = {'nonempty_guard': [['a']], 'repeated_capture': [['aa']], 'named_mark': [['a']],
                                       'raw_array': ['a', 'capture_slice()'], 'entry_named': ['foo']}
                    assert before['native']['value'] == before['fresh']['value'] == expected_values[case['id']], 'original native/fresh baseline'
                    assert not before['native']['context_error'] and before['fresh']['exception'] is None
                    assert after['native']['context_error'] and after['fresh']['exception'], 'candidate continuation RED'
    return packets

original = recover_git()
reports = {name: data(name + 'observations.json') for name in ('', 'raw-')}
manifests = {raw: {epoch: data(raw + epoch + '-inputs.json') for epoch in ('original', 'candidate')} for raw in ('', 'raw-')}
typed = check_report(reports[''], manifests[''], original)
raw = check_report(reports['raw-'], manifests['raw-'], original, raw=True)
controls = []
for name, change, expected in (
    ('incomplete actual capture', lambda r: r.update(complete=False), 'complete actual report'),
    ('lost actual epoch', lambda r: r['epochs'].pop(), 'exact epoch pair'),
    ('failed actual command', lambda r: r['epochs'][0]['runs'][0].update(exit=1), 'actual successful process'),
    ('missing source guard', lambda r: r['epochs'][0]['runs'][0].update(inputs_after=0), 'actual complete input guards'),
    ('wrong hash seed', lambda r: r['epochs'][0]['runs'][0].update(seed=2), 'ordered complete commands'),
    ('forged actual stdout', lambda r: r['epochs'][0]['runs'][0]['stdout'].update(sha256='0' * 64), 'channel bytes')):
    altered = copy.deepcopy(reports[''])
    change(altered)
    try:
        check_report(altered, manifests[''], original)
    except AssertionError as error:
        assert str(error) == expected, (name, str(error))
        controls.append({'name': name, 'observed': 'RED', 'reason': str(error)})
    else:
        raise AssertionError('ineffective evidence control: ' + name)
for name, mutate, expected in (
    ('hide retained canonical origin', lambda p: p['mapped_spans'][0]['original']['source_span'].update(start=999), 'actual exact helper origins'),
    ('forge argument boundary', lambda p: p['method_frames'][0]['frames'][0]['source_span'].update(start=999), 'actual argument frame'),
    ('change callback context', lambda p: p['lowering_calls'][0].update(context='list'), 'actual scalar callbacks'),
    ('change callback input', lambda p: p['lowering_calls'][0].update(input='foreign'), 'original callback arguments')):
    altered = copy.deepcopy(reports[''])
    row = altered['epochs'][1]['runs'][0]
    packet = json.loads(unpack(row['stdout']))
    if name == 'hide retained canonical origin':
        query = next(q for q in packet['mapped_spans'] if q['event']['contract_id'] == 'capture_slice')
        query['original']['source_span']['start'] = 999
    else:
        mutate(packet)
    row['stdout'] = envelope((json.dumps(packet) + '\n').encode())
    try:
        check_report(altered, manifests[''], original)
    except AssertionError as error:
        assert str(error) == expected, (name, str(error))
        controls.append({'name': name, 'observed': 'RED', 'reason': str(error)})
    else:
        raise AssertionError('ineffective authority control: ' + name)

assert subprocess.check_output(['git', 'show', BASE + ':' + OWNER], cwd=ROOT) == (ROOT / OWNER).read_bytes(), 'production unchanged'
result = {'complete': True, 'revision': BASE, 'regular_git_inputs': len(original),
          'actual_commands': len(typed) + len(raw), 'authored_typed_cases': len(data('cases.json')),
          'authored_raw_cases': len(raw) // 6, 'controls': controls,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Four complete supplied source graphs recover independently. Authored cumulative pieces distinguish executable occurrence origins from literal twins. Original/candidate actual scalar callbacks, parser argument frames and full Toolbox channels are retained. Typed entry-group consumption is healthy; capture/mark/entry-named and raw payload continuation loss remains rejected. Literal replacement and unresolved literal classification are previously owned defects. No production repair, opaque-callback transfer proof, full Phase0 or parent closure is claimed.'}
(ROOT / (PREFIX + 'verification.json')).write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
