"""Freeze the minimal reader repair and original failure before independent use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
paths = [BASE / name for name in ('review_qualified2.py', 'run_review_qualified2.py', 'review_qualified.py', 'review_ordinary_qualified.py', 'sealed-identities.json')]
paths += [BASE / 'launches/review-qualified' / name for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
paths += [ROOT / name for name in ('tools/project_data_run.sh', 'tools/project_data_env.sh')]
rows = {}
with tarfile.open(BASE / 'qualified2-inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes(); name = str(path.relative_to(ROOT))
        rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=name, recursive=False)
(BASE / 'qualified2-input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
out = BASE / 'qualified2-reader'
out.mkdir()
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'review_qualified2.py')]
(out / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (out / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(out / 'exit.txt').write_text(str(result.returncode) + '\n')
print(result.stdout.decode(), end='')
if result.stderr:
    print(result.stderr.decode(), end='', file=__import__('sys').stderr)
raise SystemExit(result.returncode)
