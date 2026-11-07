"""Retain the exact staged candidate's targeted README containment result."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
OUT = BASE / 'final-containment'
OUT.mkdir()
patch = subprocess.check_output(['git', 'diff', '--cached', '--binary'])
(OUT / 'staged-input-sha256.txt').write_text(hashlib.sha256(patch).hexdigest() + '\n')
command = ['bash', 'scripts/check_readme_stability.sh']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0, 'README containment failed; actual first channels retained'
print('exact staged README routing/size containment:0; actual channels retained')
