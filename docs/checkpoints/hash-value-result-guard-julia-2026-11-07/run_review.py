"""Retain the complete first readonly historical-reader invocation."""
import gzip,json,subprocess
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
assert not (BASE/'review-exit.txt').exists()
command=['bash','tools/run_python_project_data.sh',str(BASE/'review.py')]
(BASE/'review-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'):(BASE/('review-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
(BASE/'review-exit.txt').write_text(str(result.returncode)+'\n')
print('readonly recovery exit',result.returncode,'stderr bytes',len(result.stderr))
if result.returncode==0:(BASE/'review-result.json').write_bytes(result.stdout)
assert result.returncode==0,'complete reader channels retained'
