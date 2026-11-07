"""Retain complete channels of the strict-error-shape readonly recovery."""
import gzip,json,subprocess
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());command=['bash','tools/run_python_project_data.sh',str(base/'review_typed_errors.py')]
assert not (base/'typed-review-exit.txt').exists()
(base/'typed-review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for name in ('stdout','stderr'):(base/('typed-review-'+name+'.log.gz')).write_bytes(gzip.compress(getattr(r,name),mtime=0))
(base/'typed-review-exit.txt').write_text(str(r.returncode)+'\n')
print('strict-error-shape recovery exit',r.returncode,'stderr bytes',len(r.stderr))
if r.returncode==0:(base/'typed-review-result.json').write_bytes(r.stdout)
assert r.returncode==0,'full strict reader channels retained'
