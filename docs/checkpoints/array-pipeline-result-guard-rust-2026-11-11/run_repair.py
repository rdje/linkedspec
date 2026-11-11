"""Capture the actual source writer and formatter before their one-shot use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OUT = BASE / 'repair-run'
OUT.mkdir()
owner = Path('rust/linkedspec-runtime/src/engine.rs')
normal = Path('rust/linkedspec-runtime/tests/array_pipeline_result_guard_composition.rs')
paths = [Path(__file__).relative_to(Path.cwd()), BASE / 'repair.py', BASE / 'owner-before.rs.gz', owner, normal,
         Path('tools/project_data_run.sh'), Path('tools/run_python_project_data.sh'), Path('tools/project_data_env.sh')]
files = {}
with tarfile.open(OUT / 'inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        raw = path.read_bytes()
        files[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'inputs.json').write_text(json.dumps(files, indent=2, sort_keys=True) + '\n')
for tag, command in [('writer', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'repair.py')]),
                     ('formatter', ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', str(owner), str(normal)])]:
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0
(OUT / 'owner-after.rs.gz').write_bytes(gzip.compress(owner.read_bytes(), mtime=0))
(OUT / 'normal-after.rs.gz').write_bytes(gzip.compress(normal.read_bytes(), mtime=0))
print('Actual asserted writer and scoped formatter both exit0; full first-use input/output custody retained')
