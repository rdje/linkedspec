"""Retain actual Dart writer/formatter inputs and complete first-use channels."""
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
owner = Path('dart/lib/src/runtime/interpreter.dart')
normal = Path('dart/test/array_pipeline_result_guard_composition_test.dart')
probe = Path('dart/tool/probe_array_pipeline_results.dart')
paths = [Path(__file__).relative_to(ROOT), BASE / 'repair.py', BASE / 'owner-before.dart.gz', owner, normal, probe,
         Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh'), Path('tools/run_python_project_data.sh'), Path('tools/run_dart_project_data.sh')]
records = {}
with tarfile.open(OUT / 'inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'inputs.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
for tag, command in [('writer', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'repair.py')]),
                     ('formatter', ['bash', 'tools/run_dart_project_data.sh', 'format', str(owner), str(normal), str(probe)])]:
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0
for tag, path in [('owner-after.dart.gz', owner), ('normal-after.dart.gz', normal), ('probe-after.dart.gz', probe)]:
    (OUT / tag).write_bytes(gzip.compress(path.read_bytes(), mtime=0))
print('Actual asserted writer/scoped formatter exit0; all input bytes and complete channels retained')
