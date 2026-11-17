"""Retain the failed normal attempt and refresh the existing derived scope store."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.1.2'
log = Path('.linkedspec-data/perl-other-io-commit.log').read_bytes()
assert b'maintained reference is missing or unindexed' in log and b'doctrines: one or more doctrines FAILED' in log
(BASE / 'failed-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
with tarfile.open(BASE / 'landing-before.tar.gz', 'x:gz') as packed:
    for path in (BASE / 'repair_scope.py', BASE / 'REVIEW.md', Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'),
            Path('tools/update_reference_scope.py'), Path('tools/reference_scope.py'), Path('tools/check_reference_scope.py')):
        packed.add(path, arcname=str(path), recursive=False)
argv = ['bash', 'tools/run_python_project_data.sh', 'tools/update_reference_scope.py', '--owner', OWNER]
(BASE / 'scope-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('scope-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
(BASE / 'scope-exit.txt').write_text(str(child.returncode) + '\n')
assert child.returncode == 0 and not child.stderr, child.stderr.decode()
print(child.stdout.decode(), end='')
