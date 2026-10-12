"""Actual reason-sensitive artifact forgeries; readonly default checks retained denials."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda raw: base64.b64encode(raw).decode()
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'evidence.json')
command = ['python3', PREFIX + 'review.py']

def invoke():
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'returncode': process.returncode, 'stdout_base64': encode(process.stdout),
            'stderr_base64': encode(process.stderr)}

def packed(value):
    return gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0)

def json_bytes(value):
    return (json.dumps(value, indent=2) + '\n').encode()

names = [
 ('rehashed-native-actual-identity', 'actual callback identity and own eligibility'),
 ('hidden-full-inverse-red', 'actual distinguishing semantic failure population'),
 ('forged-consumer-header', 'complete ordered consumer header population'),
 ('forged-whole-original-publication', 'complete original publication bytes'),
 ('removed-rendered-teaching', 'wrong required FlowExpr rendered teaching oracle'),
]
if sys.argv[1:]:
    assert not target.exists(), 'one-shot semantic controls'
    baseline = invoke()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64']), baseline
    paths = [PREFIX + tail for tail in ['after-native.json', 'after-native-data.json.gz',
             'faults.json', 'faults-data.json.gz', 'faults-reached.json.gz', 'consumers.json',
             'consumers-channels.json.gz', 'preservation.json',
             'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json', 'book.json']]
    original = {p: (ROOT / p).read_bytes() for p in paths}
    rows = []
    for name, reason in names:
        mutations = {}
        if name == 'rehashed-native-actual-identity':
            data = json.loads(gzip.decompress(original[PREFIX + 'after-native-data.json.gz']))
            for index in (1, 2):
                row = next(row for row in data[index]['observation']['rows'] if row['label'].startswith('authority/') and row['options']['known'])
                row['authority']['calls'][0]['actual_callback'] = 0
                data[index]['stdout_base64'] = encode(json.dumps(data[index]['observation'], sort_keys=True, separators=(',', ':')).encode() + b'\n')
            raw = packed(data)
            record = json.loads(original[PREFIX + 'after-native.json'])
            record['data_sha256'] = sha(raw)
            mutations = {PREFIX + 'after-native-data.json.gz': raw, PREFIX + 'after-native.json': json_bytes(record)}
        elif name == 'hidden-full-inverse-red':
            data = json.loads(gzip.decompress(original[PREFIX + 'faults-data.json.gz']))
            inverse = data[0]
            inverse['channels'][1]['stdout_base64'] = encode(decode(inverse['channels'][1]['stdout_base64']).replace(b'\nnot ok ', b'\nok '))
            inverse['channels'][1]['stderr_base64'] = ''
            inverse['channels'][1]['returncode'] = 0
            inverse['failures'] = []
            raw = packed(data)
            record = json.loads(original[PREFIX + 'faults.json'])
            record['data_sha256'] = sha(raw)
            record['variants'][0]['failures'] = 0
            mutations = {PREFIX + 'faults-data.json.gz': raw, PREFIX + 'faults-reached.json.gz': raw,
                         PREFIX + 'faults.json': json_bytes(record)}
        elif name == 'forged-consumer-header':
            data = json.loads(gzip.decompress(original[PREFIX + 'consumers-channels.json.gz']))
            data['stdout_base64'] = encode(decode(data['stdout_base64']).replace(b't/actionir_method_input_captures.t ', b't/forged_consumer.t ', 1))
            raw = packed(data)
            record = json.loads(original[PREFIX + 'consumers.json'])
            record['channels_sha256'] = sha(raw)
            mutations = {PREFIX + 'consumers-channels.json.gz': raw, PREFIX + 'consumers.json': json_bytes(record)}
        elif name == 'forged-whole-original-publication':
            record = json.loads(original[PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'])
            record['claims'][0]['statement'] += ' forged'
            raw = json_bytes(record)
            preservation = json.loads(original[PREFIX + 'preservation.json'])
            preservation['selected'][0].update(sha256=sha(raw), bytes=len(raw))
            mutations = {PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json': raw,
                         PREFIX + 'preservation.json': json_bytes(preservation)}
        else:
            envelope = json.loads(original[PREFIX + 'book.json'])
            book = json.loads(gzip.decompress(decode(envelope['data'])))
            row = book['rows'][0]
            row['target_html_base64'] = encode(decode(row['target_html_base64']).replace(b'Required FlowExpr callbacks', b'removed teaching'))
            row['target_marker_present'] = False
            raw = json_bytes(book)
            envelope.update(bytes=len(raw), sha256=sha(raw), data=encode(gzip.compress(raw, mtime=0)))
            mutations = {PREFIX + 'book.json': json_bytes(envelope)}
        try:
            for path, raw in mutations.items():
                assert raw != original[path], ('actual artifact mutation', name, path)
                (ROOT / path).write_bytes(raw)
            result = invoke()
            row = {'name': name, 'expected_reason': reason,
                   'mutated_bytes_base64': {p: encode(raw) for p, raw in mutations.items()}, **result}
            rows.append(row)
            assert result['returncode'] != 0 and reason.encode() in decode(result['stderr_base64']), (name, result)
        finally:
            for path, raw in original.items():
                (ROOT / path).write_bytes(raw)
        restored = invoke()
        rows[-1]['restoration'] = restored
        assert restored == baseline, ('exact restoration', name)
    data_path = ROOT / (PREFIX + 'evidence-data.json.gz')
    with data_path.open('xb') as output:
        output.write(packed({'baseline': baseline, 'rows': rows}))
    inputs = {p: sha((ROOT / p).read_bytes()) for p in paths + [PREFIX + 'review.py', PREFIX + 'review.json', PREFIX + 'book-review.py', PREFIX + 'evidence.py']}
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'command': command,
              'data_sha256': sha(data_path.read_bytes()), 'inputs': inputs,
              'controls': [{'name': name, 'expected_reason': reason} for name, reason in names],
              'scope': 'Five actual semantic forgeries update immediate hashes and coherent repeated native channels or paired artifact summaries. The unchanged independent reader rejects each for its named deeper reason; original full input bytes and modes are restored after each, then readonly acceptance passes exactly. Production and native instruments are never mutated. Default mode only reads retained controls and checks current identities.'}
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['command'] == command and report['controls'] == [{'name': name, 'expected_reason': reason} for name, reason in names]
    raw = (ROOT / (PREFIX + 'evidence-data.json.gz')).read_bytes()
    assert sha(raw) == report['data_sha256']
    data = json.loads(gzip.decompress(raw))
    assert data['baseline']['returncode'] == 0 and not decode(data['baseline']['stderr_base64'])
    assert [(row['name'], row['expected_reason']) for row in data['rows']] == names
    for row in data['rows']:
        assert row['returncode'] != 0 and row['expected_reason'].encode() in decode(row['stderr_base64'])
        assert row['restoration'] == data['baseline'] and row['mutated_bytes_base64']
        for path, spelling in row['mutated_bytes_base64'].items():
            assert decode(spelling) != (ROOT / path).read_bytes(), 'actual distinguishing retained mutation'
    assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in report['inputs'].items())
print('FlowExpr semantic evidence PASS: five reason-sensitive denials and exact restorations')
