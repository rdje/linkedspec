"""Retain full channels for the composition qualification and readonly check."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
mode=sys.argv[1];assert mode in ('write','review')
tag='binding-'+mode
assert not (BASE/(tag+'-exit.txt')).exists()
command=['bash','tools/run_python_project_data.sh',str(BASE/'qualify_claim.py')]
if mode=='write': command.append('--write')
(BASE/(tag+'-command.json')).write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'):
    (BASE/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
(BASE/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
print(tag,'exit',result.returncode,'stderr bytes',len(result.stderr))
assert result.returncode==0 and result.stderr==b''
