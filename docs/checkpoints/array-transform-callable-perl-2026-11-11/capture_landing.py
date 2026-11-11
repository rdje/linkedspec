"""Retain the actual staged-owner rejection and its separately qualified result."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
tag = sys.argv[1]
assert tag in ('rejected', 'qualified')
OUT = BASE / ('landing-' + tag)
OUT.mkdir()
for name in (__file__, 'tools/check_task_verification_fields.pl'):
    path = Path(name).resolve()
    relative = path.relative_to(ROOT)
    (OUT / (relative.name + '.gz')).write_bytes(gzip.compress(path.read_bytes(), mtime=0))
patch = subprocess.check_output(['git', 'diff', '--cached', '--full-index', '--', 'docs/tasks/*.md'])
(OUT / 'staged-task.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
command = ['perl', 'tools/check_task_verification_fields.pl', '--owner']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
if tag == 'rejected':
    assert result.returncode != 0 and b'found 2 [' in result.stderr
    log = ROOT / '.linkedspec-data/array-transform-callable-perl-intake-commit.log'
    (OUT / 'commit-combined.log.gz').write_bytes(gzip.compress(log.read_bytes(), mtime=0))
    (OUT / 'commit-observed-exit.txt').write_text('1\n')
else:
    assert result.returncode == 0 and not result.stderr
    assert result.stdout.strip() == b'TYPE-REFERENCE-BOOK.1.2.23.3.78.6.1.0'
print(tag, 'actual owner-check exit', result.returncode)
