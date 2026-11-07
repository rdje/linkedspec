"""Capture the actual unchanged portability oracle before/after evidence packaging."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
phase = sys.argv[1]
assert phase in ('before', 'after')
OUT = BASE / ('process-storage-' + phase)
OUT.mkdir()
logical = BASE / 'commit-correction/processes-before-termination.json'
paths = [Path('scripts/check_repo_root_path_portability.sh'),
         Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh'),
         Path('tools/run_python_project_data.sh'), BASE / 'record.py',
         BASE / 'capture_process_storage.py', BASE / 'package_process_storage.py',
         BASE / 'review_process_storage.py']
paths += [logical] if phase == 'before' else [Path(str(logical) + '.gz'), BASE / 'commit-correction/process-storage.json']
rows = {}
with tarfile.open(OUT / 'inputs-before-run.tar.gz', 'w:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink()
        body = path.read_bytes()
        rows[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
command = ['bash', 'scripts/check_repo_root_path_portability.sh']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == (1 if phase == 'before' else 0)
if phase == 'before':
    assert b'processes-before-termination.json' in result.stderr and b'current checkout identity' in result.stderr
for name, row in rows.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
print('actual process-storage ' + phase + ': portability exit' + str(result.returncode) + '; first inputs/channels retained')
