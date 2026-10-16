"""Eight coherent artifact denials with a fixed supplied inventory and exact restoration."""
import base64
import gzip
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
TARGET = ROOT / (PREFIX + 'evidence-final.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = lambda value: base64.b64decode(value, validate=True)
dump = lambda value: (json.dumps(value, indent=2) + '\n').encode()
pack = lambda value: gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
assert sys.argv[1:] in ([], ['--capture'])
NAMES = ['coherent-head-alias', 'coherent-parent-donation', 'hidden-original-inverse',
         'whole-accepted-publication', 'forged-consumer-header', 'missing-rendered-head-teaching',
         'missing-rendered-parser-return-teaching', 'same-bytes-wrong-runtime-path']
if not sys.argv[1:]:
    record = json.loads(TARGET.read_bytes())
    assert record['result'] == 'PASS' and record['producer_sha256'] == sha(Path(__file__).read_bytes())
    for path, identity in record['inputs'].items():
        assert sha((ROOT / path).read_bytes()) == identity['sha256']
        assert stat.S_IMODE((ROOT / path).stat().st_mode) == identity['mode']
    data = (ROOT / (PREFIX + 'evidence-final-data.json.gz')).read_bytes()
    assert sha(data) == record['data_sha256']
    baseline_bytes = (ROOT / (PREFIX + 'evidence-final-baseline.json')).read_bytes()
    assert sha(baseline_bytes) == record['baseline_capture_sha256']
    baseline_record = json.loads(baseline_bytes)
    assert baseline_record['inputs'] == record['inputs'] and baseline_record['baseline'] == record['baseline']
    assert baseline_record['producer_sha256'] == record['producer_sha256']
    rows = json.loads(gzip.decompress(data))
    assert [row['name'] for row in rows] == NAMES
    assert record['rows'] == [{k: row[k] for k in ('name', 'reason')} for row in rows]
    for row in rows:
        assert row['denial']['returncode'] != 0 and row['reason'].encode() in decode(row['denial']['stderr_base64'])
        assert row['restoration']['returncode'] == 0 and not decode(row['restoration']['stderr_base64'])
        assert row['mutations'] and all(sha(decode(item['bytes_base64'])) == item['sha256'] for item in row['mutations'].values())
    print('Attached-parser artifacts PASS:', len(rows), 'coherent deeper denials and exact restorations')
    raise SystemExit(0)
assert not TARGET.exists()
command = ['python3', PREFIX + 'review-accepted.py', '--inventory']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
assert result.returncode == 0 and not result.stderr
paths = set(json.loads(result.stdout)) | {PREFIX + 'evidence-final.py'}
assert PREFIX + 'compat.json' not in paths, 'supplemental standard result is outside preflight custody'
identities = {p: {'sha256': sha((ROOT / p).read_bytes()), 'mode': stat.S_IMODE((ROOT / p).stat().st_mode)} for p in sorted(paths)}
files = {p: (ROOT / p).read_bytes() for p in identities}
rows = []
with tempfile.TemporaryDirectory(prefix='attached-parser-evidence-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, value in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(identities[path]['mode'])
    env = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))

    def check():
        command = ['python3', PREFIX + 'review-accepted.py', '--preflight']
        p = subprocess.run(command, cwd=supplied, env=env, capture_output=True)
        return {'command': command, 'returncode': p.returncode,
                'stdout_base64': encode(p.stdout), 'stderr_base64': encode(p.stderr)}

    baseline = check()
    baseline_record = {'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': identities, 'baseline': baseline}
    (ROOT / (PREFIX + 'evidence-final-baseline.json')).write_bytes(dump(baseline_record))
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64']), baseline

    def exercise(name, reason, changed):
        for path, value in changed.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(value)
            target.chmod(identities[path]['mode'] if path in identities else 0o644)
        denial = check()
        for path in changed:
            if path in files:
                (supplied / path).write_bytes(files[path])
                (supplied / path).chmod(identities[path]['mode'])
            else:
                (supplied / path).unlink()
        restoration = check()
        rows.append({'name': name, 'reason': reason, 'denial': denial, 'restoration': restoration,
                     'mutations': {p: {'sha256': sha(value), 'bytes_base64': encode(value)} for p, value in changed.items()}})
        (ROOT / (PREFIX + 'evidence-final-data.json.gz')).write_bytes(pack(rows))
        assert denial['returncode'] != 0 and reason.encode() in decode(denial['stderr_base64']), (name, denial)
        assert restoration['returncode'] == 0 and not decode(restoration['stderr_base64']), ('exact restoration', name)

    data = json.loads(gzip.decompress(files[PREFIX + 'after-native-data.json.gz']))
    for index in (1, 2):
        row = next(r for r in data[index]['observation']['rows'] if r['label'] == 'ordinary/attached/scalar')
        slot = next(x['fields']['slot'] for x in row['native']['held_slots']['items']
                    if x['fields']['key'] == 'trim_action_ir_value' and x['fields']['number'] == 2)
        assert slot['type'] == 'LVALUE'
        slot['type'] = 'SCALAR'
        data[index]['stdout_base64'] = encode((json.dumps(data[index]['observation'], sort_keys=True, separators=(',', ':')) + '\n').encode())
    value = pack(data)
    meta = json.loads(files[PREFIX + 'after-native.json'])
    meta['data_sha256'] = sha(value)
    exercise('coherent-head-alias', 'every original ordinary native row',
             {PREFIX + 'after-native-data.json.gz': value, PREFIX + 'after-native.json': dump(meta)})

    data = json.loads(gzip.decompress(files[PREFIX + 'after-native-data.json.gz']))
    for index in (1, 2):
        row = next(r for r in data[index]['observation']['rows'] if r['label'] == 'authority/parse/parse_method_function_expr/1/1/scalar')
        assert row['authority']['parent_packet'] == 0
        row['authority']['parent_packet'] = 1
        data[index]['stdout_base64'] = encode((json.dumps(data[index]['observation'], sort_keys=True, separators=(',', ':')) + '\n').encode())
    value = pack(data)
    meta = json.loads(files[PREFIX + 'after-native.json'])
    meta['data_sha256'] = sha(value)
    exercise('coherent-parent-donation', 'no enclosing packet donation',
             {PREFIX + 'after-native-data.json.gz': value, PREFIX + 'after-native.json': dump(meta)})

    data = json.loads(gzip.decompress(files[PREFIX + 'faults-data.json.gz']))
    inverse = data[0]
    inverse['failures'].pop(0)
    channel = inverse['channels'][1]
    channel['stdout_base64'] = encode(decode(channel['stdout_base64']).replace(b'not ok ', b'ok ', 1))
    stderr = decode(channel['stderr_base64'])
    blocks = list(re.finditer(rb'^#   Failed test ', stderr, re.M))
    assert len(blocks) == 194
    stderr = stderr[:blocks[0].start()] + stderr[blocks[1].start():]
    stderr, count = re.subn(rb'Looks like you failed 194 tests of 920', b'Looks like you failed 193 tests of 920', stderr)
    assert count == 1 and channel['returncode'] == 194
    channel['returncode'] = 193
    channel['stderr_base64'] = encode(stderr)
    value = pack(data)
    meta = json.loads(files[PREFIX + 'faults.json'])
    meta['data_sha256'] = sha(value)
    meta['variants'][0]['failures'] = 193
    exercise('hidden-original-inverse', 'exact inverse original194',
             {PREFIX + 'faults-data.json.gz': value, PREFIX + 'faults-reached.json.gz': value,
              PREFIX + 'faults.json': dump(meta)})

    path = PREFIX + 'before-REPO-HYGIENE.17.json'
    data = json.loads(files[path])
    data['claims'][0]['statement'] = 'X' + data['claims'][0]['statement'][1:]
    value = dump(data)
    meta = json.loads(files[PREFIX + 'preservation.json'])
    entry = next(x for x in meta['selected'] if x['before'] == path)
    entry.update(sha256=sha(value), bytes=len(value))
    exercise('whole-accepted-publication', 'whole accepted publication custody',
             {path: value, PREFIX + 'preservation.json': dump(meta)})

    data = json.loads(gzip.decompress(files[PREFIX + 'consumers-channels.json.gz']))
    stdout = decode(data['stdout_base64'])
    header = re.search(rb'^(\S+\.t)[ \t]+\.{2,}[ \t]*$', stdout, re.M)
    assert header
    data['stdout_base64'] = encode(stdout[:header.start(1)] + b'forged.t' + stdout[header.end(1):])
    value = pack(data)
    meta = json.loads(files[PREFIX + 'consumers.json'])
    meta['channels_sha256'] = sha(value)
    exercise('forged-consumer-header', 'complete accepted consumer command/header population',
             {PREFIX + 'consumers-channels.json.gz': value, PREFIX + 'consumers.json': dump(meta)})

    for name, phrase, reason in (
        ('missing-rendered-head-teaching', b'Writes through it change the same trimmed scalar', 'wrong attached-head alias teaching'),
        ('missing-rendered-parser-return-teaching', b'A truthy parser result is forwarded unchanged', 'wrong attached parser return teaching'),
    ):
        envelope = json.loads(files[PREFIX + 'book.json'])
        data = json.loads(gzip.decompress(decode(envelope['data'])))
        row = data['rows'][0]
        html = decode(row['target_html_base64'])
        assert phrase in html
        row['target_html_base64'] = encode(html.replace(phrase, b'', 1))
        value = dump(data)
        envelope.update(bytes=len(value), sha256=sha(value), data=encode(gzip.compress(value, mtime=0)))
        book_bytes = dump(envelope)
        meta = json.loads(files[PREFIX + 'book-review.json'])
        meta['book_capture_sha256'] = sha(book_bytes)
        exercise(name, reason, {PREFIX + 'book.json': book_bytes, PREFIX + 'book-review.json': dump(meta)})

    data = json.loads(gzip.decompress(files[PREFIX + 'after-native-inputs.json.gz']))
    original = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
    substitute = 'perl/LinkedSpec/ActionIR/ControlFlow.shadow.pm'
    item = data.pop(original)
    data[substitute] = item
    value = pack(data)
    meta = json.loads(files[PREFIX + 'after-native.json'])
    meta['inputs'][substitute] = meta['inputs'].pop(original)
    meta['capsule_sha256'] = sha(value)
    exercise('same-bytes-wrong-runtime-path', 'complete native runtime namespace',
             {PREFIX + 'after-native-inputs.json.gz': value, PREFIX + 'after-native.json': dump(meta),
              substitute: decode(item['bytes_base64'])})
    assert [row['name'] for row in rows] == NAMES
    for path, identity in identities.items():
        assert sha((supplied / path).read_bytes()) == identity['sha256']
        assert stat.S_IMODE((supplied / path).stat().st_mode) == identity['mode']
    extras = [p.relative_to(supplied).as_posix() for p in supplied.rglob('*')
              if p.is_file() and p.relative_to(supplied).as_posix() not in identities]
    assert all(p.startswith('.linkedspec-data/') for p in extras), ('only managed wrapper outputs', extras)
assert all((ROOT / path).read_bytes() == value for path, value in files.items())
record = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': identities,
          'data_sha256': sha((ROOT / (PREFIX + 'evidence-final-data.json.gz')).read_bytes()),
          'baseline_capture_sha256': sha((ROOT / (PREFIX + 'evidence-final-baseline.json')).read_bytes()),
          'baseline': baseline, 'rows': [{k: row[k] for k in ('name', 'reason')} for row in rows],
          'managed_wrapper_outputs': extras,
          'scope': str(len(rows)) + ' actual artifact denials after coherent immediate rehashes, with complete '
                   'declared supplied source bytes/modes and exact restoration. The hidden inverse forgery '
                   'also adjusts its stderr diagnostic block, failure summary and exit. The rendered-book '
                   'forgeries update their review capture hash before semantic rejection. Only the owning '
                   'Git objects/index are read through GIT_DIR/GIT_WORK_TREE; no repository is created. '
                   'Wrappers create only managed same-volume outputs. compat.json is excluded from preflight '
                   'custody; final publication separately binds its completed result. No runtime observation '
                   'or original producer is refreshed, and no broader admission is inferred.'}
TARGET.write_bytes(dump(record))
print('Attached-parser artifacts PASS:', len(rows), 'coherent deeper denials and exact restorations')
