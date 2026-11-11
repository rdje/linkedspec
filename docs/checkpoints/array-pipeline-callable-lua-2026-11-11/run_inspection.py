"""Retain actual inspection inputs before invoking its readonly child."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'inspection'
OUT.mkdir()
paths = [BASE / 'inspect_intake.py', BASE / 'run_inspection.py', BASE / 'cases.json',
    Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json')]
paths += [BASE / 'intake' / host / name for host in ('puc', 'luajit') for name in
    ('normal-stdout.log.gz', 'normal-stderr.log.gz', 'normal-exit.txt', 'version-stdout.log.gz', 'version-stderr.log.gz')]

rows = {}
with tarfile.open(OUT / 'inputs-before-read.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-read.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        body = archive.extractfile(member).read()
        assert hashlib.sha256(body).hexdigest() == rows[member.name]['sha256']
        assert member.mode & 0o777 == rows[member.name]['mode']
(OUT / 'identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'inspect_intake.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
for name, row in rows.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
print('Actual independent installed-Lua intake inspection retained; inspect stdout.log.gz')
