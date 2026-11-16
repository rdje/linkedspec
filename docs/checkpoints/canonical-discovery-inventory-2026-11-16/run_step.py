"""Acquire an additional bounded child phase without changing earlier launchers."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
tag, script = sys.argv[1:]
assert re.fullmatch(r'[a-z][a-z0-9_-]*', tag)
assert re.fullmatch(r'[a-z_]+\.py', script) and (BASE / script).is_file()
OUT = BASE / 'steps' / tag
OUT.mkdir(parents=True)
paths = sorted(BASE.glob('*.py')) + [Path('tools/project_data_run.sh'),
    Path('tools/project_data_env.sh'), Path('tools/run_python_project_data.sh')]
identities = {}
with tarfile.open(OUT / 'sources-before-child.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
        identities[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'sources-before-child.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'source-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / script)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'complete child channels retained:' + tag
print(result.stdout.decode(), end='')
