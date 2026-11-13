"""Retain direct image/inverse producers before each focused command."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
tag, *command = sys.argv[1:]
assert tag and all(c.isalnum() or c in '-_' for c in tag) and command
OUT = BASE / 'proofs' / tag
OUT.mkdir(parents=True)
paths = [path for path in BASE.iterdir() if path.is_file()]
paths += [Path(name) for name in (
    'tools/historical_objective_images.py', 'tools/test_historical_objective_images.py',
    'tests/language-readiness/verify_objectives.py', 'tools/run_ci_local.sh',
    'tools/host_ram_usage.sh', 'tools/ram_guard.sh', 'tools/test_ram_guard.py',
    'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
    'doctrine/project_data_storage/python_entrypoints.json', 'doctrine/project_data_storage/python_temporary_owners.json',
    'tests/language-readiness/current-source-images.json.gz',
    'tests/language-readiness/current-source-successors.json.gz',
    'tests/language-readiness/additional-source-images.json.gz',
    'tests/language-readiness/current-source-successors-2026-11-12.json.gz',
    'tests/language-readiness/ram-preflight-ci-evolution.json.gz') if Path(name).exists()]
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == rows[member.name]['sha256']
        assert member.mode & 0o777 == rows[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment={}), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), capture_output=True)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
print(json.dumps(dict(stage=tag, actual_exit=result.returncode, stdout_bytes=len(result.stdout), stderr_bytes=len(result.stderr))))
sys.exit(result.returncode)
