"""Exercise deeper artifact denials in complete supplied, same-volume roots."""
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
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
TARGET = ROOT / (PREFIX + 'evidence.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
encode = lambda raw: base64.b64encode(raw).decode()
decode = lambda value: base64.b64decode(value, validate=True)
dump = lambda value: (json.dumps(value, indent=2) + '\n').encode()
pack = lambda value: gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0)


def current_inputs():
    paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / PREFIX).iterdir() if p.is_file()}
    paths.discard(PREFIX + 'evidence.json')
    paths.discard(PREFIX + 'evidence-data.json.gz')
    for tail in ['after-native-inputs.json.gz', 'consumers-inputs.json.gz']:
        paths.update(json.loads(gzip.decompress((ROOT / (PREFIX + tail)).read_bytes())))
    knowledge = json.loads(gzip.decompress((ROOT / (PREFIX + 'knowledge-inputs.json.gz')).read_bytes()))
    paths.update(knowledge['current'])
    paths.update(json.loads((ROOT / (PREFIX + 'book-review.json')).read_bytes())['source_inputs'])
    paths.update(['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json',
                  'doctrine/readme_stability/routes.jsonl'])
    paths.update(json.loads((ROOT / (PREFIX + 'validation.json')).read_bytes())['sources'])
    return {path: {'sha256': sha((ROOT / path).read_bytes()),
                   'mode': stat.S_IMODE((ROOT / path).stat().st_mode)} for path in sorted(paths)}


if not sys.argv[1:]:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    for path, item in report['inputs'].items():
        assert sha((ROOT / path).read_bytes()) == item['sha256']
        assert stat.S_IMODE((ROOT / path).stat().st_mode) == item['mode']
    raw = (ROOT / (PREFIX + 'evidence-data.json.gz')).read_bytes()
    assert sha(raw) == report['data_sha256']
    rows = json.loads(gzip.decompress(raw))
    assert len(rows) == 6 and report['rows'] == [{k: r[k] for k in ('name', 'reason')} for r in rows]
    for row in rows:
        assert row['denial']['returncode'] != 0 and row['reason'].encode() in decode(row['denial']['stderr_base64'])
        assert row['restoration']['returncode'] == 0 and not decode(row['restoration']['stderr_base64'])
        assert row['mutations']
    print('Optional FlowExpr artifact controls PASS: six actual deeper denials and exact restorations')
    sys.exit(0)

assert not TARGET.exists(), 'one-shot artifact controls'
identities = current_inputs()
files = {path: (ROOT / path).read_bytes() for path in identities}
rows = []
with tempfile.TemporaryDirectory(prefix='flow-kind-evidence-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        target.chmod(identities[path]['mode'])
    # Only read the owning repository's immutable objects/index; create no Git repo.
    environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))

    def check():
        command = ['python3', PREFIX + 'review.py', '--preflight']
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        return {'command': command, 'returncode': result.returncode,
                'stdout_base64': encode(result.stdout), 'stderr_base64': encode(result.stderr)}

    baseline = check()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])

    def exercise(name, reason, changed):
        for path, raw in changed.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        denial = check()
        try:
            assert denial['returncode'] != 0 and reason.encode() in decode(denial['stderr_base64']), (name, denial)
        finally:
            for path in changed:
                if path in files:
                    (supplied / path).write_bytes(files[path])
                    (supplied / path).chmod(identities[path]['mode'])
                else:
                    (supplied / path).unlink()
        restoration = check()
        rows.append({'name': name, 'reason': reason, 'denial': denial, 'restoration': restoration,
                     'mutations': {p: {'sha256': sha(raw), 'bytes_base64': encode(raw)} for p, raw in changed.items()}})
        (ROOT / (PREFIX + 'evidence-data.json.gz')).write_bytes(pack(rows))
        assert restoration['returncode'] == 0 and not decode(restoration['stderr_base64'])

    data = json.loads(gzip.decompress(files[PREFIX + 'after-native-data.json.gz']))
    for index in (1, 2):
        data[index]['observation']['rows'][0]['authority']['calls'][0]['actual_callback'] = 0
        data[index]['stdout_base64'] = encode((json.dumps(data[index]['observation'], sort_keys=True, separators=(',', ':')) + '\n').encode())
    raw = pack(data)
    metadata = json.loads(files[PREFIX + 'after-native.json'])
    metadata['data_sha256'] = sha(raw)
    exercise('coherent-native-authority', 'actual selected CODE identity or opaque native delegation',
             {PREFIX + 'after-native-data.json.gz': raw, PREFIX + 'after-native.json': dump(metadata)})

    data = json.loads(gzip.decompress(files[PREFIX + 'faults-data.json.gz']))
    data[0]['failures'] = []
    channel = data[0]['channels'][1]
    channel['stdout_base64'] = encode(decode(channel['stdout_base64']).replace(b'not ok ', b'ok '))
    channel['stderr_base64'], channel['returncode'] = '', 0
    raw = pack(data)
    metadata = json.loads(files[PREFIX + 'faults.json'])
    metadata['data_sha256'] = sha(raw)
    metadata['variants'][0]['failures'] = 0
    exercise('hidden-original-inverse', 'actual distinguishing semantic failure population',
             {PREFIX + 'faults-data.json.gz': raw, PREFIX + 'faults-reached.json.gz': raw,
              PREFIX + 'faults.json': dump(metadata)})

    path = PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.4.0.json'
    original = json.loads(files[path])
    original['claims'][0]['statement'] = 'X' + original['claims'][0]['statement'][1:]
    raw = dump(original)
    metadata = json.loads(files[PREFIX + 'preservation.json'])
    metadata['selected'][0].update(sha256=sha(raw), bytes=len(raw))
    exercise('whole-accepted-publication', 'complete original publication bytes',
             {path: raw, PREFIX + 'preservation.json': dump(metadata)})

    data = json.loads(gzip.decompress(files[PREFIX + 'consumers-channels.json.gz']))
    out = decode(data['stdout_base64'])
    header = re.search(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', out, re.M)
    assert header
    data['stdout_base64'] = encode(out[:header.start(1)] + b'forged.t' + out[header.end(1):])
    raw = pack(data)
    metadata = json.loads(files[PREFIX + 'consumers.json'])
    metadata['channels_sha256'] = sha(raw)
    exercise('forged-consumer-header', 'complete ordered consumer header population',
             {PREFIX + 'consumers-channels.json.gz': raw, PREFIX + 'consumers.json': dump(metadata)})

    envelope = json.loads(files[PREFIX + 'book.json'])
    data = json.loads(gzip.decompress(decode(envelope['data'])))
    marker = b'Optional FlowExpr kind lookup'
    row = data['rows'][0]
    row['target_html_base64'] = encode(decode(row['target_html_base64']).replace(marker, b''))
    row['target_marker_present'] = False
    raw = dump(data)
    envelope.update(bytes=len(raw), sha256=sha(raw), data=encode(gzip.compress(raw, mtime=0)))
    exercise('missing-rendered-teaching', 'wrong required FlowExpr rendered teaching oracle',
             {PREFIX + 'book.json': dump(envelope)})

    data = json.loads(gzip.decompress(files[PREFIX + 'after-native-inputs.json.gz']))
    original_path = 'perl/LinkedSpec/OwnerDispatch.pm'
    substitute = 'perl/LinkedSpec/forged_runtime_input.pm'
    item = data.pop(original_path)
    data[substitute] = item
    raw = pack(data)
    metadata = json.loads(files[PREFIX + 'after-native.json'])
    metadata['inputs'][substitute] = metadata['inputs'].pop(original_path)
    metadata['capsule_sha256'] = sha(raw)
    exercise('substituted-runtime-input', 'complete original parent Perl runtime namespace',
             {PREFIX + 'after-native-inputs.json.gz': raw, PREFIX + 'after-native.json': dump(metadata),
              substitute: decode(item['bytes_base64'])})
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
    assert actual == {p: item['sha256'] for p, item in identities.items()}, 'exact supplied restoration'
    assert all(stat.S_IMODE((supplied / p).stat().st_mode) == item['mode'] for p, item in identities.items())

assert all((ROOT / path).read_bytes() == raw for path, raw in files.items()), 'all live inputs unchanged'
data_raw = (ROOT / (PREFIX + 'evidence-data.json.gz')).read_bytes()
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'inputs': identities, 'data_sha256': sha(data_raw), 'baseline': baseline,
          'rows': [{k: r[k] for k in ('name', 'reason')} for r in rows],
          'scope': 'Six actual deeper semantic artifact denials after coherent immediate rehashes, complete supplied inputs/modes and exact restoration. All source bytes are retained in current tracked files, native/consumer/Knowledge capsules or the accepted Git boundary; every supplied identity is listed here. Only read owning Git objects/index through a supplied work-tree view; no Git repository is created or changed. Full mutations and actual channels are retained; live files remain unchanged. This capture adds no runtime observation or broad admission.'}
TARGET.write_bytes(dump(report))
print('Optional FlowExpr artifact controls PASS: six actual deeper denials and exact restorations')
