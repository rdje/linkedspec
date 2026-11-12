"""Retain first current reader body, command and full separate channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'current'
OUT.mkdir()
paths = [BASE / name for name in ('check_current.py', 'capture_current.py', 'intake/input-identities.json')]
paths += [Path(name) for name in ('tools/project_data_run.sh', 'tools/project_data_env.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-reader.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'inputs-before-reader.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        row = rows[member.name]; body = archive.extractfile(member).read()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'check_current.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
for name, row in rows.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
(OUT / 'result.json').write_bytes(result.stdout)
print(result.stdout.decode(), end='')
