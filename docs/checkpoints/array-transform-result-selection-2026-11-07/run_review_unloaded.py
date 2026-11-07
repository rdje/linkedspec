"""Retain full channels of the separate unloaded-module protocol recovery."""
import gzip,json,subprocess
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());command=['bash','tools/run_python_project_data.sh',str(base/'review_unloaded.py')]
assert not (base/'unloaded-review-exit.txt').exists()
(base/'unloaded-review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for name in ('stdout','stderr'):(base/('unloaded-review-'+name+'.log.gz')).write_bytes(gzip.compress(getattr(r,name),mtime=0))
(base/'unloaded-review-exit.txt').write_text(str(r.returncode)+'\n')
print('qualified unloaded-module recovery exit',r.returncode,'stderr bytes',len(r.stderr))
if r.returncode==0:(base/'unloaded-review-result.json').write_bytes(r.stdout)
assert r.returncode==0,'full qualified reader channels retained'
