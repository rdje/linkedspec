"""Retain project sources before a child phase and acquire its complete channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PHASES = {'plan-archive': 'qualify_plan.py', 'capture': 'capture.py',
          'review-first': 'review.py', 'controls': 'controls.py', 'review-final': 'review.py'}
phase = sys.argv[1]
assert phase in PHASES
OUT = BASE / 'launches' / phase
OUT.mkdir(parents=True)
paths = sorted(BASE.glob('*.py')) + [Path('tools/project_data_run.sh'),
    Path('tools/project_data_env.sh'), Path('tools/run_python_project_data.sh')]
identities = {}
with tarfile.open(OUT / 'sources-before-child.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        identities[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'sources-before-child.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'source-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / PHASES[phase])]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'phase failed; complete channels retained:' + phase
print(result.stdout.decode(), end='')
