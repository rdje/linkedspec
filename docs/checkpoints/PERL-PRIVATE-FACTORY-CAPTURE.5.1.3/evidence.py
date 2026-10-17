"""Actual semantic corruption controls; readonly default, one-shot --capture.

Only this leaf's new artifacts and owned index are temporarily replaced. Their
complete originals are persisted before the first write, then restored in finally.
"""
import base64
import copy
import gzip
import hashlib
import json
import stat
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
REG = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
sha = lambda b: hashlib.sha256(b).hexdigest()
encode = lambda b: base64.b64encode(b).decode()
decode = lambda b: base64.b64decode(b, validate=True)
dump = lambda v: (json.dumps(v, indent=2) + '\n').encode()
pack = lambda v: gzip.compress(json.dumps(v, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
raw = lambda p: (ROOT / p).read_bytes()
TARGET = ROOT / (PREFIX + 'evidence.json')
NAMES = ['omitted-prior-history', 'forged-original-registry', 'forged-resulting-registry',
         'displaced-authority-index', 'altered-whole-callback-publication']
assert sys.argv[1:] in ([], ['--capture'])
if not sys.argv[1:]:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['reader_sha256'] == sha(raw(PREFIX + 'final-review.py'))
    for p, item in report['inputs'].items():
        assert sha(raw(p)) == item['sha256'] and stat.S_IMODE((ROOT / p).stat().st_mode) == item['mode']
    packed = raw(PREFIX + 'evidence-data.json.gz')
    assert sha(packed) == report['data_sha256']
    rows = json.loads(gzip.decompress(packed))
    assert [r['name'] for r in rows] == NAMES and len(rows) == 5
    baseline_raw = raw(PREFIX + 'evidence-baseline.json.gz')
    assert sha(baseline_raw) == report['baseline_sha256']
    baseline = json.loads(gzip.decompress(baseline_raw))
    assert baseline['baseline']['returncode'] == 0 and not decode(baseline['baseline']['stderr_base64'])
    for p, item in baseline['originals'].items():
        assert raw(p) == decode(item['bytes_base64']) and sha(raw(p)) == item['sha256']
    for row in rows:
        assert row['denial']['returncode'] != 0 and row['reason'].encode() in decode(row['denial']['stderr_base64'])
        assert row['restoration']['returncode'] == 0 and not decode(row['restoration']['stderr_base64'])
        assert row['exact_restoration']
        for p, item in row['mutations'].items():
            assert p in baseline['originals'] and sha(decode(item['bytes_base64'])) == item['sha256']
            assert item['sha256'] != baseline['originals'][p]['sha256']
    assert json.loads(raw(PREFIX + 'evidence-progress.json'))['result'] == 'PASS'
    print('Finite admission evidence PASS:five semantic REDs/full channels/exact byte and mode restorations')
    raise SystemExit(0)

assert not TARGET.exists(), 'one-shot artifact capture'
review = json.loads(raw(PREFIX + 'review.json'))
identities = {p:dict(sha256=sha(raw(p)), mode=stat.S_IMODE((ROOT / p).stat().st_mode)) for p in review['inputs']}
command = ['python3', PREFIX + 'final-review.py']
def check():
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return dict(command=command, returncode=process.returncode,
                stdout_base64=encode(process.stdout), stderr_base64=encode(process.stderr))
baseline = check()
targets = [PREFIX + n for n in ('measurement.json', 'plan.json', 'preservation.json',
           'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json')] + [INDEX]
originals = {p:dict(bytes_base64=encode(raw(p)), sha256=sha(raw(p)),
                   mode=stat.S_IMODE((ROOT / p).stat().st_mode)) for p in targets}
baseline_value = pack(dict(producer_sha256=sha(Path(__file__).read_bytes()), baseline=baseline,
                           inputs=identities, originals=originals))
with (ROOT / (PREFIX + 'evidence-baseline.json.gz')).open('xb') as output:
    output.write(baseline_value)
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64']), baseline
rows = []
progress_path = ROOT / (PREFIX + 'evidence-progress.json')
def exercise(name, reason, changes):
    assert set(changes) <= set(originals), 'only pre-owned mutable control targets'
    progress_path.write_bytes(dump(dict(result='in-flight', name=name,
        recovery=PREFIX + 'evidence-baseline.json.gz', restore_paths=sorted(changes))))
    try:
        for p, value in changes.items():
            (ROOT / p).write_bytes(value)
        denial = check()
    finally:
        for p in changes:
            (ROOT / p).write_bytes(decode(originals[p]['bytes_base64']))
            (ROOT / p).chmod(originals[p]['mode'])
    restoration = check()
    restored = all(raw(p) == decode(v['bytes_base64']) and
                   stat.S_IMODE((ROOT / p).stat().st_mode) == v['mode'] for p, v in originals.items())
    rows.append(dict(name=name, reason=reason, denial=denial, restoration=restoration,
        exact_restoration=restored, mutations={p:dict(sha256=sha(v),bytes_base64=encode(v)) for p,v in changes.items()}))
    (ROOT / (PREFIX + 'evidence-data.json.gz')).write_bytes(pack(rows))
    progress_path.write_bytes(dump(dict(result='restored', name=name, completed=len(rows))))
    assert denial['returncode'] != 0 and reason.encode() in decode(denial['stderr_base64']), (name, denial)
    assert restoration['returncode'] == 0 and not decode(restoration['stderr_base64']) and restored, (name, restoration)

p = PREFIX + 'measurement.json'; value = json.loads(raw(p))
del value['preserved'][next(iter(value['preserved']))]
exercise(NAMES[0], 'complete prior history/decision census', {p:dump(value)})

p = PREFIX + 'plan.json'; value = json.loads(raw(p))
forged = decode(value['originals'][REG]['bytes_base64']) + b'\n'
value['originals'][REG] = dict(sha256=sha(forged), bytes_base64=encode(forged))
exercise(NAMES[1], 'plan original identity is independently Git-bound', {p:dump(value)})

value = json.loads(raw(p))
registry = [json.loads(l) for l in decode(value['outputs'][REG]['bytes_base64']).splitlines()]
next(r for r in registry if r.get('id') == 'engineering_notes')['limits']['max_files'] += 1
forged = b''.join(json.dumps(r,sort_keys=True,separators=(',',':')).encode()+b'\n' for r in registry)
value['outputs'][REG] = dict(sha256=sha(forged),bytes_base64=encode(forged))
exercise(NAMES[2], 'resulting object is independently reconstructed', {p:dump(value)})

value = json.loads(raw(p)); line = decode(value['index_row_base64'])
forged = raw(INDEX).replace(line,b'',1) + b'\n' + line
value['outputs'][INDEX] = dict(sha256=sha(forged),bytes_base64=encode(forged))
exercise(NAMES[3], 'new authority is in the index table', {p:dump(value),INDEX:forged})

p = PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json'
value = json.loads(raw(p)); value['claims'][0]['statement'] = 'Altered ' + value['claims'][0]['statement']
forged = dump(value)
preservation_path = PREFIX + 'preservation.json'; value = json.loads(raw(preservation_path))
value['selected'][0].update(sha256=sha(forged),bytes=len(forged))
exercise(NAMES[4], 'whole accepted publication independently Git-bound', {p:forged,preservation_path:dump(value)})

assert [r['name'] for r in rows] == NAMES
assert all(sha(raw(p)) == item['sha256'] and stat.S_IMODE((ROOT / p).stat().st_mode) == item['mode'] for p,item in identities.items())
progress_path.write_bytes(dump(dict(result='PASS', completed=5, recovery=PREFIX+'evidence-baseline.json.gz', in_flight=[])))
report = dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),reader_sha256=sha(raw(PREFIX+'final-review.py')),
    inputs=identities,data_sha256=sha(raw(PREFIX+'evidence-data.json.gz')),baseline_sha256=sha(baseline_value),
    rows=[dict(name=r['name'],reason=r['reason']) for r in rows],
    scope='Five actual independent-reader semantic denials after coherent immediate rehashes, with all changed source bytes/full channels and exact restoration. Complete originals are durable before any mutation; finally restores only new leaf-owned artifacts and its owned index. Original-root Git is read-only. No immutable history/runtime/checker source is mutated and no observation or executed producer refreshed. These controls do not replace exact staged canonical admission.')
TARGET.write_bytes(dump(report))
print('Finite admission evidence PASS:five semantic REDs/full channels/exact byte and mode restorations')
