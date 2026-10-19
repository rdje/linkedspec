"""Actual isolated transport/draft denials with exact healthy restorations."""
import copy
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

HOME = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12-portability/'
ORIGINAL = HOME + 'original.json.gz'
VIEW = c.HOME + 'render-build.json'
COMMAND = ['python3', HOME + 'review.py', '--transport-only']


def variants(inputs):
    original = json.loads(gzip.decompress(c.decode(inputs[ORIGINAL]['base64'])))
    view = c.decode(inputs[VIEW]['base64'])
    raw = c.decode(original['before_images'][VIEW]['base64'])
    assert view == raw.replace(b'/', b'\\/')
    changed = json.loads(view)
    changed['command'][-1] += '/changed-output'
    altered = json.dumps(changed, indent=1).encode().replace(b'/', b'\\/') + b'\n'
    assert json.loads(altered) != json.loads(raw)
    forged = copy.deepcopy(original)
    claim = json.loads(c.decode(forged['claim']['base64']))
    omitted = claim['claims'][0]['durability']['inputs'].pop()
    del forged['inputs'][omitted['path']]
    claim_raw = json.dumps(claim).encode()
    forged['claim'].update(base64=c.encode(claim_raw), sha256=c.sha(claim_raw))
    preflight = json.loads(c.decode(forged['preflight']['base64']))
    preflight.update(draft_base64=c.encode(claim_raw), draft_sha256=c.sha(claim_raw), bytes=len(claim_raw), input_count=195)
    del preflight['input_modes'][omitted['path']]
    preflight_raw = json.dumps(preflight).encode()
    forged['preflight'].update(base64=c.encode(preflight_raw), sha256=c.sha(preflight_raw))
    return [dict(name='unescaped-original-view', path=VIEW, base64=c.encode(raw), reason='exact standard solidus transport'),
            dict(name='changed-decoded-destination', path=VIEW, base64=c.encode(altered), reason='exact standard solidus transport'),
            dict(name='coherent-original-input-omission', path=ORIGINAL,
                 base64=c.encode(gzip.compress(json.dumps(forged, sort_keys=True).encode(), mtime=0)), reason='whole original draft identity')]


def run(fixture):
    result = subprocess.run(COMMAND, cwd=fixture, capture_output=True)
    return dict(command=COMMAND, returncode=result.returncode, stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))


assert sys.argv[1:] in ([], ['--capture'])
if sys.argv[1:]:
    paths = [ORIGINAL, VIEW, HOME + 'review.py', c.HOME + 'common.py', c.HOME + 'render-final.json.gz']
    inputs = {path: c.read(path) for path in paths}
    candidates = variants(inputs)
    c.write_new(HOME + 'control-inputs.json.gz', dict(inputs=inputs, variants=candidates,
        producer_base64=c.encode(Path(__file__).read_bytes())), packed=True)
    with tempfile.TemporaryDirectory(prefix='knowledge-fields-transport-controls-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == ROOT.stat().st_dev
        for path, item in inputs.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        healthy = run(fixture)
        assert healthy['returncode'] == 0 and not c.decode(healthy['stderr_base64']), healthy
        rows = []
        for variant in candidates:
            target = fixture / variant['path']
            target.write_bytes(c.decode(variant['base64']))
            negative = run(fixture)
            assert negative['returncode'] != 0 and variant['reason'].encode() in c.decode(negative['stderr_base64']), negative
            assert target.read_bytes() == c.decode(variant['base64'])
            target.write_bytes(c.decode(inputs[variant['path']]['base64']))
            restored = run(fixture)
            assert restored == healthy
            assert all(c.sha((fixture / path).read_bytes()) == item['sha256'] and
                       (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in inputs.items())
            rows.append(dict(name=variant['name'], negative=negative, restored=restored, all_bytes_modes_restored=True))
        assert c.unchanged(inputs)
    c.write_new(HOME + 'controls.json', dict(result='PASS', baseline=healthy, rows=rows,
        producer_sha256=c.sha(Path(__file__).read_bytes()), inputs_sha256=c.sha((ROOT / (HOME + 'control-inputs.json.gz')).read_bytes())))
prepared = json.loads(gzip.decompress((ROOT / (HOME + 'control-inputs.json.gz')).read_bytes()))
report = json.loads((ROOT / (HOME + 'controls.json')).read_bytes())
assert c.decode(prepared['producer_base64']) == Path(__file__).read_bytes()
assert report['producer_sha256'] == c.sha(Path(__file__).read_bytes())
assert report['inputs_sha256'] == c.sha((ROOT / (HOME + 'control-inputs.json.gz')).read_bytes())
assert all(c.read(path) == item for path, item in prepared['inputs'].items())
assert variants(prepared['inputs']) == prepared['variants']
assert len(report['rows']) == 3 and report['baseline']['returncode'] == 0
for row, variant in zip(report['rows'], prepared['variants']):
    assert row['name'] == variant['name'] and row['negative']['returncode'] != 0
    assert variant['reason'].encode() in c.decode(row['negative']['stderr_base64'])
    assert row['restored'] == report['baseline'] and row['all_bytes_modes_restored']
print('Transport/draft controls PASS:3 actual REDs;exact byte/mode restorations')
