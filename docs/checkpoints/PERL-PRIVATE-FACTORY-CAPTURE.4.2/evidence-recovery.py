"""Replay the unchanged artifact reader with its exact captured pending overlay."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
COMPAT = PREFIX + 'compat.json'
OVERLAY = PREFIX + 'evidence-compat-inflight.json'
TARGET = ROOT / (PREFIX + 'evidence-recovery.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
encode = lambda raw: base64.b64encode(raw).decode()
decode = lambda value: base64.b64decode(value, validate=True)
original_raw = (ROOT / (PREFIX + 'evidence.json')).read_bytes()
original = json.loads(original_raw)
assert original['result'] == 'PASS'
assert original['producer_sha256'] == sha((ROOT / (PREFIX + 'evidence.py')).read_bytes())
overlay = (ROOT / OVERLAY).read_bytes()
assert sha(overlay) == original['inputs'][COMPAT]['sha256'], 'exact original pending input bytes'
assert json.loads(overlay)['result'] == 'pending' and len(json.loads(overlay)['rows']) == 3
data_raw = (ROOT / (PREFIX + 'evidence-data.json.gz')).read_bytes()
assert sha(data_raw) == original['data_sha256']
rows = json.loads(gzip.decompress(data_raw))
assert len(rows) == 6 and original['rows'] == [{k: r[k] for k in ('name', 'reason')} for r in rows]
for row in rows:
    assert row['denial']['returncode'] != 0 and row['reason'].encode() in decode(row['denial']['stderr_base64'])
    assert row['restoration']['returncode'] == 0 and not decode(row['restoration']['stderr_base64'])
    assert row['mutations']
files = {}
for path, item in original['inputs'].items():
    raw = overlay if path == COMPAT else (ROOT / path).read_bytes()
    assert sha(raw) == item['sha256'], ('actual original artifact reader input', path)
    assert stat.S_IMODE((ROOT / path).stat().st_mode) == item['mode']
    files[path] = raw
sources = {PREFIX + name: sha((ROOT / (PREFIX + name)).read_bytes()) for name in
           ['evidence.py', 'evidence.json', 'evidence-data.json.gz', 'evidence-compat-inflight.json', 'evidence-recovery.py']}

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot supplied reader recovery'
    command = ['python3', PREFIX + 'evidence.py']

    def execute(directory):
        process = subprocess.run(command, cwd=directory, capture_output=True)
        return {'command': command, 'returncode': process.returncode,
                'stdout_base64': encode(process.stdout), 'stderr_base64': encode(process.stderr)}

    refused_live = execute(ROOT)
    assert refused_live['returncode'] != 0 and b'AssertionError' in decode(refused_live['stderr_base64'])
    observations = []
    with tempfile.TemporaryDirectory(prefix='flow-kind-artifact-reader-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in files.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(original['inputs'][path]['mode'])
        (supplied / (PREFIX + 'evidence.json')).write_bytes(original_raw)
        (supplied / (PREFIX + 'evidence-data.json.gz')).write_bytes(data_raw)
        for name in ['original', 'changed-pending', 'restored-pending', 'missing-fixture', 'restored-fixture']:
            if name == 'changed-pending':
                (supplied / COMPAT).write_bytes(b'X' + overlay[1:])
            elif name == 'restored-pending':
                (supplied / COMPAT).write_bytes(overlay)
            elif name == 'missing-fixture':
                (supplied / 't/actionir_flow_kind_capture.t').unlink()
            elif name == 'restored-fixture':
                fixture = 't/actionir_flow_kind_capture.t'
                (supplied / fixture).write_bytes(files[fixture])
                (supplied / fixture).chmod(original['inputs'][fixture]['mode'])
            row = {'name': name, **execute(supplied)}
            observations.append(row)
            if name == 'changed-pending':
                assert row['returncode'] != 0 and b'AssertionError' in decode(row['stderr_base64'])
            elif name == 'missing-fixture':
                assert row['returncode'] != 0 and b'FileNotFoundError' in decode(row['stderr_base64'])
                assert b't/actionir_flow_kind_capture.t' in decode(row['stderr_base64'])
            else:
                assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        for path, raw in files.items():
            assert (supplied / path).read_bytes() == raw
            assert stat.S_IMODE((supplied / path).stat().st_mode) == original['inputs'][path]['mode']
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
              'sources': sources, 'original_inputs': len(files), 'refused_live': refused_live,
              'rows': observations,
              'scope': 'Unchanged original artifact reader and all original input bytes/modes in a complete supplied root, using the exact captured pending compatibility overlay. The original preflight semantic controls never read that extra inventory file; their complete six observations stay immutable. Final compatibility is separately verified by the current full review. Two actual recovery-integrity controls reject a changed overlay and missing real fixture, then restore. No Git repo is created and no runtime observation is refreshed.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['sources'] == sources and report['original_inputs'] == len(files)
    assert report['refused_live']['returncode'] != 0
    assert [row['name'] for row in report['rows']] == ['original', 'changed-pending', 'restored-pending', 'missing-fixture', 'restored-fixture']
    assert [row['returncode'] == 0 for row in report['rows']] == [True, False, True, False, True]
print('Optional FlowExpr artifact recovery PASS: six original semantic controls; exact supplied reader replay/two integrity controls')
