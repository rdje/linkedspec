"""Retain an actual one-shot command, instrument inputs and separate channels."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
tag, *command = sys.argv[1:]
assert tag and all(c.isalnum() or c in '-_' for c in tag) and command
out = BASE / 'launches' / tag
out.mkdir(parents=True)
paths = [p for p in BASE.iterdir() if p.is_file()]
paths += [ROOT / p for p in ('tools/project_data_run.sh', 'tools/project_data_env.sh')]
paths += [ROOT / p for p in (
    'tools/run_python_project_data.sh', 'tools/run_lua_project_data.sh',
    'docs/checkpoints/REPO-HYGIENE.19/census.py',
    'docs/checkpoints/REPO-HYGIENE.18-census.py',
    'docs/checkpoints/artifact-review-2026-11-10/review.py',
    'docs/checkpoints/artifact-review-2026-11-11/census.py',
    'docs/checkpoints/artifact-review-2026-11-11/retire.py',
    'docs/checkpoints/artifact-review-2026-11-11/review.py',
    'docs/checkpoints/artifact-review-2026-11-11/run.py',
)]
rows = {}
with tarfile.open(out / 'inputs.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        name = path.relative_to(ROOT).as_posix()
        raw = path.read_bytes()
        rows[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=name, recursive=False)
with tarfile.open(out / 'inputs.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(out / 'identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(out / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment={}), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (out / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(out / 'exit.txt').write_text(str(result.returncode) + '\n')
print(json.dumps(dict(stage=tag, actual_exit=result.returncode, stdout_bytes=len(result.stdout), stderr_bytes=len(result.stderr))))
sys.exit(result.returncode)
