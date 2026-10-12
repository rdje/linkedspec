"""Replay the unchanged second publication from its complete supplied byte capsule."""
import base64
import gzip
import hashlib
import io
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
BASE = '328b11c5ed1d5ffbc870f6785448e3a8249fe882'
TARGET = ROOT / (PREFIX + 'replay.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
preserved = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
packed = (ROOT / (PREFIX + 'original-inputs.json.gz')).read_bytes()
assert sha(packed) == preserved['capsule_sha256']
original = {p: base64.b64decode(v, validate=True) for p, v in json.loads(gzip.decompress(packed)).items()}
claim = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
assert sha(claim) == preserved['claim_sha256'] and len(claim) == 79329
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
assert len(original) == len(bindings) == 337
assert all(sha(original[r['path']]) == r['sha256'] for r in bindings)
population = json.loads(gzip.decompress(original[OLD + 'population.json.gz']))
files = {p: base64.b64decode(v, validate=True) for p, v in population.items()}
assert len(files) == 1485
prior = json.loads(original[OLD + 'preservation.json'])
paths = sorted(row['path'] for row in prior['census'])
process = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
    input=''.join(BASE + ':' + p + '\n' for p in paths).encode(), capture_output=True)
assert process.returncode == 0 and not process.stderr
stream = io.BytesIO(process.stdout)
for path in paths:
    header = stream.readline().split()
    assert len(header) == 3 and header[1] == b'blob'
    files[path] = stream.read(int(header[2]))
    assert stream.read(1) == b'\n'
assert not stream.read()
files.update(original)
files[CLAIM] = claim
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py']
env = dict(os.environ, GIT_DIR=str(ROOT / '.git'), PYTHONDONTWRITEBYTECODE='1')

def invoke(supplied):
    result = subprocess.run(command, cwd=supplied, env=dict(env, GIT_WORK_TREE=str(supplied)), capture_output=True)
    return {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}

def run():
    rows = []
    with tempfile.TemporaryDirectory(prefix='knowledge-candidate-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for p, raw in files.items():
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(preserved['modes'].get(p, 0o644))
        good = invoke(supplied)
        rows.append({'name': 'unchanged-second-publication', **good})
        assert good['returncode'] == 0 and not base64.b64decode(good['stderr_base64']), good
        assert base64.b64decode(good['stdout_base64']) == b'Final Knowledge publication PASS: 337 live inputs; 79329 bytes\n'
        target = supplied / CLAIM
        target.write_bytes(claim + b' ')
        bad = invoke(supplied)
        rows.append({'name': 'changed-full-publication', **bad})
        assert bad['returncode'] != 0 and b'AssertionError' in base64.b64decode(bad['stderr_base64']), bad
        target.write_bytes(claim)
        fixture = supplied / 't/knowledge_map_header_lists.t'
        saved = fixture.read_bytes()
        fixture.unlink()
        bad = invoke(supplied)
        rows.append({'name': 'missing-bound-fixture', **bad})
        assert bad['returncode'] != 0 and b'AssertionError' in base64.b64decode(bad['stderr_base64']), bad
        fixture.write_bytes(saved)
        fixture.chmod(preserved['modes']['t/knowledge_map_header_lists.t'])
        restored = invoke(supplied)
        rows.append({'name': 'exact-restoration', **restored})
        assert restored == good
        assert all((supplied / p).read_bytes() == raw for p, raw in files.items())
        assert all((supplied / p).stat().st_mode & 0o777 == preserved['modes'].get(p, 0o644) for p in files)
    return rows

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot replay capture'
    rows = run()
    TARGET.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
        'capsule_sha256': sha(packed), 'claim_sha256': sha(claim), 'claim_bytes': len(claim),
        'bindings': len(bindings), 'supplied_inputs': {p: sha(v) for p, v in sorted(files.items())},
        'command': command, 'rows': rows,
        'scope': 'Unchanged first readonly publisher and all337 original input bytes, full79329 publication, complete original1485 Markdown scan and fixed historical claim namespace are supplied on the repository volume. Git history reads use this repository only. Native observations are not rerun or refreshed; two actual isolated corruptions reject and exact restoration passes.'}, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['capsule_sha256'] == sha(packed) and report['claim_sha256'] == sha(claim)
    assert report['supplied_inputs'] == {p: sha(v) for p, v in sorted(files.items())}
    assert [r['returncode'] == 0 for r in report['rows']] == [True, False, False, True]
print('Frozen second publication replay PASS: 337 bindings/full79329; two denials; exact restoration')
