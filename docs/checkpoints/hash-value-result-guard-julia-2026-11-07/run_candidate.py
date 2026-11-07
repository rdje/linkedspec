"""Retain the one-time candidate comparison command and complete channels."""
import gzip,json,subprocess
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd())
command=['bash','tools/run_python_project_data.sh',str(base/'check_candidate.py')]
(base/'candidate-command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for name in ('stdout','stderr'):(base/('candidate-'+name+'.log.gz')).write_bytes(gzip.compress(getattr(r,name),mtime=0))
(base/'candidate-exit.txt').write_text(str(r.returncode)+'\n')
assert r.returncode==0
print('current/direct candidate comparison PASS')
