"""Record a new proof stage's sources before use and its complete channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 3 and sys.argv[1].replace('-', '').isalnum()
target = Path(sys.argv[2])
assert target.parent == BASE and target.suffix == '.py'
OUT = BASE / 'proofs' / sys.argv[1]
OUT.mkdir(parents=True)
paths = sorted(BASE.glob('*.py')) + [Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
identities = {}
with tarfile.open(OUT / 'sources-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'sources-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        body = archive.extractfile(member).read()
        assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode) == identities[member.name]
(OUT / 'source-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(target)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
sys.stdout.buffer.write(result.stdout)
sys.stderr.buffer.write(result.stderr)
raise SystemExit(result.returncode)
