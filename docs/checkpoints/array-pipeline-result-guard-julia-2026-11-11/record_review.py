"""Seal actual readonly instruments and input identities before first use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'readonly-review'
assert not (BASE / 'control-owner').exists()
for phase in ('intake', 'before', 'after', 'direct', 'private-old', 'private-fixed'):
    assert (BASE / phase / 'custody.json').is_file()
    assert not any((BASE / phase / name).exists() for name in ('emitted', 'parsed', 'prior-transform'))
OUT.mkdir()
identities = {}
for path in sorted(BASE.rglob('*')):
    if OUT in path.parents or not path.is_file():
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'instruments-before-use.tar.gz', 'x:gz') as archive:
    for name in ('review.py', 'check_current.py', 'record_review.py'):
        path = BASE / name
        archive.add(path, arcname=str(path), recursive=False)
for tag, name in (('historical', 'review.py'), ('current', 'check_current.py')):
    command = ['bash', 'tools/run_python_project_data.sh', str(BASE / name)]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and not result.stderr, f'{tag}: original readonly failure retained'
for name, row in identities.items():
    path = Path(name)
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
print('First historical/current readonly checks actual0/empty stderr; actual producers/inputs remained frozen')
