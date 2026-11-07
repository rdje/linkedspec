"""Retain full channels of the first readonly original-selection recovery."""
import gzip,json,subprocess
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
assert not (BASE/'review-exit.txt').exists()
command=['bash','tools/run_python_project_data.sh',str(BASE/'review.py')]
(BASE/'review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'):(BASE/('review-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(r,channel),mtime=0))
(BASE/'review-exit.txt').write_text(str(r.returncode)+'\n')
print('first readonly recovery exit',r.returncode,'stderr bytes',len(r.stderr))
if r.returncode==0:(BASE/'review-result.json').write_bytes(r.stdout)
assert r.returncode==0,'actual reader failure retained'
