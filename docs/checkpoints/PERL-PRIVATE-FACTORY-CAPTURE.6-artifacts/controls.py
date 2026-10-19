"""Actual bit, omission and order denials; default only reviews retained observations."""
import copy
import gzip
import json
import subprocess
import sys
from pathlib import Path
import artifact as a

assert sys.argv[1:] in ([], ['--capture'])
record_path = a.ROOT / (a.HOME + 'controls.json')
rows_path = a.ROOT / (a.HOME + 'controls-reached.json.gz')
originals_path = a.ROOT / (a.HOME + 'control-originals.json.gz')
command = ['python3', a.SELF, '--parts-only']


def observe():
    run = subprocess.run(command, cwd=a.ROOT, capture_output=True)
    return dict(command=command, returncode=run.returncode,
                stdout_base64=a.encode(run.stdout), stderr_base64=a.encode(run.stderr))


def candidates(originals):
    manifest = json.loads(a.decode(originals[a.MANIFEST]['base64']))
    part_path = manifest['parts'][0]['path']
    corrupt = bytearray(a.decode(originals[part_path]['base64'])); corrupt[0] ^= 1
    missing = copy.deepcopy(manifest)
    missing['parts'] = missing['parts'][:-1]
    missing['raw_bytes'] = sum(item['bytes'] for item in missing['parts'])
    reordered = copy.deepcopy(manifest)
    reordered['parts'][0], reordered['parts'][1] = reordered['parts'][1], reordered['parts'][0]
    return [
        ('corrupted-part', part_path, bytes(corrupt), 'part byte identity', a.HOME + 'counterfactual-part-000.bin'),
        ('omitted-part', a.MANIFEST, (json.dumps(missing, indent=1) + '\n').encode(),
         'complete part population', a.HOME + 'counterfactual-missing.json.gz'),
        ('reordered-parts', a.MANIFEST, (json.dumps(reordered, indent=1) + '\n').encode(),
         'ordered part population', a.HOME + 'counterfactual-order.json.gz'),
    ]


if sys.argv[1:]:
    assert not record_path.exists() and not originals_path.exists() and not rows_path.exists()
    assert not (a.ROOT / a.RAW).exists(), 'normal parts-only reader leaves no assembled copy'
    manifest = a.load_manifest()
    originals = {}
    for path in (a.MANIFEST, manifest['parts'][0]['path']):
        source = a.ROOT / path
        value = source.read_bytes()
        originals[path] = dict(base64=a.encode(value), sha256=a.sha(value), mode=source.stat().st_mode & 0o7777)
    with originals_path.open('xb') as output:
        output.write(gzip.compress(json.dumps(originals, sort_keys=True).encode(), mtime=0))
    baseline = observe()
    assert baseline['returncode'] == 0 and not a.decode(baseline['stderr_base64'])
    rows = []
    for name, path, value, reason, retained in candidates(originals):
        target = a.ROOT / path
        with (a.ROOT / retained).open('xb') as output:
            output.write(gzip.compress(value, mtime=0) if retained.endswith('.gz') else value)
        try:
            target.write_bytes(value)
            target.chmod(originals[path]['mode'])
            negative = observe()
            assert target.read_bytes() == value
        finally:
            for restore_path, item in originals.items():
                (a.ROOT / restore_path).write_bytes(a.decode(item['base64']))
                (a.ROOT / restore_path).chmod(item['mode'])
        restored = observe()
        row = dict(name=name, path=path, reason=reason, retained=retained,
                   counterfactual_sha256=a.sha(value), mode=originals[path]['mode'],
                   negative=negative, restored=restored)
        rows.append(row)
        rows_path.write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
        assert negative['returncode'] != 0 and reason.encode() in a.decode(negative['stderr_base64']), row
        assert restored == baseline and not (a.ROOT / a.RAW).exists(), row
    report = dict(result='PASS', producer_sha256=a.sha(Path(__file__).read_bytes()), baseline=baseline,
        originals_sha256=a.sha(originals_path.read_bytes()), reached_sha256=a.sha(rows_path.read_bytes()),
        controls=[dict(name=row['name'], reason=row['reason'], retained=row['retained']) for row in rows],
        scope='Three actual whole-file counterfactual CLI denials and exact byte/mode restoration. '
              'The complete corrupted part and both complete altered manifests are retained; no '
              'native producer is run and no compatibility copy is created by these controls.')
    with record_path.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')

report = json.loads(record_path.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == a.sha(Path(__file__).read_bytes())
assert a.sha(originals_path.read_bytes()) == report['originals_sha256']
assert a.sha(rows_path.read_bytes()) == report['reached_sha256']
originals = json.loads(gzip.decompress(originals_path.read_bytes()))
rows = json.loads(gzip.decompress(rows_path.read_bytes()))
assert len(rows) == len(report['controls']) == 3
for path, item in originals.items():
    assert (a.ROOT / path).read_bytes() == a.decode(item['base64'])
    assert (a.ROOT / path).stat().st_mode & 0o7777 == item['mode']
for row, (name, path, value, reason, retained) in zip(rows, candidates(originals)):
    actual = (a.ROOT / retained).read_bytes()
    if retained.endswith('.gz'): actual = gzip.decompress(actual)
    assert actual == value and a.sha(actual) == row['counterfactual_sha256']
    assert (row['name'], row['path'], row['reason'], row['retained']) == (name, path, reason, retained)
    assert row['mode'] == originals[path]['mode']
    assert row['negative']['returncode'] != 0 and row['negative']['command'] == command
    assert reason.encode() in a.decode(row['negative']['stderr_base64'])
    assert row['restored'] == report['baseline'] and row['restored']['returncode'] == 0
assert a.part_bytes(a.load_manifest())
print('Artifact part controls PASS:3 actual denials; complete counterfactuals; exact restoration')
