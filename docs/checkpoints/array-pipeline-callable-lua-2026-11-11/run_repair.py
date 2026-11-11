"""Retain writer inputs before actual rehearsal and application, plus all channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'repair-run'
OUT.mkdir()
paths = [BASE / 'repair.py', BASE / 'run_repair.py', BASE / 'before/puc/normal-exit.txt', BASE / 'before/luajit/normal-exit.txt', BASE / 'traceq/complete.txt',
    BASE / 'baseline.json', Path('lua/src/linkedspec/interpreter.lua'), Path('lua/test/run.lua'),
    Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-writer.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-writer.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == rows[member.name]['sha256']
(OUT / 'identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
for phase in ('rehearse', 'apply'):
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'repair.py'), '--' + phase]
    (OUT / (phase + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (phase + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (phase + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b''
for name, row in rows.items():
    if name not in ('lua/src/linkedspec/interpreter.lua', 'lua/test/run.lua'):
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
print('Actual rehearsal/application source inputs, commands, channels and exit0 retained')
