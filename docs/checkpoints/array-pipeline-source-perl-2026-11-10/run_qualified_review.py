"""Bind qualified recovery instruments before use and retain actual results."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
names = ['review_qualified.py', 'run_qualified_review.py', 'reader-qualification.json',
         'diagnose_git_modes.py', 'review-command.json', 'review-exit.txt',
         'review-stdout.log.gz', 'review-stderr.log.gz', 'sealed-identities.json']
records = {}
with tarfile.open(BASE / 'qualified-reader-inputs.tar.gz', 'x:gz') as archive:
    for name in names:
        p = BASE / name
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
(BASE / 'qualified-reader-inputs.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
for prefix, script in [('mode-diagnostic', 'diagnose_git_modes.py'), ('qualified-review', 'review_qualified.py')]:
    packet = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(BASE / script)])
    target = BASE / (prefix + '-command.json')
    assert not target.exists()
    target.write_text(json.dumps(packet, indent=2) + '\n')
    result = subprocess.run(packet['argv'], cwd=packet['cwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / (prefix + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / (prefix + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in records.items():
        p = Path(name)
        assert hashlib.sha256(p.read_bytes()).hexdigest() == row['sha256'] and p.stat().st_mode & 0o777 == row['mode']
    assert result.returncode == 0 and result.stderr == b'', 'Qualified failure retained without PASS credit'
    if prefix == 'mode-diagnostic':
        outputs = {}
        with tarfile.open(BASE / 'qualified-diagnostic-inputs.tar.gz', 'x:gz') as archive:
            for name in ('mode-diagnostic.json', 'mode-diagnostic-command.json', 'mode-diagnostic-stdout.log.gz',
                         'mode-diagnostic-stderr.log.gz', 'mode-diagnostic-exit.txt'):
                p = BASE / name
                raw = p.read_bytes()
                outputs[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
                archive.add(p, arcname=p, recursive=False)
        (BASE / 'qualified-diagnostic-inputs.json').write_text(json.dumps(outputs, indent=2, sort_keys=True) + '\n')
    if prefix == 'qualified-review':
        (BASE / 'qualified-review-result.json').write_bytes(result.stdout)
        print(result.stdout.decode())
