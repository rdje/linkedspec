"""Readonly semantic-evidence review; --capture runs bounded artifact controls once."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'evidence.json')
names = ('after-native.json', 'after-native-data.json.gz', 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.5.json',
         'consumers.json', 'book.json')


def invoke():
    command = ['python3', PREFIX + 'review.py']
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout_base64': encode(result.stdout), 'stderr_base64': encode(result.stderr)}


def write_json(name, value):
    (ROOT / (PREFIX + name)).write_text(json.dumps(value, indent=2) + '\n')


if sys.argv[1:]:
    assert not target.exists(), 'one-shot artifact controls'
    baseline = invoke()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
    original = {name: {'bytes_base64': encode((ROOT / (PREFIX + name)).read_bytes()),
                       'mode': (ROOT / (PREFIX + name)).stat().st_mode & 0o7777} for name in names}
    archive = ROOT / (PREFIX + 'evidence-originals.json.gz')
    with archive.open('xb') as output:
        output.write(gzip.compress(json.dumps(original, sort_keys=True).encode(), mtime=0))
    rows = []
    controls = [
        ('native-argument-change', 'complete native ordinary ledger'),
        ('parent-donation', 'no parent donation'),
        ('matching-packet-loss', 'matching own packet'),
        ('whole-prior-claim', 'whole prior publication custody'),
        ('missing-consumer', 'complete supplied suite selection'),
        ('rendered-candidate-value', 'native-derived candidate table'),
    ]
    for name, reason in controls:
        try:
            if name in ('native-argument-change', 'parent-donation', 'matching-packet-loss'):
                data = json.loads(gzip.decompress(decode(original['after-native-data.json.gz']['bytes_base64'])))
                rows_native = data[1]['observation']['rows']
                if name == 'native-argument-change':
                    next(x for x in rows_native if x['native']['calls'])['native']['calls'][0]['first_is_caller_slot'] = 1
                elif name == 'parent-donation':
                    rows_native[0]['authority']['parent_packet'] = 1
                else:
                    next(x for x in rows_native if x['label'] == 'authority/direct/actual/scalar')['authority']['child_packets'] = 0
                # Both fresh observations receive the same coherent forgery.
                data[1]['stdout_base64'] = encode(json.dumps(data[1]['observation'], sort_keys=True, separators=(',', ':')).encode())
                data[2] = data[1]
                payload = gzip.compress(json.dumps(data, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
                (ROOT / (PREFIX + 'after-native-data.json.gz')).write_bytes(payload)
                record = json.loads(decode(original['after-native.json']['bytes_base64']))
                record['data_sha256'] = sha(payload)
                write_json('after-native.json', record)
            elif name == 'whole-prior-claim':
                record = json.loads(decode(original['before-PERL-PRIVATE-FACTORY-CAPTURE.5.5.json']['bytes_base64']))
                record['claims'][0]['statement'] += ' changed'
                write_json('before-PERL-PRIVATE-FACTORY-CAPTURE.5.5.json', record)
            elif name == 'rendered-candidate-value':
                envelope = json.loads(decode(original['book.json']['bytes_base64']))
                book = json.loads(gzip.decompress(decode(envelope['data'])))
                for row in book['rows']:
                    html = decode(row['target_html_base64'])
                    if html:
                        old = b'Candidate accepted</td><td>13</td><td>13</td>'
                        assert html.count(old) == 1
                        row['target_html_base64'] = encode(html.replace(old, b'Candidate accepted</td><td>113</td><td>13</td>', 1))
                payload = json.dumps(book, sort_keys=True, separators=(',', ':')).encode()
                envelope.update(data=encode(gzip.compress(payload, mtime=0)), bytes=len(payload), sha256=sha(payload))
                write_json('book.json', envelope)
            else:
                record = json.loads(decode(original['consumers.json']['bytes_base64']))
                record['command'] = record['command'][:-1]
                write_json('consumers.json', record)
            changed = {n: sha((ROOT / (PREFIX + n)).read_bytes()) for n in names
                       if (ROOT / (PREFIX + n)).read_bytes() != decode(original[n]['bytes_base64'])}
            observed = invoke()
            row = {'name': name, 'expected_reason': reason, 'changed': changed, 'rejection': observed}
            rows.append(row)
            write_json('evidence-reached.json', {'baseline': baseline, 'controls': rows})
            assert observed['returncode'] != 0 and reason.encode() in decode(observed['stderr_base64']), ('distinguishing denial', name)
        finally:
            for filename, item in original.items():
                path = ROOT / (PREFIX + filename)
                path.write_bytes(decode(item['bytes_base64']))
                path.chmod(item['mode'])
        restored = invoke()
        row['restoration'] = restored
        write_json('evidence-reached.json', {'baseline': baseline, 'controls': rows})
        assert restored['returncode'] == 0 and not decode(restored['stderr_base64'])
        assert restored['stdout_base64'] == baseline['stdout_base64'], 'exact readonly restoration'
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
              'originals_sha256': sha(archive.read_bytes()), 'baseline': baseline, 'controls': rows,
              'scope': 'Six actual artifact denials and byte/mode-exact restoration. Native data forgeries rehash their outer report and coherent recurrence; independent original ordinary and callback/publication predicates must reject them before final publication identity comparison. Whole prior claim and exact accepted consumer command are independently derived from Git. A coherently rehashed rendered candidate counter is rejected against the native-derived table before final report identity comparison. No live runtime source is mutated.'}
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
archive = (ROOT / (PREFIX + 'evidence-originals.json.gz')).read_bytes()
assert sha(archive) == report['originals_sha256']
original = json.loads(gzip.decompress(archive))
for name, item in original.items():
    path = ROOT / (PREFIX + name)
    assert path.read_bytes() == decode(item['bytes_base64']) and path.stat().st_mode & 0o7777 == item['mode']
assert len(report['controls']) == 6
for row in report['controls']:
    assert row['changed'] and row['rejection']['returncode'] != 0
    assert row['expected_reason'].encode() in decode(row['rejection']['stderr_base64'])
    assert row['restoration'] == report['baseline']
print('Direct/rule evidence PASS:6 distinguishing artifact denials; exact restoration')
