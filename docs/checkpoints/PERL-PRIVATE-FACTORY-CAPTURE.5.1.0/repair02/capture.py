"""Freeze first full review/publication source and reproduce its self-census RED."""
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
TARGET = ROOT / (PREFIX + 'repair02/capture.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists()
first = json.loads((ROOT / (PREFIX + 'review-final.json')).read_bytes())
paths = set(first['inputs']) | {p.relative_to(ROOT).as_posix() for p in (ROOT / PREFIX).iterdir() if p.is_file()}
paths.add(PREFIX + 'repair02/capture.py')
files = {p: (ROOT / p).read_bytes() for p in sorted(paths)}
modes = {p: stat.S_IMODE((ROOT / p).stat().st_mode) for p in paths}
for p, item in first['inputs'].items():
    assert sha(files[p]) == item['sha256'] and modes[p] == item['mode']
census = {p.relative_to(ROOT).as_posix() for p in (ROOT / PREFIX).iterdir() if p.is_file()
          and p.name not in ('review.json', 'review.json', 'compat.json')
          and not p.name.startswith(('evidence', 'publish'))}
assert census - set(first['inputs']) == {PREFIX + 'review-final.json'}
cap_path = ROOT / (PREFIX + 'repair02/inputs.json.gz')
capsule = {p: {'sha256': sha(value), 'mode': modes[p],
               'bytes_base64': base64.b64encode(value).decode()} for p, value in files.items()}
with cap_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))
with tempfile.TemporaryDirectory(prefix='expansion-self-census-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == ROOT.stat().st_dev
    for p, value in files.items():
        target = root / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(modes[p])
    command = ['python3', PREFIX + 'review-final.py']
    environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(root))
    result = subprocess.run(command, cwd=root, env=environment, capture_output=True)
    unchanged = all((root / p).read_bytes() == value and
                    stat.S_IMODE((root / p).stat().st_mode) == modes[p] for p, value in files.items())
report = {'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': {
    p: {'sha256': sha(value), 'mode': modes[p]} for p, value in files.items()},
    'capsule_sha256': sha(cap_path.read_bytes()), 'command': command, 'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(),
    'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
    'self_census_added': sorted(census - set(first['inputs'])),
    'first_publication_session': 97918, 'first_publication_returncode': 1,
    'scope': 'Complete first full review and failed publisher source before repair. Actual fresh supplied '
             'readonly replay rejects exact independent full review: the only added census member is '
             'its own review-final.json. Every originally reviewed input is unchanged. Original native, '
             'paired, source-fault, consumer, Knowledge, corrected book, seven artifact controls and '
             'completed supplemental Phase0 records are preserved without refresh.'}
with TARGET.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert result.returncode == 1 and b'AssertionError: exact independent full review' in result.stderr and unchanged
assert all((ROOT / p).read_bytes() == value for p, value in files.items())
print('First full review/publication custody PASS:', len(files), 'inputs; actual supplied self-census RED retained')
