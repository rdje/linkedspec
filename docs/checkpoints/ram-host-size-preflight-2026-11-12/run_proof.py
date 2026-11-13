"""Freeze direct producer/input bodies before a named proof command."""
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
out = BASE / 'proofs' / tag
out.mkdir(parents=True)
paths = list(path for path in BASE.iterdir() if path.is_file())
paths += [Path(name) for name in (
    'tools/ram_guard.sh', 'tools/host_ram_usage.sh', 'tools/run_ci_local.sh', 'tools/test_ram_guard.py',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'doctrine/project_data_storage/python_entrypoints.json',
    'doctrine/project_data_storage/python_temporary_owners.json',
    'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json',
    'docs/knowledge/restricted-macos-ram-host-size-fallback.md',
    'docs/knowledge/canonical-ci-ram-fallback-prerequisite.md', 'docs/knowledge/shared-host-ram-budget.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md')]
identities = {}
with tarfile.open(out / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        identities[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(out / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        body = archive.extractfile(member).read()
        assert hashlib.sha256(body).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(out / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
(out / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment={}), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), capture_output=True)
for channel in ('stdout', 'stderr'):
    (out / (channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(out / 'exit.txt').write_text(str(result.returncode) + '\n')
print(json.dumps(dict(stage=tag, actual_exit=result.returncode, stdout_bytes=len(result.stdout), stderr_bytes=len(result.stderr))))
sys.exit(result.returncode)
