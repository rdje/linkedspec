"""Retain complete channels of the first readonly historical recovery."""
import gzip,json,subprocess
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());command=['bash','tools/run_python_project_data.sh',str(base/'review.py')]
assert not (base/'review-exit.txt').exists()
(base/'review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for name in ('stdout','stderr'):(base/('review-'+name+'.log.gz')).write_bytes(gzip.compress(getattr(r,name),mtime=0))
(base/'review-exit.txt').write_text(str(r.returncode)+'\n')
print('first readonly recovery exit',r.returncode,'stderr bytes',len(r.stderr))
if r.returncode==0:(base/'review-result.json').write_bytes(r.stdout)
assert r.returncode==0,'full reader channels retained'
