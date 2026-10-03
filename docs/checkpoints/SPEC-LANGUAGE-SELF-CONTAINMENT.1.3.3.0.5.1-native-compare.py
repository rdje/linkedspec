"""Compare three existing return/result boundaries through the documented native CLI."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-'
CASES=('implicit_true','implicit_false','eager_local_return')
rows={r['id']:r for r in json.loads((ROOT/(PREFIX+'cases.json')).read_bytes())}
scratch=ROOT/'.linkedspec-data/scratch/codeblock-attached-if/native-comparison'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.resolve().is_relative_to(ROOT/'.linkedspec-data/scratch') and scratch.stat().st_dev==ROOT.stat().st_dev
results=[]
for id in CASES:
 source=rows[id]['source']
 fixture=scratch/(id+'.spec')
 fixture.write_text(source)
 command=['bash','tools/run_lua_project_data.sh','puc','lua/bin/linkedspec-lua','--spec-file',fixture.relative_to(ROOT).as_posix(),'--input','']
 run=subprocess.run(command,cwd=ROOT,env=os.environ,capture_output=True)
 assert run.returncode==0 and not run.stderr,(id,run.returncode,run.stderr)
 value=json.loads(run.stdout)
 assert value==rows[id]['expected'],(id,value)
 results.append({'id':id,'source':source,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode(),'value':value})
print(json.dumps({'version':1,'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1','boundary':'Published PUC Lua CLI comparison only; no backend admission or dependency-internal inspection.','cases':results},indent=2))
