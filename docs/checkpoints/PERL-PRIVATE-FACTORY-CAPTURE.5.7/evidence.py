"""Readonly semantic evidence controls; --capture mutates bounded artifacts once."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'evidence.json')
names = ('after-native.json', 'after-native-data.json.gz',
         'before-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json', 'consumers.json', 'book.json')

def invoke():
    command = ['python3', PREFIX + 'compose.py']
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return dict(command=command, returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))

def write_json(name, value):
    (ROOT / (PREFIX + name)).write_text(json.dumps(value, indent=2) + '\n')

if sys.argv[1:]:
    assert not target.exists(), 'one-shot artifact controls'
    baseline = invoke()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
    originals = {name: dict(bytes_base64=encode((ROOT / (PREFIX + name)).read_bytes()),
        mode=(ROOT / (PREFIX + name)).stat().st_mode & 0o7777) for name in names}
    archive = ROOT / (PREFIX + 'evidence-originals.json.gz')
    with archive.open('xb') as output:
        output.write(gzip.compress(json.dumps(originals, sort_keys=True).encode(), mtime=0))
    rows = []
    for name, reason in (
            ('native-error-effect', 'complete native ordinary ledger'),
            ('opaque-reference-grant', 'actual native callback selection'),
            ('fixed-provider-attempt-loss', 'observed in-scope provider registration attempts'),
            ('missing-selection-observation', 'complete selection observation population'),
            ('whole-prior-claim', 'whole prior publication custody'),
            ('missing-consumer', 'complete supplied suite selection'),
            ('rendered-provider-key', 'native-derived provider table')):
        try:
            if name in ('native-error-effect', 'opaque-reference-grant', 'fixed-provider-attempt-loss', 'missing-selection-observation'):
                data = json.loads(gzip.decompress(decode(originals['after-native-data.json.gz']['bytes_base64'])))
                native_rows = data[1]['observation']['rows']
                if name == 'native-error-effect':
                    native_rows[0]['successful_error'] = 'forged-successful-error-effect'
                elif name == 'opaque-reference-grant':
                    row = next(r for r in native_rows if r['label'] == 'copied-name-trim_action_ir_value')
                    selection = next(r for r in row['authority']['values'][0] if r['key'] == 'trim_action_ir_value')
                    assert selection['selected'] == 0
                    selection['selected'] = 1
                elif name == 'missing-selection-observation':
                    assert len(native_rows[0]['authority']['values']) == 1
                    native_rows[0]['authority']['values'] = []
                else:
                    row = next(r for r in native_rows if r['label'] == 'custom-native-alias' and r['context'] == 'scalar')
                    assert len(row['authority']['registrations']) == 1
                    row['authority']['registrations'] = []
                data[1]['stdout_base64'] = encode(json.dumps(data[1]['observation'], sort_keys=True, separators=(',', ':')).encode() + b'\n')
                data[2] = copy.deepcopy(data[1])
                payload = gzip.compress(json.dumps(data, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
                (ROOT / (PREFIX + 'after-native-data.json.gz')).write_bytes(payload)
                index = json.loads(decode(originals['after-native.json']['bytes_base64']))
                index.update(data_sha256=sha(payload), warm_raw_recurrence=True,
                    cold_raw_recurrence=data[3] == data[4])
                write_json('after-native.json', index)
            elif name == 'whole-prior-claim':
                value = json.loads(decode(originals['before-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json']['bytes_base64']))
                value['claims'][0]['statement'] += ' altered'
                write_json('before-PERL-PRIVATE-FACTORY-CAPTURE.5.6.json', value)
            elif name == 'missing-consumer':
                value = json.loads(decode(originals['consumers.json']['bytes_base64']))
                value['command'] = value['command'][:-1]
                write_json('consumers.json', value)
            else:
                envelope = json.loads(decode(originals['book.json']['bytes_base64']))
                book = json.loads(gzip.decompress(decode(envelope['data'])))
                for row in book['rows']:
                    html = decode(row['target_html_base64'])
                    if html:
                        old = b'<td><code>extract_array_symbol_name</code></td><td>Fixed provider and actual retained definition</td>'
                        assert html.count(old) == 1
                        row['target_html_base64'] = encode(html.replace(old,
                            b'<td><code>extract_hash_symbol_name</code></td><td>Fixed provider and actual retained definition</td>', 1))
                payload = json.dumps(book, sort_keys=True, separators=(',', ':')).encode()
                envelope.update(data=encode(gzip.compress(payload, mtime=0)), bytes=len(payload), sha256=sha(payload))
                write_json('book.json', envelope)
            changed = {n: sha((ROOT / (PREFIX + n)).read_bytes()) for n in names
                if (ROOT / (PREFIX + n)).read_bytes() != decode(originals[n]['bytes_base64'])}
            observed = invoke()
            row = dict(name=name, expected_reason=reason, changed=changed, rejection=observed)
            rows.append(row)
            write_json('evidence-reached.json', dict(baseline=baseline, controls=rows))
            assert observed['returncode'] != 0 and reason.encode() in decode(observed['stderr_base64']), ('distinguishing denial', name)
        finally:
            for filename, item in originals.items():
                path = ROOT / (PREFIX + filename)
                path.write_bytes(decode(item['bytes_base64']))
                path.chmod(item['mode'])
        restored = invoke()
        row['restoration'] = restored
        write_json('evidence-reached.json', dict(baseline=baseline, controls=rows))
        assert restored == baseline, 'exact readonly restoration'
    report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
        originals_sha256=sha(archive.read_bytes()), baseline=baseline, controls=rows,
        scope='Seven actual semantic artifact denials with byte/mode-exact restoration. Native forgeries coherently update parsed/raw JSON, matching warm recurrence, its declaration and outer hashes. Independent original ordinary, provider identity/attempt and fixed accepted command/claim predicates reject them; rendered provider keys are checked against native map data before final report identity comparison. Live runtime source is never mutated.')
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
archive = (ROOT / (PREFIX + 'evidence-originals.json.gz')).read_bytes()
assert sha(archive) == report['originals_sha256']
originals = json.loads(gzip.decompress(archive))
for name, item in originals.items():
    path = ROOT / (PREFIX + name)
    assert path.read_bytes() == decode(item['bytes_base64']) and path.stat().st_mode & 0o7777 == item['mode']
assert len(report['controls']) == 7
for row in report['controls']:
    assert row['changed'] and row['rejection']['returncode'] != 0
    assert row['expected_reason'].encode() in decode(row['rejection']['stderr_base64'])
    assert row['restoration'] == report['baseline']
print('Mixed-default evidence PASS:7 distinguishing artifact denials; exact restoration')
