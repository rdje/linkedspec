"""Replay the preserved uncommitted publication from complete supplied bytes."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import tarfile
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'replay.json')
assert not target.exists()
preservation_raw = (ROOT / (PREFIX + 'preservation.json')).read_bytes()
preservation = json.loads(preservation_raw)
archive = ROOT / (PREFIX + 'initial-inputs.tar.gz')
assert sha(archive.read_bytes()) == preservation['archive_sha256']
files, modes = {}, {}
with tarfile.open(archive) as stream:
    for item in stream.getmembers():
        assert item.isfile() and not item.name.startswith('/') and '..' not in Path(item.name).parts
        files[item.name] = stream.extractfile(item).read()
        modes[item.name] = item.mode
assert len(files) == 547 and files[preservation['claim_path']] == (ROOT / (PREFIX + 'initial-claim.json')).read_bytes()
for path, item in preservation['inputs'].items():
    assert sha(files[path]) == item['sha256'] and modes[path] == item['mode']
# The old readonly reviewer scans the full Markdown population. Its complete
# current scan bytes are already an input of the preserved publication.
knowledge_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/knowledge-inputs.json.gz'
knowledge = json.loads(gzip.decompress(files[knowledge_path]))
for path, item in knowledge['current'].items():
    value = decode(item['bytes_base64'])
    assert sha(value) == item['sha256']
    if path in files:
        assert files[path] == value and modes[path] == item['mode']
    else:
        files[path], modes[path] = value, item['mode']
metadata = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip()
environment = dict(os.environ, GIT_DIR=metadata, GIT_OPTIONAL_LOCKS='0',
    PYTHONDONTWRITEBYTECODE='1', PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/publish.py']
with tempfile.TemporaryDirectory(prefix='initial-publication-replay-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, value in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(value)
        destination.chmod(modes[path])
    environment['GIT_WORK_TREE'] = str(supplied)
    result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
    actual_modes = {p: (supplied / p).stat().st_mode & 0o7777 for p in actual}
report = dict(result='PASS' if result.returncode == 0 else 'FAIL',
    producer_sha256=sha(Path(__file__).read_bytes()), preservation_sha256=sha(preservation_raw),
    archive_sha256=sha(archive.read_bytes()), supplied_count=len(files),
    inputs={p: dict(sha256=sha(v), mode=modes[p]) for p, v in sorted(files.items())},
    command=command, returncode=result.returncode,
    stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr),
    unchanged=actual == {p: sha(v) for p, v in files.items()} and actual_modes == modes,
    scope='Actual complete initial readonly publisher execution from the captured546 live inputs, exact original canonical claim, and full original Markdown scan bytes. All supplied byte/mode identities are guarded. Current repository Git objects/index are an explicitly read-only metadata dependency with runtime-derived work-tree override; no metadata is copied or mutated. This is the preserved uncommitted logical draft, not a fictional historical Git revision or a canonical whole-project gate replay. It does not admit package-object behavior.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert report['unchanged'] and result.returncode == 0 and not result.stderr
assert result.stdout == b'Mixed-default publication PASS: 546 live inputs; 127929 bytes\n'
print('Initial full publication replay PASS:', len(files), 'supplied files;546 original bindings/full127929 bytes; exact input preservation')
