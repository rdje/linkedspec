"""Retain actual mutation producer/inputs and complete outer channels once."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
target = BASE / 'repair-command.json'
assert not target.exists()
names = [BASE / 'repair.py', BASE / 'run_repair.py', BASE / 'before/input-identities.json',
         Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')]
records = {}
with tarfile.open(BASE / 'repair-inputs.tar.gz', 'x:gz') as archive:
    for p in names:
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
(BASE / 'repair-input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
packet = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(BASE / 'repair.py')])
target.write_text(json.dumps(packet, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=packet['cwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('repair-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'repair-exit.txt').write_text(str(result.returncode) + '\n')
patch = subprocess.check_output(['git', 'diff', '--', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'])
(BASE / 'source.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
assert result.returncode == 0 and result.stderr == b'', 'Actual mutation failure retained; qualify before retry'
print(result.stdout.decode())
