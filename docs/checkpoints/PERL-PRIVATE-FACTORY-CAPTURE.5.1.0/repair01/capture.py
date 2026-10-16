"""Preserve the first book/evidence candidate and replay its unchanged preflight."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
TARGET = ROOT / (PREFIX + 'repair01/capture.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists(), 'one-shot original candidate preservation'
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert evidence['result'] == 'PASS'
paths = set(evidence['inputs']) | {PREFIX + name for name in
    ('evidence.json', 'evidence-data.json.gz', 'publish.py', 'repair01/capture.py')}
files = {path: (ROOT / path).read_bytes() for path in sorted(paths)}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
for path, item in evidence['inputs'].items():
    assert sha(files[path]) == item['sha256'] and modes[path] == item['mode']
assert b'Undefined, empty or whitespace input' in files['docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']
capsule = {path: {'sha256': sha(value), 'mode': modes[path],
                 'bytes_base64': base64.b64encode(value).decode()} for path, value in files.items()}
cap_path = ROOT / (PREFIX + 'repair01/inputs.json.gz')
with cap_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))
with tempfile.TemporaryDirectory(prefix='expansion-first-book-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, value in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(modes[path])
    command = ['python3', PREFIX + 'review.py', '--preflight']
    environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    unchanged = all((supplied / path).read_bytes() == value and
                    stat.S_IMODE((supplied / path).stat().st_mode) == modes[path] for path, value in files.items())
report = {'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': {
    path: {'sha256': sha(value), 'mode': modes[path]} for path, value in files.items()},
    'capsule_sha256': sha(cap_path.read_bytes()), 'command': command,
    'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode(), 'unchanged': unchanged,
    'scope': 'Whole original first book/evidence candidate before wording correction. Its unchanged preflight '
             'still passes on supplied original bytes; it did not assert whitespace semantics. The native '
             'identity-trim row returns a one-element whitespace array. This is a documentation correction, '
             'with no changed runtime, instrument, native observation, paired fixture or source fault.'}
with TARGET.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr and unchanged
assert all((ROOT / path).read_bytes() == value for path, value in files.items())
print('Original expansion book candidate preserved; unchanged full supplied preflight PASS:', len(files), 'inputs')
