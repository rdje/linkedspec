"""Retain the asserted writer and its actual first-use source inputs/channels."""
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
owner = Path('lua/src/linkedspec/interpreter.lua')
paths = [Path(__file__).relative_to(ROOT), BASE / 'repair.py', BASE / 'owner-before.lua.gz', BASE / 'runner-before.lua.gz', owner, Path('lua/test/run.lua'),
         Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh'), Path('tools/run_python_project_data.sh')]
records = {}
with tarfile.open(OUT / 'inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'inputs.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'repair.py')]
(OUT / 'writer-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / ('writer-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'writer-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
(OUT / 'owner-after.lua.gz').write_bytes(gzip.compress(owner.read_bytes(), mtime=0))
print('Actual asserted writer0 with all first-use inputs and complete channels retained')
