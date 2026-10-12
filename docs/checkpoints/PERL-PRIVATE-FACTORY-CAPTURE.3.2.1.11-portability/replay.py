"""Replay every original third-publication byte through ten explicit overlays."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
TARGET = ROOT / (PREFIX + 'replay.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
preserved = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
claim = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
assert len(claim) == 44317 and sha(claim) == preserved['claim_sha256']
packed = (ROOT / (PREFIX + 'original-overlays.json.gz')).read_bytes()
assert sha(packed) == preserved['capsule_sha256']
overlays = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(packed)).items()}
assert len(overlays) == 10
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
original = {r['path']: overlays[r['path']] if r['path'] in overlays else (ROOT / r['path']).read_bytes() for r in bindings}
assert len(original) == 177 and all(sha(original[r['path']]) == r['sha256'] for r in bindings)
previous = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(original[OLD + 'original-inputs.json.gz'])).items()}
population = json.loads(gzip.decompress(previous['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-population.json.gz']))
files = {p: base64.b64decode(raw, validate=True) for p, raw in population.items()}
assert len(files) == 1485
files.update(original)
files[CLAIM] = claim
command = ['python3', OLD + 'publish.py']
environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), PYTHONDONTWRITEBYTECODE='1')
def invoke(supplied):
    result = subprocess.run(command, cwd=supplied, env=dict(environment, GIT_WORK_TREE=str(supplied)), capture_output=True)
    return {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode()}

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot supplied replay'
    with tempfile.TemporaryDirectory(prefix='third-publication-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for p, raw in files.items():
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(preserved['modes'].get(p, 0o644))
        good = invoke(supplied)
        assert good['returncode'] == 0 and not base64.b64decode(good['stderr_base64']), good
        assert base64.b64decode(good['stdout_base64']) == b'Current Knowledge/documentation publication PASS: 177 live inputs; 44317 bytes\n'
        rows = [{'name': 'unchanged-third-publication', **good}]
        target = supplied / CLAIM
        target.write_bytes(claim + b' ')
        bad = invoke(supplied)
        assert bad['returncode'] != 0 and b'AssertionError' in base64.b64decode(bad['stderr_base64'])
        rows.append({'name': 'changed-full-publication', **bad})
        target.write_bytes(claim)
        fixture = supplied / 't/knowledge_map_header_lists.t'
        raw = fixture.read_bytes()
        fixture.unlink()
        bad = invoke(supplied)
        assert bad['returncode'] != 0 and b'FileNotFoundError' in base64.b64decode(bad['stderr_base64'])
        rows.append({'name': 'missing-bound-fixture', **bad})
        fixture.write_bytes(raw)
        fixture.chmod(preserved['modes']['t/knowledge_map_header_lists.t'])
        restored = invoke(supplied)
        assert restored == good
        rows.append({'name': 'exact-restoration', **restored})
        assert all((supplied / p).read_bytes() == raw for p, raw in files.items())
        assert all((supplied / p).stat().st_mode & 0o777 == preserved['modes'].get(p, 0o644) for p in files)
    TARGET.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
        'claim_sha256': sha(claim), 'bindings': 177, 'claim_bytes': 44317, 'overlays': 10,
        'supplied_inputs': {p: sha(raw) for p, raw in sorted(files.items())}, 'command': command, 'rows': rows,
        'scope': 'Actual unchanged third readonly publisher receives all177 exact original binding bytes/full44317 publication and complete1485 Markdown population. Ten complete original overlays replace only mutable current files; other originals remain hash-gated retained files. Two actual isolated corruptions reject, then exact restoration passes. Native observations are not rerun or refreshed; this project supplies only its own read-only Git history.'}, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['claim_sha256'] == sha(claim) and report['supplied_inputs'] == {p: sha(raw) for p, raw in sorted(files.items())}
    assert [r['returncode'] == 0 for r in report['rows']] == [True, False, False, True]
print('Third publication supplied replay PASS:177 complete bindings/full44317; two denials; exact restoration')
