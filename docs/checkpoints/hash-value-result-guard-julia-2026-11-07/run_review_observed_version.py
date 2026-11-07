"""Retain complete channels for the separate observed-version readonly reader."""
import gzip,json,subprocess
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd())
command=['bash','tools/run_python_project_data.sh',str(base/'review_observed_version.py')]
assert not (base/'observed-review-exit.txt').exists()
(base/'observed-review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for name in ('stdout','stderr'):(base/('observed-review-'+name+'.log.gz')).write_bytes(gzip.compress(getattr(r,name),mtime=0))
(base/'observed-review-exit.txt').write_text(str(r.returncode)+'\n')
print('observed-version readonly recovery exit',r.returncode,'stderr bytes',len(r.stderr))
if r.returncode==0:(base/'observed-review-result.json').write_bytes(r.stdout)
assert r.returncode==0,'complete qualified reader channels retained'
