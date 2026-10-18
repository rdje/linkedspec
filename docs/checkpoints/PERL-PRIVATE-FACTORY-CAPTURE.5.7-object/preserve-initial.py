"""Freeze the uncommitted initial publication without inventing a Git revision."""
import base64
import hashlib
import io
import json
import subprocess
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
raw = (ROOT / CLAIM).read_bytes()
record = json.loads(raw)
assert len(raw) == 127929 and len(record['claims']) == 1
bindings = record['claims'][0]['durability']['inputs']
assert len(bindings) == 546 and record['claims'][0]['durability']['mode'] == 'live'
files = {}
for item in bindings:
    path = item['path']
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    payload = source.read_bytes()
    assert sha(payload) == item['sha256']
    files[path] = dict(sha256=sha(payload), size=len(payload), mode=source.stat().st_mode & 0o7777)
command = ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/publish.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = dict(command=command, returncode=process.returncode,
    stdout_base64=encode(process.stdout), stderr_base64=encode(process.stderr))
with (ROOT / (PREFIX + 'baseline.json')).open('x') as output:
    output.write(json.dumps(baseline, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Mixed-default publication PASS: 546 live inputs; 127929 bytes\n'
with (ROOT / (PREFIX + 'initial-claim.json')).open('xb') as output:
    output.write(raw)
archive = ROOT / (PREFIX + 'initial-inputs.tar.gz')
with tarfile.open(archive, 'x:gz', format=tarfile.PAX_FORMAT) as stream:
    for path, item in sorted(files.items()):
        source = ROOT / path
        payload = source.read_bytes()
        assert sha(payload) == item['sha256'] and source.stat().st_mode & 0o7777 == item['mode']
        member = tarfile.TarInfo(path)
        member.size, member.mode, member.mtime = len(payload), item['mode'], 0
        stream.addfile(member, io.BytesIO(payload))
    member = tarfile.TarInfo(CLAIM)
    member.size, member.mode, member.mtime = len(raw), (ROOT / CLAIM).stat().st_mode & 0o7777, 0
    stream.addfile(member, io.BytesIO(raw))
with tarfile.open(archive) as stream:
    members = {item.name: item for item in stream.getmembers()}
    assert set(members) == set(files) | {CLAIM}
    for path, item in files.items():
        assert sha(stream.extractfile(members[path]).read()) == item['sha256']
        assert members[path].mode == item['mode']
    assert stream.extractfile(members[CLAIM]).read() == raw
assert all(sha((ROOT / p).read_bytes()) == x['sha256'] for p, x in files.items())
result = dict(result='PASS', kind='uncommitted-logical-draft', git_revision=None,
    repository_head=BASE, producer_sha256=sha(Path(__file__).read_bytes()),
    claim_path=CLAIM, claim_sha256=sha(raw), claim_bytes=len(raw), inputs=files,
    archive_sha256=sha(archive.read_bytes()), baseline=baseline,
    scope='Complete original546-input/127929-byte draft and actual readonly baseline are retained before any bound repair. Every byte and actual mode is recoverable, including the exact original canonical claim file. The draft is not assigned a historical Git revision and is not final admission for package-object targets. The cancelled normal commit never landed. Original narrow data and executed producers remain unchanged; final corrected evidence has separate identities.')
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
print('Initial logical publication preserved:546 inputs/full127929 bytes; actual baseline; complete byte/mode archive; no fake revision')
